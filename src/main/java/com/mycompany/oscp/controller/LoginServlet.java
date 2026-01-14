package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import com.mycompany.oscp.model.*;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM users WHERE username=? AND password=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        User user = new User();
                        user.setUsername(rs.getString("username"));
                        user.setEmail(rs.getString("email"));
                        user.setRole(rs.getString("role"));
                        user.setAddress(rs.getString("address"));

                        HttpSession session = req.getSession();
                        session.setAttribute("user", user);

                        String contextPath = req.getContextPath();
                        if ("customer".equals(user.getRole())) {
                            res.sendRedirect(contextPath + "/products");
                        } else {
                            res.sendRedirect(contextPath + "/sellerDashboard");
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
