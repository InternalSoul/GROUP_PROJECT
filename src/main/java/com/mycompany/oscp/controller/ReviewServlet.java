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

            String action = req.getParameter("action");
            if (action == null || action.trim().isEmpty()) {
                action = "create";
            }
            action = action.toLowerCase();

            String ratingParam = null;
            double rating = 0.0;
            String comment = null;

            // For create and update, we need a rating and comment
            if (!"delete".equals(action)) {
                ratingParam = req.getParameter("rating");
                if (ratingParam == null || ratingParam.trim().isEmpty()) {
                    session.setAttribute("error", "Please select a rating");
                    res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                    return;
                }

                try {
                    rating = Double.parseDouble(ratingParam);
                } catch (NumberFormatException ex) {
                    session.setAttribute("error", "Invalid rating value");
                    res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                    return;
                }

                comment = req.getParameter("comment");
            }

            try (Connection conn = DatabaseConnection.getConnection()) {
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

                if ("delete".equals(action)) {
                    // Delete an existing review belonging to this user
                    String reviewIdParam = req.getParameter("reviewId");
                    int reviewId;
                    try {
                        reviewId = Integer.parseInt(reviewIdParam);
                    } catch (NumberFormatException ex) {
                        session.setAttribute("error", "Invalid review request");
                        res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                        return;
                    }

                    String ownerSql = "SELECT user_id, product_id FROM reviews WHERE review_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(ownerSql)) {
                        ps.setInt(1, reviewId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) {
                                session.setAttribute("error", "Review not found");
                                res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                                return;
                            }
                            int ownerId = rs.getInt("user_id");
                            int ownerProductId = rs.getInt("product_id");
                            if (ownerId != userId || ownerProductId != productId) {
                                session.setAttribute("error", "You can only modify your own review.");
                                res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                                return;
                            }
                        }
                    }

                    String deleteSql = "DELETE FROM reviews WHERE review_id = ? AND user_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                        ps.setInt(1, reviewId);
                        ps.setInt(2, userId);
                        ps.executeUpdate();
                    }

                    String updateRatingSql = "UPDATE products SET rating = (SELECT AVG(CAST(rating AS DECIMAL(3,2))) FROM reviews WHERE product_id = ?) WHERE product_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateRatingSql)) {
                        ps.setInt(1, productId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                    }

                    req.setAttribute("msg", "Review deleted successfully ✅");
                    req.setAttribute("productId", productId);
                    req.getRequestDispatcher("/reviewSuccess.jsp").forward(req, res);
                    return;
                }

                if ("update".equals(action)) {
                    // Update an existing review belonging to this user
                    String reviewIdParam = req.getParameter("reviewId");
                    int reviewId;
                    try {
                        reviewId = Integer.parseInt(reviewIdParam);
                    } catch (NumberFormatException ex) {
                        session.setAttribute("error", "Invalid review request");
                        res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                        return;
                    }

                    String ownerSql = "SELECT user_id, product_id FROM reviews WHERE review_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(ownerSql)) {
                        ps.setInt(1, reviewId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) {
                                session.setAttribute("error", "Review not found");
                                res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                                return;
                            }
                            int ownerId = rs.getInt("user_id");
                            int ownerProductId = rs.getInt("product_id");
                            if (ownerId != userId || ownerProductId != productId) {
                                session.setAttribute("error", "You can only modify your own review.");
                                res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                                return;
                            }
                        }
                    }

                    String updateSql = "UPDATE reviews SET rating = ?, comment = ?, review_date = ? WHERE review_id = ? AND user_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                        ps.setDouble(1, rating);
                        ps.setString(2, comment != null ? comment : "");
                        ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
                        ps.setInt(4, reviewId);
                        ps.setInt(5, userId);
                        ps.executeUpdate();
                    }

                    String updateRatingSql = "UPDATE products SET rating = (SELECT AVG(CAST(rating AS DECIMAL(3,2))) FROM reviews WHERE product_id = ?) WHERE product_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateRatingSql)) {
                        ps.setInt(1, productId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                    }

                    req.setAttribute("msg", "Review updated successfully ✅");
                    req.setAttribute("productId", productId);
                    req.getRequestDispatcher("/reviewSuccess.jsp").forward(req, res);
                    return;
                }

                // Default: create a new review
                // Verify that the user has purchased this product
                boolean hasPurchased = false;
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
                    res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                    return;
                }

                // Check if this user already reviewed this product
                String existingSql = "SELECT COUNT(*) FROM reviews WHERE product_id = ? AND user_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(existingSql)) {
                    ps.setInt(1, productId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            session.setAttribute("error", "You have already reviewed this product.");
                            res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
                            return;
                        }
                    }
                }

                String insertSql = "INSERT INTO reviews (product_id, user_id, rating, comment, review_date) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, productId);
                    ps.setInt(2, userId);
                    ps.setDouble(3, rating);
                    ps.setString(4, comment != null ? comment : "");
                    ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
                    ps.executeUpdate();
                }

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
                session.setAttribute("error", "Failed to submit review. Please try again.");
                res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#write-review");
            }
        } catch (NumberFormatException e) {
            String productIdParam = req.getParameter("productId");
            session.setAttribute("error", "Invalid review request");
            if (productIdParam != null && !productIdParam.isEmpty()) {
                res.sendRedirect(req.getContextPath() + "/product?id=" + productIdParam + "#write-review");
            } else {
                res.sendRedirect(req.getContextPath() + "/products");
            }
        }
    }
}
