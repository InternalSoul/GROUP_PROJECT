package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import com.mycompany.oscp.model.*;

public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Fetch fresh user data from database
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT username, email, role, address, phone FROM users WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, user.getUsername());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        user.setEmail(rs.getString("email"));
                        user.setRole(rs.getString("role"));
                        user.setAddress(rs.getString("address"));
                        user.setPhone(rs.getString("phone"));
                        session.setAttribute("user", user);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String email = req.getParameter("email");
        String address = req.getParameter("address");
        String phone = req.getParameter("phone");
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        try (Connection conn = DatabaseConnection.getConnection()) {
            // If user wants to change password, verify current password first
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                if (currentPassword == null || currentPassword.trim().isEmpty()) {
                    session.setAttribute("error", "Current password is required to change password");
                    res.sendRedirect(req.getContextPath() + "/profile");
                    return;
                }

                if (!newPassword.equals(confirmPassword)) {
                    session.setAttribute("error", "New passwords do not match");
                    res.sendRedirect(req.getContextPath() + "/profile");
                    return;
                }

                // Verify current password
                String checkSql = "SELECT password FROM users WHERE username = ?";
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setString(1, user.getUsername());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String storedPassword = rs.getString("password");
                            if (!currentPassword.equals(storedPassword)) {
                                session.setAttribute("error", "Current password is incorrect");
                                res.sendRedirect(req.getContextPath() + "/profile");
                                return;
                            }
                        }
                    }
                }

                // Update with new password
                String updateSql = "UPDATE users SET email = ?, address = ?, phone = ?, password = ? WHERE username = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, email);
                    ps.setString(2, address);
                    ps.setString(3, phone);
                    ps.setString(4, newPassword);
                    ps.setString(5, user.getUsername());
                    ps.executeUpdate();
                }
            } else {
                // Update without changing password
                String updateSql = "UPDATE users SET email = ?, address = ?, phone = ? WHERE username = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, email);
                    ps.setString(2, address);
                    ps.setString(3, phone);
                    ps.setString(4, user.getUsername());
                    ps.executeUpdate();
                }
            }

            // Update session user object
            user.setEmail(email);
            user.setAddress(address);
            user.setPhone(phone);
            session.setAttribute("user", user);
            session.setAttribute("success", "Profile updated successfully");

        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Failed to update profile: " + e.getMessage());
        }

        res.sendRedirect(req.getContextPath() + "/profile");
    }
}
