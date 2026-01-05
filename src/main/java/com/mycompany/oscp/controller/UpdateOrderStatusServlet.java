package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import com.mycompany.oscp.model.*;

@WebServlet("/updateOrderStatus")
public class UpdateOrderStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Only sellers and admins can update order status
        if (!"seller".equals(user.getRole()) && !"admin".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        String orderIdParam = req.getParameter("orderId");
        String newStatus = req.getParameter("status");
        String trackingLocation = req.getParameter("trackingLocation");

        if (orderIdParam == null || newStatus == null || orderIdParam.isEmpty() || newStatus.isEmpty()) {
            req.setAttribute("error", "Order ID and status are required");
            req.getRequestDispatcher("/sellerDashboard.jsp").forward(req, res);
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);

            try (Connection conn = DatabaseConnection.getConnection()) {
                conn.setAutoCommit(false);

                // Verify the seller owns products in this order
                if ("seller".equals(user.getRole())) {
                    String verifySql = "SELECT COUNT(*) as count FROM order_items " +
                            "WHERE order_id = ? AND seller_username = ?";
                    try (PreparedStatement psVerify = conn.prepareStatement(verifySql)) {
                        psVerify.setInt(1, orderId);
                        psVerify.setString(2, user.getUsername());
                        try (ResultSet rs = psVerify.executeQuery()) {
                            if (rs.next() && rs.getInt("count") == 0) {
                                req.setAttribute("error", "You don't have permission to update this order");
                                req.getRequestDispatcher("/sellerDashboard.jsp").forward(req, res);
                                return;
                            }
                        }
                    }
                }

                // Update order status
                String updateOrderSql = "UPDATE orders SET status = ? WHERE id = ?";
                try (PreparedStatement psUpdate = conn.prepareStatement(updateOrderSql)) {
                    psUpdate.setString(1, newStatus);
                    psUpdate.setInt(2, orderId);
                    int rowsUpdated = psUpdate.executeUpdate();

                    if (rowsUpdated == 0) {
                        conn.rollback();
                        req.setAttribute("error", "Order not found");
                        req.getRequestDispatcher("/sellerDashboard").forward(req, res);
                        return;
                    }
                }

                // Update order tracking if location provided
                if (trackingLocation != null && !trackingLocation.isEmpty()) {
                    String updateTrackingSql = "UPDATE order_tracking SET current_location = ?, " +
                            "last_updated = CURRENT_TIMESTAMP WHERE order_id = ?";
                    try (PreparedStatement psTracking = conn.prepareStatement(updateTrackingSql)) {
                        psTracking.setString(1, trackingLocation);
                        psTracking.setInt(2, orderId);
                        psTracking.executeUpdate();
                    }
                } else {
                    // Set default tracking location based on status
                    String defaultLocation = getDefaultTrackingLocation(newStatus);
                    String updateTrackingSql = "UPDATE order_tracking SET current_location = ?, " +
                            "last_updated = CURRENT_TIMESTAMP WHERE order_id = ?";
                    try (PreparedStatement psTracking = conn.prepareStatement(updateTrackingSql)) {
                        psTracking.setString(1, defaultLocation);
                        psTracking.setInt(2, orderId);
                        psTracking.executeUpdate();
                    }
                }

                conn.commit();
                req.setAttribute("success", "Order status updated successfully");

            } catch (SQLException e) {
                e.printStackTrace();
                req.setAttribute("error", "Failed to update order status: " + e.getMessage());
            }

        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid order ID");
        }

        req.getRequestDispatcher("/sellerDashboard").forward(req, res);
    }

    private String getDefaultTrackingLocation(String status) {
        switch (status.toLowerCase()) {
            case "pending":
                return "Order Placed - Awaiting Confirmation";
            case "processing":
                return "Order Confirmed - Preparing for Shipment";
            case "shipped":
                return "Package Shipped - In Transit";
            case "out for delivery":
                return "Out for Delivery - Arriving Today";
            case "delivered":
                return "Delivered - Order Complete";
            case "cancelled":
                return "Order Cancelled";
            default:
                return "Status: " + status;
        }
    }
}
