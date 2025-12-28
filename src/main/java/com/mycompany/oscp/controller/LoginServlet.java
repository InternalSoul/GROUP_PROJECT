package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import com.mycompany.oscp.model.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM USERS WHERE USERNAME=? AND PASSWORD=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        User user = new User();
                        user.setId(rs.getInt("USER_ID"));
                        user.setUsername(rs.getString("USERNAME"));
                        user.setEmail(rs.getString("EMAIL"));
                        user.setRole(rs.getString("ROLE"));
                        user.setAddress(rs.getString("ADDRESS"));

                        HttpSession session = req.getSession();
                        session.setAttribute("user", user);

                        // Redirect based on role
                        if ("seller".equalsIgnoreCase(user.getRole())) {
                            res.sendRedirect(req.getContextPath() + "/sellerDashboard.jsp");
                        } else {
                            res.sendRedirect(req.getContextPath() + "/products");
                        }
                        return;
                    } else {
                        req.setAttribute("error", "Invalid username or password");
                        req.getRequestDispatcher("/login.jsp").forward(req, res);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Login failed: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, res);
        }
    }
}
