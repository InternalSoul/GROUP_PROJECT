package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.mycompany.oscp.model.*;

public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String username = user.getUsername();
        String role = user.getRole();

        List<Order> customerOrders = new ArrayList<>();
        List<Order> sellerOrders = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Customer order history
            String orderSql = "SELECT id, user_username, total_amount, status, created_at FROM orders WHERE user_username = ? ORDER BY created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Order order = new Order();
                        order.setId(rs.getInt("id"));
                        order.setUser(user);
                        order.setStatus(rs.getString("status"));
                        order.setDate(rs.getTimestamp("created_at"));

                        List<OrderDetails> details = new ArrayList<>();
                        // Join products to get the latest image for each product
                        String itemSql = "SELECT oi.product_id, oi.product_name, oi.seller_username, oi.quantity, oi.price, p.image "
                                +
                                "FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id WHERE oi.order_id = ?";
                        try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                            psItem.setInt(1, order.getId());
                            try (ResultSet rsItem = psItem.executeQuery()) {
                                while (rsItem.next()) {
                                    Product p = new Product();
                                    p.setId(rsItem.getInt("product_id"));
                                    p.setName(rsItem.getString("product_name"));
                                    p.setSellerUsername(rsItem.getString("seller_username"));
                                    p.setPrice(rsItem.getDouble("price"));
                                    p.setImage(rsItem.getString("image") != null ? rsItem.getString("image") : "");
                                    OrderDetails od = new OrderDetails(rsItem.getInt("quantity"),
                                            rsItem.getDouble("price"), p);
                                    details.add(od);
                                }
                            }
                        }
                        order.setOrderDetails(details);
                        customerOrders.add(order);
                    }
                }
            }

            // Seller sales history (for seller/admin roles)
            if ("seller".equals(role) || "admin".equals(role)) {
                String sellerSql = "SELECT o.id, o.user_username, o.total_amount, o.status, o.created_at, " +
                        "oi.product_id, oi.product_name, oi.quantity, oi.price, p.image " +
                        "FROM orders o JOIN order_items oi ON o.id = oi.order_id " +
                        "LEFT JOIN products p ON oi.product_id = p.product_id " +
                        "WHERE oi.seller_username = ? ORDER BY o.created_at DESC";
                try (PreparedStatement ps = conn.prepareStatement(sellerSql)) {
                    ps.setString(1, username);
                    try (ResultSet rs = ps.executeQuery()) {
                        Map<Integer, Order> orderMap = new LinkedHashMap<>();
                        while (rs.next()) {
                            int orderId = rs.getInt("id");
                            Order order = orderMap.get(orderId);
                            if (order == null) {
                                order = new Order();
                                order.setId(orderId);
                                User buyer = new User();
                                buyer.setUsername(rs.getString("user_username"));
                                order.setUser(buyer);
                                order.setStatus(rs.getString("status"));
                                order.setDate(rs.getTimestamp("created_at"));
                                order.setOrderDetails(new ArrayList<>());
                                orderMap.put(orderId, order);
                            }
                            Product p = new Product();
                            p.setId(rs.getInt("product_id"));
                            p.setName(rs.getString("product_name"));
                            p.setPrice(rs.getDouble("price"));
                            p.setSellerUsername(username);
                            p.setImage(rs.getString("image") != null ? rs.getString("image") : "");
                            OrderDetails od = new OrderDetails(rs.getInt("quantity"), rs.getDouble("price"), p);
                            order.getOrderDetails().add(od);
                        }
                        sellerOrders.addAll(orderMap.values());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("customerOrders", customerOrders);
        req.setAttribute("sellerOrders", sellerOrders);

        req.getRequestDispatcher("/orderHistory.jsp").forward(req, res);
    }
}
