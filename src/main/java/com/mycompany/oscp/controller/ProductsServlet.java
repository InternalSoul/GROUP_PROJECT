package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.mycompany.oscp.model.*;

@WebServlet("/products")
public class ProductsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Check if user is logged in
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<Product> products = new ArrayList<>();
        String searchQuery = req.getParameter("search");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql;
            PreparedStatement stmt;

            // Search functionality
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                sql = "SELECT * FROM PRODUCTS WHERE UPPER(NAME) LIKE UPPER(?)";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, "%" + searchQuery + "%");
            } else {
                sql = "SELECT * FROM PRODUCTS";
                stmt = conn.prepareStatement(sql);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("PRODUCT_ID"));
                    p.setName(rs.getString("NAME"));
                    p.setPrice(rs.getDouble("PRICE"));
                    // Handle IMAGE column if it exists
                    try {
                        p.setImage(rs.getString("IMAGE"));
                    } catch (SQLException e) {
                        p.setImage("");
                    }
                    products.add(p);
                }
            }
            stmt.close();

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load products: " + e.getMessage());
        }

        req.setAttribute("products", products);
        req.getRequestDispatcher("/products.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = req.getParameter("action");

        // Only sellers can add/delete products
        if (!"seller".equalsIgnoreCase(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM PRODUCTS WHERE PRODUCT_ID = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            } else if ("add".equals(action)) {
                String name = req.getParameter("name");
                double price = Double.parseDouble(req.getParameter("price"));
                String image = req.getParameter("image");

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO PRODUCTS (NAME, PRICE, IMAGE) VALUES (?, ?, ?)")) {
                    ps.setString(1, name);
                    ps.setDouble(2, price);
                    ps.setString(3, image != null ? image : "");
                    ps.executeUpdate();
                }
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }

        res.sendRedirect(req.getContextPath() + "/products");
    }
}
