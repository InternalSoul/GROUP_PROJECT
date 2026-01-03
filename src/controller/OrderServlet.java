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
            // Calculate total
            double total = 0;
            for (Product p : cart) {
                total += p.getPrice();
            }

            // Create Order object
            Order order = new Order();
            order.setStatus("Pending");
            order.setUser(user);

            // Create OrderDetails list
            List<OrderDetails> detailsList = new ArrayList<>();
            for (Product p : cart) {
                OrderDetails od = new OrderDetails(1, p.getPrice(), p);
                detailsList.add(od);
            }
            order.setOrderDetails(detailsList);

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
                    try (PreparedStatement psItem = conn.prepareStatement(insertItemSql)) {
                        for (OrderDetails od : order.getOrderDetails()) {
                            Product p = od.getProduct();
                            psItem.setInt(1, dbOrderId);
                            psItem.setInt(2, p != null ? p.getId() : 0);
                            psItem.setString(3, p != null ? p.getName() : null);
                            psItem.setString(4, p != null ? p.getSellerUsername() : null);
                            psItem.setInt(5, od.getQuantity());
                            psItem.setDouble(6, od.getPrice());
                            psItem.addBatch();
                        }
                        psItem.executeBatch();
                    }
                }

                // After creating the order, clear the user's cart_items (move items from cart
                // to orders)
                try (PreparedStatement psClear = conn.prepareStatement(
                        "DELETE FROM cart_items WHERE user_username = ?")) {
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
