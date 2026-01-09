package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.mycompany.oscp.model.*;

@WebServlet("/product")
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idParam);
        } catch (NumberFormatException ex) {
            res.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        Product product = null;
        List<Review> reviews = new ArrayList<>();
        double averageRating = 0.0;
        List<Product> variants = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Fetch the product record (follow actual DB schema)
            String productSql = "SELECT product_id, name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock FROM products WHERE product_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(productSql)) {
                stmt.setInt(1, productId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        product = new Product();
                        product.setId(rs.getInt("product_id"));
                        product.setName(rs.getString("name"));
                        product.setPrice(rs.getDouble("price"));
                        product.setImage(rs.getString("image") != null ? rs.getString("image") : "");
                        product.setSellerUsername(
                                rs.getString("seller_username") != null ? rs.getString("seller_username") : "");
                        product.setCategory(rs.getString("category") != null ? rs.getString("category") : "");
                        product.setProductType(
                                rs.getString("product_type") != null ? rs.getString("product_type") : "");
                        product.setSize(rs.getString("size") != null ? rs.getString("size") : "");
                        product.setColor(rs.getString("color") != null ? rs.getString("color") : "");
                        product.setBrand(rs.getString("brand") != null ? rs.getString("brand") : "");
                        product.setMaterial(rs.getString("material") != null ? rs.getString("material") : "");
                        product.setRating(rs.getDouble("rating"));
                        product.setInStock(rs.getBoolean("in_stock"));
                    }
                }
            }

            // Fetch all variants for this product based on same seller and name so
            // we can show size/color availability in the Add to Cart pop out.
            if (product != null && product.getSellerUsername() != null
                    && !product.getSellerUsername().isEmpty()) {
                String variantSql = "SELECT product_id, name, price, image, seller_username, size, color, in_stock, stock_quantity "
                        + "FROM products WHERE seller_username = ? AND name = ?";
                try (PreparedStatement vstmt = conn.prepareStatement(variantSql)) {
                    vstmt.setString(1, product.getSellerUsername());
                    vstmt.setString(2, product.getName());
                    try (ResultSet vrs = vstmt.executeQuery()) {
                        while (vrs.next()) {
                            Product v = new Product();
                            v.setId(vrs.getInt("product_id"));
                            v.setName(vrs.getString("name"));
                            v.setPrice(vrs.getDouble("price"));
                            v.setImage(vrs.getString("image") != null ? vrs.getString("image") : "");
                            v.setSellerUsername(vrs.getString("seller_username") != null
                                    ? vrs.getString("seller_username")
                                    : "");
                            v.setSize(vrs.getString("size") != null ? vrs.getString("size") : "");
                            v.setColor(vrs.getString("color") != null ? vrs.getString("color") : "");
                            v.setInStock(vrs.getBoolean("in_stock"));
                            v.setStockQuantity(vrs.getInt("stock_quantity"));
                            variants.add(v);
                        }
                    }
                }
            }

            // Fetch reviews for the product
            String reviewSql = "SELECT r.review_id, r.product_id, r.user_id, r.rating, r.comment, r.review_date, u.username "
                    +
                    "FROM reviews r " +
                    "JOIN users u ON r.user_id = u.user_id " +
                    "WHERE r.product_id = ? ORDER BY r.review_date DESC";
            try (PreparedStatement stmt = conn.prepareStatement(reviewSql)) {
                stmt.setInt(1, productId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Review review = new Review();
                        review.setId(rs.getInt("review_id"));
                        review.setProductId(rs.getInt("product_id"));
                        review.setUserId(String.valueOf(rs.getInt("user_id")));
                        review.setUsername(rs.getString("username"));
                        review.setRating(rs.getDouble("rating"));
                        review.setComment(rs.getString("comment") != null ? rs.getString("comment") : "");
                        try {
                            review.setCreatedAt(rs.getTimestamp("review_date"));
                        } catch (SQLException ignored) {
                            review.setCreatedAt(null);
                        }
                        reviews.add(review);
                    }
                }
            } catch (SQLException reviewEx) {
                // Reviews table might not be present; continue with empty list
                reviewEx.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (product == null) {
            res.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        if (!reviews.isEmpty()) {
            double sum = 0.0;
            for (Review r : reviews) {
                sum += r.getRating();
            }
            averageRating = sum / reviews.size();
        } else {
            averageRating = product.getRating();
        }

        String description = buildDescription(product);

        req.setAttribute("product", product);
        req.setAttribute("reviews", reviews);
        req.setAttribute("averageRating", averageRating);
        req.setAttribute("reviewCount", reviews.size());
        req.setAttribute("description", description);
        req.setAttribute("variants", variants);

        req.getRequestDispatcher("/product-details.jsp").forward(req, res);
    }

    private String buildDescription(Product product) {
        StringBuilder sb = new StringBuilder();
        if (product.getBrand() != null && !product.getBrand().isEmpty()) {
            sb.append(product.getBrand()).append(" · ");
        }
        if (product.getMaterial() != null && !product.getMaterial().isEmpty()) {
            sb.append(product.getMaterial()).append(" · ");
        }
        String desc = sb.toString().trim();
        if (desc.endsWith("·")) {
            desc = desc.substring(0, desc.length() - 1).trim();
        }
        if (desc.isEmpty()) {
            return "This piece is crafted with attention to detail. Check specs below for sizing and materials.";
        }
        return desc;
    }
}
