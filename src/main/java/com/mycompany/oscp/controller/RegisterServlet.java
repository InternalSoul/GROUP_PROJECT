package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import com.mycompany.oscp.model.*;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String address = req.getParameter("address");
        String role = req.getParameter("role"); // customer or seller

        // Validate inputs
        if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "All fields are required");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if username already exists
            String checkSql = "SELECT COUNT(*) FROM USERS WHERE USERNAME = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, username);
                ResultSet rs = checkPs.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    req.setAttribute("error", "Username already exists");
                    req.getRequestDispatcher("/register.jsp").forward(req, res);
                    return;
                }
            }

            // Insert new user
            String sql = "INSERT INTO USERS (USERNAME, EMAIL, PASSWORD, ROLE, ADDRESS) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setString(4, role != null ? role : "customer");
                ps.setString(5, address != null ? address : "");
                ps.executeUpdate();
            }

            // Redirect to login with success message
            req.setAttribute("success", "Registration successful! Please login.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Registration failed: " + e.getMessage());
            req.getRequestDispatcher("/register.jsp").forward(req, res);
        }
    }
}
