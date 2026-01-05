package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import com.mycompany.oscp.model.*;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Check if user is logged in
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int productId = Integer.parseInt(req.getParameter("productId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");

            // Verify that the user has purchased this product
            boolean hasPurchased = false;
            try (Connection conn = DatabaseConnection.getConnection()) {
                String checkSql = "SELECT COUNT(*) FROM orders o " +
                                "JOIN order_items oi ON o.id = oi.order_id " +
                                "WHERE user_username = ? AND oi.product_id = ? AND status = 'Delivered'";
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setString(1, user.getUsername());
                    ps.setInt(2, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            hasPurchased = true;
                        }
                    }
                }

                if (!hasPurchased) {
                    session.setAttribute("error", "You can only review products you have purchased");
                    res.sendRedirect(req.getContextPath() + "/orderHistory");
                    return;
                }

                // Get user_id from username
                int userId = 0;
                String userIdSql = "SELECT user_id FROM users WHERE username = ?";
                try (PreparedStatement ps = conn.prepareStatement(userIdSql)) {
                    ps.setString(1, user.getUsername());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            userId = rs.getInt("user_id");
                        }
                    }
                }

                if (userId == 0) {
                    session.setAttribute("error", "User not found");
                    res.sendRedirect(req.getContextPath() + "/orderHistory");
                    return;
                }

                // Insert the review
                String insertSql = "INSERT INTO reviews (product_id, user_id, rating, comment, review_date) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, productId);
                    ps.setInt(2, userId);
                    ps.setInt(3, rating);
                    ps.setString(4, comment != null ? comment : "");
                    ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
                    ps.executeUpdate();
                }

                // Update product's average rating
                String updateRatingSql = "UPDATE products SET rating = (SELECT AVG(CAST(rating AS DECIMAL(3,2))) FROM reviews WHERE product_id = ?) WHERE product_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateRatingSql)) {
                    ps.setInt(1, productId);
                    ps.setInt(2, productId);
                    ps.executeUpdate();
                }

                req.setAttribute("msg", "Review submitted successfully ✅");
                req.setAttribute("productId", productId);
                req.getRequestDispatcher("/reviewSuccess.jsp").forward(req, res);
            } catch (SQLException e) {
                e.printStackTrace();
                session.setAttribute("error", "Failed to submit review: " + e.getMessage());
                res.sendRedirect(req.getContextPath() + "/review.jsp?productId=" + productId);
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid input");
            res.sendRedirect(req.getContextPath() + "/orderHistory");
        }
    }
}
