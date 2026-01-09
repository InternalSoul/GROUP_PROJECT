package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.mycompany.oscp.model.*;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        @SuppressWarnings("unchecked")
        List<Product> cart = (List<Product>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        // Get payment method from form
        String paymentMethod = req.getParameter("method");
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/payment.jsp");
            return;
        }

        // Map UI payment method to DB-friendly codes used in `payments` table
        // (allowed values: 'online', 'cash') and derive payment status.
        String paymentMethodDb = "cash";
        if ("Online".equalsIgnoreCase(paymentMethod) || "Card".equalsIgnoreCase(paymentMethod)) {
            paymentMethodDb = "online";
        }

        String paymentStatusDb = "pending";
        if ("Online".equalsIgnoreCase(paymentMethod) || "Card".equalsIgnoreCase(paymentMethod)) {
            paymentStatusDb = "completed";
        }

        try {
            // Create Order object
            Order order = new Order();
            order.setStatus("Pending");
            order.setUser(user);
            order.setPaymentMethod(paymentMethod);

            // Group cart items by product so quantities are tracked correctly
            Map<Integer, Product> productById = new LinkedHashMap<>();
            Map<Integer, Integer> quantityById = new LinkedHashMap<>();
            for (Product p : cart) {
                int pid = p.getId();
                if (!productById.containsKey(pid)) {
                    productById.put(pid, p);
                    quantityById.put(pid, 0);
                }
                quantityById.put(pid, quantityById.get(pid) + 1);
            }

            // Create OrderDetails list with aggregated quantities
            List<OrderDetails> detailsList = new ArrayList<>();
            for (Map.Entry<Integer, Product> entry : productById.entrySet()) {
                Product p = entry.getValue();
                int qty = quantityById.get(entry.getKey());
                OrderDetails od = new OrderDetails(qty, p.getPrice(), p);
                detailsList.add(od);
            }
            order.setOrderDetails(detailsList);

            // Calculate total based on aggregated order details
            double total = order.calcTotal();

            // Persist order and items immediately for order history
            try (Connection conn = DatabaseConnection.getConnection()) {
                conn.setAutoCommit(false);

                // Validate stock availability before creating order
                String stockCheckSql = "SELECT stock_quantity, in_stock, name FROM products WHERE product_id = ?";
                try (PreparedStatement psStock = conn.prepareStatement(stockCheckSql)) {
                    for (Map.Entry<Integer, Integer> entry : quantityById.entrySet()) {
                        int productId = entry.getKey();
                        int requestedQty = entry.getValue();

                        psStock.setInt(1, productId);
                        try (ResultSet rsStock = psStock.executeQuery()) {
                            if (rsStock.next()) {
                                int availableStock = rsStock.getInt("stock_quantity");
                                boolean inStock = rsStock.getBoolean("in_stock");
                                String productName = rsStock.getString("name");

                                if (!inStock || availableStock < requestedQty) {
                                    conn.rollback();
                                    req.setAttribute("error", "Insufficient stock for " + productName +
                                            ". Only " + availableStock + " available.");
                                    req.getRequestDispatcher("/cart").forward(req, res);
                                    return;
                                }
                            }
                        }
                    }
                }

                String insertOrderSql = "INSERT INTO orders (user_username, total_amount, status, payment_method, created_at) VALUES (?,?,?,?,CURRENT_TIMESTAMP)";
                int dbOrderId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, user.getUsername());
                    ps.setDouble(2, total);
                    ps.setString(3, order.getStatus());
                    ps.setString(4, paymentMethod);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            dbOrderId = rs.getInt(1);
                        }
                    }
                }

                if (dbOrderId > 0 && order.getOrderDetails() != null) {
                    order.setId(dbOrderId);
                    String insertItemSql = "INSERT INTO order_items (order_id, product_id, product_name, seller_username, quantity, price) VALUES (?,?,?,?,?,?)";
                    String sellerLookupSql = "SELECT seller_username FROM products WHERE product_id = ?";
                    try (PreparedStatement psItem = conn.prepareStatement(insertItemSql);
                            PreparedStatement psSeller = conn.prepareStatement(sellerLookupSql)) {
                        for (OrderDetails od : order.getOrderDetails()) {
                            Product p = od.getProduct();

                            String sellerUsername = null;
                            if (p != null) {
                                psSeller.setInt(1, p.getId());
                                try (ResultSet rsSeller = psSeller.executeQuery()) {
                                    if (rsSeller.next()) {
                                        sellerUsername = rsSeller.getString("seller_username");
                                    }
                                }
                            }

                            psItem.setInt(1, dbOrderId);
                            psItem.setInt(2, p != null ? p.getId() : 0);
                            psItem.setString(3, p != null ? p.getName() : null);
                            psItem.setString(4, sellerUsername);
                            psItem.setInt(5, od.getQuantity());
                            psItem.setDouble(6, od.getPrice());
                            psItem.addBatch();
                        }
                        psItem.executeBatch();
                    }
                }

                // Create payment record linked to this order so that tracking and
                // reporting can always see a non-null payment_method.
                if (dbOrderId > 0) {
                    String insertPaymentSql = "INSERT INTO payments (order_id, payment_method, amount, status, paid_at) VALUES (?,?,?,?,?)";
                    try (PreparedStatement psPay = conn.prepareStatement(insertPaymentSql)) {
                        psPay.setInt(1, dbOrderId);
                        psPay.setString(2, paymentMethodDb);
                        psPay.setDouble(3, total);
                        psPay.setString(4, paymentStatusDb);
                        if ("completed".equalsIgnoreCase(paymentStatusDb)) {
                            psPay.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
                        } else {
                            psPay.setTimestamp(5, null);
                        }
                        psPay.executeUpdate();
                    }
                }

                // After creating the order, clear the user's cart items from carts/cart_items
                // First get cart_id for the customer
                int cartId = 0;
                String getCartSql = "SELECT cart_id FROM carts WHERE customer_username = ?";
                try (PreparedStatement psGetCart = conn.prepareStatement(getCartSql)) {
                    psGetCart.setString(1, user.getUsername());
                    try (ResultSet rsCart = psGetCart.executeQuery()) {
                        if (rsCart.next()) {
                            cartId = rsCart.getInt("cart_id");
                        }
                    }
                }

                // Clear cart items if cart exists
                if (cartId > 0) {
                    String clearSql = "DELETE FROM cart_items WHERE cart_id = ?";
                    try (PreparedStatement psClear = conn.prepareStatement(clearSql)) {
                        psClear.setInt(1, cartId);
                        psClear.executeUpdate();
                    }
                }

                // Create initial order tracking
                String trackingSql = "INSERT INTO order_tracking (order_id, current_location, estimated_delivery, last_updated) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
                try (PreparedStatement psTrack = conn.prepareStatement(trackingSql)) {
                    psTrack.setInt(1, dbOrderId);
                    psTrack.setString(2, "Order Placed - Processing");
                    // Set estimated delivery to 7 days from now
                    psTrack.setTimestamp(3, new Timestamp(System.currentTimeMillis() + (7L * 24 * 60 * 60 * 1000)));
                    psTrack.executeUpdate();
                }

                // Decrement stock quantities for ordered products
                String updateStockSql = "UPDATE products SET stock_quantity = stock_quantity - ? WHERE product_id = ?";
                try (PreparedStatement psUpdateStock = conn.prepareStatement(updateStockSql)) {
                    for (Map.Entry<Integer, Integer> entry : quantityById.entrySet()) {
                        psUpdateStock.setInt(1, entry.getValue());
                        psUpdateStock.setInt(2, entry.getKey());
                        psUpdateStock.addBatch();
                    }
                    psUpdateStock.executeBatch();
                }

                conn.commit();
                session.setAttribute("orderDbId", dbOrderId);
            } catch (SQLException se) {
                se.printStackTrace();
            }

            // Store order in session and clear cart
            session.setAttribute("order", order);
            session.setAttribute("orderTotal", total);
            session.removeAttribute("cart");

            // Pass the actual database order ID to orderSuccess page
            Integer dbOrderId = (Integer) session.getAttribute("orderDbId");
            if (dbOrderId != null && dbOrderId > 0) {
                req.setAttribute("orderId", "ORD" + dbOrderId);
            } else {
                req.setAttribute("orderId", "ORD" + System.currentTimeMillis());
            }

            // Redirect to order success page
            req.getRequestDispatcher("/orderSuccess.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error processing order");
            req.getRequestDispatcher("/cart").forward(req, res);
        }
    }
}
