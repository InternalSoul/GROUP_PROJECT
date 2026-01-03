package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.Product;
import model.User;
import model.DatabaseConnection;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Load cart items from cart_items table for this user
        User user = (User) session.getAttribute("user");
        List<Product> cart = new ArrayList<>();
        if (user != null) {
            try (Connection conn = DatabaseConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement(
                            "SELECT product_id, product_name, price, image FROM cart_items WHERE user_username = ? ORDER BY created_at ASC")) {
                ps.setString(1, user.getUsername());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Product p = new Product();
                        p.setId(rs.getInt("product_id"));
                        p.setName(rs.getString("product_name"));
                        p.setPrice(rs.getDouble("price"));
                        p.setImage(rs.getString("image"));
                        cart.add(p);
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Keep session cart in sync with DB-backed cart
        session.setAttribute("cart", cart);

        req.getRequestDispatcher("/cart.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        if (session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        @SuppressWarnings("unchecked")
        List<Product> cart = (List<Product>) session.getAttribute("cart");

        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        if ("add".equals(action)) {
            // Add item to cart
            String name = req.getParameter("name");
            double price = Double.parseDouble(req.getParameter("price"));
            int id = Integer.parseInt(req.getParameter("id"));
            String image = req.getParameter("image");

            Product product = new Product(id, name, price, image != null ? image : "");
            cart.add(product);

            // Also record cart item in database
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try (Connection conn = DatabaseConnection.getConnection();
                        PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO cart_items (user_username, product_id, product_name, price, image, quantity, created_at) "
                                        +
                                        "VALUES (?,?,?,?,?,1,NOW())")) {
                    ps.setString(1, user.getUsername());
                    ps.setInt(2, id);
                    ps.setString(3, name);
                    ps.setDouble(4, price);
                    ps.setString(5, image != null ? image : "");
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            res.sendRedirect(req.getContextPath() + "/products");

        } else if ("remove".equals(action)) {
            // Remove item from cart
            int index = Integer.parseInt(req.getParameter("index"));
            if (index >= 0 && index < cart.size()) {
                Product removed = cart.remove(index);

                // Also remove from cart_items table
                User user = (User) session.getAttribute("user");
                if (user != null && removed != null) {
                    try (Connection conn = DatabaseConnection.getConnection();
                            PreparedStatement ps = conn.prepareStatement(
                                    "DELETE FROM cart_items WHERE user_username = ? AND product_id = ? LIMIT 1")) {
                        ps.setString(1, user.getUsername());
                        ps.setInt(2, removed.getId());
                        ps.executeUpdate();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
            res.sendRedirect(req.getContextPath() + "/cart");

        } else if ("clear".equals(action)) {
            // Clear cart
            cart.clear();

            // Clear cart_items table for this user
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try (Connection conn = DatabaseConnection.getConnection();
                        PreparedStatement ps = conn.prepareStatement(
                                "DELETE FROM cart_items WHERE user_username = ?")) {
                    ps.setString(1, user.getUsername());
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            res.sendRedirect(req.getContextPath() + "/cart");

        } else {
            // Default: add to cart (for backward compatibility)
            String name = req.getParameter("name");
            double price = Double.parseDouble(req.getParameter("price"));
            int id = Integer.parseInt(req.getParameter("id"));

            cart.add(new Product(id, name, price));

            // Also record cart item in database
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try (Connection conn = DatabaseConnection.getConnection();
                        PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO cart_items (user_username, product_id, product_name, price, quantity, created_at) "
                                        +
                                        "VALUES (?,?,?,?,1,NOW())")) {
                    ps.setString(1, user.getUsername());
                    ps.setInt(2, id);
                    ps.setString(3, name);
                    ps.setDouble(4, price);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            res.sendRedirect(req.getContextPath() + "/products");
        }
    }
}
