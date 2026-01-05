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
        List<Order> orders = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Use correct column names: id, user_username, created_at
            String sql = "SELECT o.id, o.user_username, o.created_at, o.total_amount, o.status, " +
                        "ot.tracking_id, ot.current_location, ot.estimated_delivery, ot.last_updated " +
                        "FROM orders o " +
                        "LEFT JOIN order_tracking ot ON o.id = ot.order_id " +
                        "WHERE o.user_username = ? " +
                        "ORDER BY o.created_at DESC";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("id"));
                order.setId(rs.getInt("id"));
                order.setOrderDate(rs.getTimestamp("created_at"));
                order.setDate(rs.getTimestamp("created_at"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("status"));
                
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
