package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import model.*;

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

        try {
            // Create Order object
            Order order = new Order();
            order.setStatus("Pending");
            order.setUser(user);

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

                String insertOrderSql = "INSERT INTO orders (user_username, total_amount, status, created_at) VALUES (?,?,?,NOW())";
                int dbOrderId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, user.getUsername());
                    ps.setDouble(2, total);
                    ps.setString(3, order.getStatus());
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

                // After creating the order, clear the user's cart items from carts/cart_items
                String clearSql = "DELETE ci FROM cart_items ci " +
                        "JOIN carts c ON ci.cart_id = c.cart_id " +
                        "JOIN users u ON c.user_id = u.user_id " +
                        "WHERE u.username = ?";
                try (PreparedStatement psClear = conn.prepareStatement(clearSql)) {
                    psClear.setString(1, user.getUsername());
                    psClear.executeUpdate();
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

            // Generate order ID for display
            String orderId = "ORD" + System.currentTimeMillis();
            req.setAttribute("orderId", orderId);

            // Redirect to order success page
            req.getRequestDispatcher("/orderSuccess.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error processing order");
            req.getRequestDispatcher("/cart").forward(req, res);
        }
    }
}
