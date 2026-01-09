package com.mycompany.oscp.controller;

import com.mycompany.oscp.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/tracking")
public class TrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String orderIdParam = req.getParameter("orderId");

        if (orderIdParam == null) {
            req.setAttribute("error", "No order selected for tracking.");
            req.getRequestDispatcher("/tracking.jsp").forward(req, res);
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdParam);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid order ID for tracking.");
            req.getRequestDispatcher("/tracking.jsp").forward(req, res);
            return;
        }

        List<Order> orders = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Include payment_method from both orders and payments so it can
            // be shown on the tracking page even if one of them is NULL.
            String sql = "SELECT o.id, o.user_username, o.created_at, o.total_amount, o.status, " +
                    "o.payment_method, p.payment_method AS payment_method_payments, " +
                    "ot.tracking_id, ot.current_location, ot.estimated_delivery, ot.last_updated " +
                    "FROM orders o " +
                    "LEFT JOIN payments p ON o.id = p.order_id " +
                    "LEFT JOIN order_tracking ot ON o.id = ot.order_id " +
                    "WHERE o.user_username = ? AND o.id = ? " +
                    "ORDER BY o.created_at DESC";

            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setInt(2, orderId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("id"));
                order.setId(rs.getInt("id"));
                order.setOrderDate(rs.getTimestamp("created_at"));
                order.setDate(rs.getTimestamp("created_at"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("status"));

                // Map stored payment method (from orders or payments table)
                // to a user-friendly label
                String paymentMethodDb = rs.getString("payment_method");
                if (paymentMethodDb == null || paymentMethodDb.isEmpty()) {
                    paymentMethodDb = rs.getString("payment_method_payments");
                }
                if (paymentMethodDb != null) {
                    String methodDisplay;
                    switch (paymentMethodDb.toLowerCase()) {
                        case "online":
                            methodDisplay = "Online Banking";
                            break;
                        case "cash":
                            methodDisplay = "Cash on Delivery";
                            break;
                        case "card":
                        case "credit":
                        case "debit":
                            methodDisplay = "Credit/Debit Card";
                            break;
                        default:
                            methodDisplay = paymentMethodDb;
                    }
                    order.setPaymentMethod(methodDisplay);
                }

                // Use the logged-in user's address as delivery address (if available)
                if (user.getAddress() != null && !user.getAddress().isEmpty()) {
                    order.setAddress(user.getAddress());
                }

                // Set tracking info if exists
                if (rs.getObject("tracking_id") != null) {
                    OrderTracking tracking = new OrderTracking();
                    tracking.setTrackingId(rs.getInt("tracking_id"));
                    tracking.setOrderId(rs.getInt("id"));
                    tracking.setCurrentLocation(rs.getString("current_location"));
                    tracking.setEstimatedDelivery(rs.getTimestamp("estimated_delivery"));
                    tracking.setLastUpdated(rs.getTimestamp("last_updated"));
                    order.setTracking(tracking);
                }

                orders.add(order);
            }

            req.setAttribute("orders", orders);
            req.getRequestDispatcher("/tracking.jsp").forward(req, res);

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load tracking information: " + e.getMessage());
            req.getRequestDispatcher("/tracking.jsp").forward(req, res);
        }
    }
}
