package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.mycompany.oscp.model.*;

@WebServlet("/sellerDashboard")
public class SellerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Only sellers and admins can access dashboard
        if (!"seller".equals(user.getRole()) && !"admin".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        int productCount = 0;
        double totalValue = 0.0;
        double totalRevenue = 0.0;
        List<Product> latestProducts = new ArrayList<>();
        List<Map<String, Object>> recentOrders = new ArrayList<>();
        int orderCount = 0;
        int pendingOrders = 0;

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Get product count and catalog value
            String countSql = "SELECT COUNT(*) AS cnt, COALESCE(SUM(price),0) AS total_val FROM products WHERE seller_username = ?";
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setString(1, user.getUsername());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        productCount = rs.getInt("cnt");
                        totalValue = rs.getDouble("total_val");
                    }
                }
            }

            // Get order count and revenue for this seller
            String orderStatsSql = "SELECT COUNT(DISTINCT oi.order_id) as cnt, " +
                    "COALESCE(SUM(oi.quantity * oi.price), 0) as revenue, " +
                    "SUM(CASE WHEN o.status = 'Pending' THEN 1 ELSE 0 END) as pending " +
                    "FROM order_items oi " +
                    "JOIN orders o ON oi.order_id = o.id " +
                    "WHERE oi.seller_username = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderStatsSql)) {
                ps.setString(1, user.getUsername());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        orderCount = rs.getInt("cnt");
                        totalRevenue = rs.getDouble("revenue");
                        pendingOrders = rs.getInt("pending");
                    }
                }
            }

            // Get recent orders with items for this seller
            String ordersSql = "SELECT o.id, o.user_username, o.status, o.created_at, " +
                    "SUM(oi.quantity * oi.price) as seller_total " +
                    "FROM orders o " +
                    "JOIN order_items oi ON o.id = oi.order_id " +
                    "WHERE oi.seller_username = ? " +
                    "GROUP BY o.id, o.user_username, o.status, o.created_at " +
                    "ORDER BY o.created_at DESC " +
                    "FETCH FIRST 10 ROWS ONLY";
            try (PreparedStatement ps = conn.prepareStatement(ordersSql)) {
                ps.setString(1, user.getUsername());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> order = new HashMap<>();
                        order.put("orderId", rs.getInt("id"));
                        order.put("customerUsername", rs.getString("user_username"));
                        order.put("sellerTotal", rs.getDouble("seller_total"));
                        order.put("status", rs.getString("status"));
                        order.put("createdAt", rs.getTimestamp("created_at"));
                        recentOrders.add(order);
                    }
                }
            }

            // Get latest products
            String latestSql = "SELECT product_id, name, price, image, stock_quantity, in_stock " +
                    "FROM products WHERE seller_username = ? " +
                    "ORDER BY product_id DESC " +
                    "FETCH FIRST 5 ROWS ONLY";
            try (PreparedStatement ps = conn.prepareStatement(latestSql)) {
                ps.setString(1, user.getUsername());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Product p = new Product();
                        p.setId(rs.getInt("product_id"));
                        p.setName(rs.getString("name"));
                        p.setPrice(rs.getDouble("price"));
                        p.setImage(rs.getString("image") != null ? rs.getString("image") : "");
                        p.setStockQuantity(rs.getInt("stock_quantity"));
                        p.setInStock(rs.getBoolean("in_stock"));
                        latestProducts.add(p);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load dashboard data: " + e.getMessage());
        }

        // Set attributes for JSP
        req.setAttribute("productCount", productCount);
        req.setAttribute("totalValue", totalValue);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("orderCount", orderCount);
        req.setAttribute("pendingOrders", pendingOrders);
        req.setAttribute("latestProducts", latestProducts);
        req.setAttribute("recentOrders", recentOrders);

        req.getRequestDispatcher("/sellerDashboard.jsp").forward(req, res);
    }
}
