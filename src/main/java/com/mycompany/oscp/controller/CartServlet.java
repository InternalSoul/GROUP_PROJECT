package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import com.mycompany.oscp.model.*;

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

        // Always use the database (carts + cart_items + products) as the
        // source of truth so that items persist across logout/login.
        User user = (User) session.getAttribute("user");
        List<Product> cart = new ArrayList<>();

        if (user != null) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                // Find the latest cart for this user
                Integer cartId = null;
                try (PreparedStatement psCart = conn.prepareStatement(
                        "SELECT cart_id FROM carts WHERE customer_username = ? ORDER BY created_at DESC FETCH FIRST 1 ROW ONLY")) {
                    psCart.setString(1, user.getUsername());
                    try (ResultSet rsCart = psCart.executeQuery()) {
                        if (rsCart.next()) {
                            cartId = rsCart.getInt("cart_id");
                        }
                    }
                }

                if (cartId != null) {
                    // Load cart items and join products to get details
                    String sql = "SELECT ci.product_id, ci.quantity, p.name, p.price, p.image " +
                            "FROM cart_items ci " +
                            "JOIN products p ON ci.product_id = p.product_id " +
                            "WHERE ci.cart_id = ?";
                    try (PreparedStatement psItems = conn.prepareStatement(sql)) {
                        psItems.setInt(1, cartId);
                        try (ResultSet rs = psItems.executeQuery()) {
                            while (rs.next()) {
                                int pid = rs.getInt("product_id");
                                int qty = rs.getInt("quantity");
                                Product p = new Product();
                                p.setId(pid);
                                p.setName(rs.getString("name"));
                                p.setPrice(rs.getDouble("price"));
                                p.setImage(rs.getString("image") != null ? rs.getString("image") : "");
                                // Add one Product instance per quantity to match existing logic
                                for (int i = 0; i < qty; i++) {
                                    cart.add(p);
                                }
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                // If the DB fails for some reason, fall back to whatever is in
                // the session so the user still sees their current cart.
                @SuppressWarnings("unchecked")
                List<Product> sessionCart = (List<Product>) session.getAttribute("cart");
                if (sessionCart != null) {
                    cart.clear();
                    cart.addAll(sessionCart);
                }
                e.printStackTrace();
            }
        }

        // Mirror DB-backed cart into the session (even if empty) so the rest
        // of the app/header can read from the same source.
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
            String quantityParam = req.getParameter("quantity");
            int quantity = 1;
            try {
                if (quantityParam != null) {
                    quantity = Integer.parseInt(quantityParam);
                }
            } catch (NumberFormatException ignored) {
                quantity = 1;
            }
            if (quantity < 1) {
                quantity = 1;
            }
            String image = req.getParameter("image");
            String sellerUsername = req.getParameter("sellerUsername");

            // Add one Product instance per quantity to the in-memory cart to
            // keep existing logic simple (each entry is treated as 1 unit).
            for (int i = 0; i < quantity; i++) {
                Product product = new Product(id, name, price, image != null ? image : "");
                if (sellerUsername != null) {
                    product.setSellerUsername(sellerUsername);
                }
                cart.add(product);
            }

            // Also record cart item in database using carts/cart_items schema
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try (Connection conn = DatabaseConnection.getConnection()) {
                    // Find or create a cart for this user
                    Integer cartId = null;
                    try (PreparedStatement psCart = conn.prepareStatement(
                            "SELECT cart_id FROM carts WHERE customer_username = ? ORDER BY created_at DESC FETCH FIRST 1 ROW ONLY")) {
                        psCart.setString(1, user.getUsername());
                        try (ResultSet rsCart = psCart.executeQuery()) {
                            if (rsCart.next()) {
                                cartId = rsCart.getInt("cart_id");
                            }
                        }
                    }

                    if (cartId == null) {
                        try (PreparedStatement psNewCart = conn.prepareStatement(
                                "INSERT INTO carts (customer_username, created_at) VALUES (?, CURRENT_TIMESTAMP)",
                                Statement.RETURN_GENERATED_KEYS)) {
                            psNewCart.setString(1, user.getUsername());
                            psNewCart.executeUpdate();
                            try (ResultSet rsNew = psNewCart.getGeneratedKeys()) {
                                if (rsNew.next()) {
                                    cartId = rsNew.getInt(1);
                                }
                            }
                        }
                    }

                    if (cartId != null) {
                        // Insert or increment quantity in cart_items
                        // For simplicity, just insert a new row per add and
                        // let reads aggregate quantities.
                        try (PreparedStatement psItem = conn.prepareStatement(
                                "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?,?,?)")) {
                            psItem.setInt(1, cartId);
                            psItem.setInt(2, id);
                            psItem.setInt(3, quantity);
                            psItem.executeUpdate();
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            res.sendRedirect(req.getContextPath() + "/products");

        } else if ("remove".equals(action)) {
            // Remove item(s) from cart. When coming from the grouped cart view,
            // we remove all units of the given product id.
            String productIdParam = req.getParameter("productId");
            if (productIdParam != null && !productIdParam.isEmpty()) {
                int productId = Integer.parseInt(productIdParam);

                // Remove all matching items from the in-memory cart
                Iterator<Product> it = cart.iterator();
                while (it.hasNext()) {
                    Product p = it.next();
                    if (p.getId() == productId) {
                        it.remove();
                    }
                }

                // Remove all matching rows from cart_items table for this user's cart
                User user = (User) session.getAttribute("user");
                if (user != null) {
                    try (Connection conn = DatabaseConnection.getConnection()) {
                        Integer cartId = null;
                        try (PreparedStatement psCart = conn.prepareStatement(
                                "SELECT cart_id FROM carts WHERE customer_username = ? ORDER BY created_at DESC FETCH FIRST 1 ROW ONLY")) {
                            psCart.setString(1, user.getUsername());
                            try (ResultSet rsCart = psCart.executeQuery()) {
                                if (rsCart.next()) {
                                    cartId = rsCart.getInt("cart_id");
                                }
                            }
                        }

                        if (cartId != null) {
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?")) {
                                ps.setInt(1, cartId);
                                ps.setInt(2, productId);
                                ps.executeUpdate();
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            } else {
                // Backward-compatibility: remove by index if provided
                String indexParam = req.getParameter("index");
                if (indexParam != null && !indexParam.isEmpty()) {
                    int index = Integer.parseInt(indexParam);
                    if (index >= 0 && index < cart.size()) {
                        cart.remove(index);
                    }
                }
            }
            res.sendRedirect(req.getContextPath() + "/cart");

        } else if ("clear".equals(action)) {
            // Clear cart
            cart.clear();

            // Clear cart_items table for this user's cart
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try (Connection conn = DatabaseConnection.getConnection()) {
                    Integer cartId = null;
                    try (PreparedStatement psCart = conn.prepareStatement(
                            "SELECT cart_id FROM carts WHERE customer_username = ? ORDER BY created_at DESC FETCH FIRST 1 ROW ONLY")) {
                        psCart.setString(1, user.getUsername());
                        try (ResultSet rsCart = psCart.executeQuery()) {
                            if (rsCart.next()) {
                                cartId = rsCart.getInt("cart_id");
                            }
                        }
                    }

                    if (cartId != null) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "DELETE FROM cart_items WHERE cart_id = ?")) {
                            ps.setInt(1, cartId);
                            ps.executeUpdate();
                        }
                    }
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

            // Also record cart item in database using carts/cart_items schema
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try (Connection conn = DatabaseConnection.getConnection()) {
                    Integer cartId = null;
                    try (PreparedStatement psCart = conn.prepareStatement(
                            "SELECT cart_id FROM carts WHERE customer_username = ? ORDER BY created_at DESC FETCH FIRST 1 ROW ONLY")) {
                        psCart.setString(1, user.getUsername());
                        try (ResultSet rsCart = psCart.executeQuery()) {
                            if (rsCart.next()) {
                                cartId = rsCart.getInt("cart_id");
                            }
                        }
                    }

                    if (cartId == null) {
                        try (PreparedStatement psNewCart = conn.prepareStatement(
                                "INSERT INTO carts (customer_username, created_at) VALUES (?, CURRENT_TIMESTAMP)",
                                Statement.RETURN_GENERATED_KEYS)) {
                            psNewCart.setString(1, user.getUsername());
                            psNewCart.executeUpdate();
                            try (ResultSet rsNew = psNewCart.getGeneratedKeys()) {
                                if (rsNew.next()) {
                                    cartId = rsNew.getInt(1);
                                }
                            }
                        }
                    }

                    if (cartId != null) {
                        try (PreparedStatement psItem = conn.prepareStatement(
                                "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?,?,1)")) {
                            psItem.setInt(1, cartId);
                            psItem.setInt(2, id);
                            psItem.executeUpdate();
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            res.sendRedirect(req.getContextPath() + "/products");
        }
    }
}
