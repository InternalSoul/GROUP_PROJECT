package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import model.*;

@WebServlet("/products")
public class ProductsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<Product> products = new ArrayList<>();
        String searchQuery = req.getParameter("search"); // 1. Get search input
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            
            String sql;
            PreparedStatement stmt;

            // 2. Choose query based on whether user is searching
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                sql = "SELECT * FROM products WHERE name LIKE ?";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, "%" + searchQuery + "%"); // Add wildcards
            } else {
                sql = "SELECT * FROM products";
                stmt = conn.prepareStatement(sql);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("product_id"));
                    p.setName(rs.getString("name"));
                    p.setPrice(rs.getDouble("price"));
                    products.add(p);
                }
            }
            // Close statement explicitly since it was created conditionally
            stmt.close();

            
        // Fetch products from database
        // try (Connection conn = DatabaseConnection.getConnection();
        //         Statement stmt = conn.createStatement();
        //         ResultSet rs = stmt.executeQuery("SELECT * FROM products")) {

        //     while (rs.next()) {
        //         Product p = new Product();
        //         p.setId(rs.getInt("product_id"));
        //         p.setName(rs.getString("name"));
        //         p.setPrice(rs.getDouble("price"));
        //         products.add(p);
        //     }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Store products in request attribute (not application)
        req.setAttribute("products", products);

        // Forward to JSP
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

        String action = req.getParameter("action"); // null or "delete"

        try (Connection conn = DatabaseConnection.getConnection()) {

            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM products WHERE product_id = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            } else {
                String name = req.getParameter("name");
                double price = Double.parseDouble(req.getParameter("price"));
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO products (name, price) VALUES (?, ?)")) {
                    ps.setString(1, name);
                    ps.setDouble(2, price);
                    ps.executeUpdate();
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // After add/delete, redirect back to products page
        res.sendRedirect(req.getContextPath() + "/products");
    }
}
