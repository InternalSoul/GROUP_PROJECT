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

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<Product> products = new ArrayList<>();
        String searchQuery = req.getParameter("search");
        String sortParam = req.getParameter("sort");
        String productType = req.getParameter("productType");
        String size = req.getParameter("size");
        String color = req.getParameter("color");
        String brand = req.getParameter("brand");
        String priceRange = req.getParameter("priceRange");

        Set<String> productTypes = new HashSet<>();
        Set<String> sizes = new HashSet<>();
        Set<String> colors = new HashSet<>();
        Set<String> brands = new HashSet<>();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Get distinct filter values
            try (Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(
                            "SELECT DISTINCT product_type FROM products WHERE product_type IS NOT NULL ORDER BY product_type")) {
                while (rs.next()) {
                    String val = rs.getString("product_type");
                    if (val != null && !val.isEmpty())
                        productTypes.add(val);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            try (Statement stmt = conn.createStatement();
                    ResultSet rs = stmt
                            .executeQuery("SELECT DISTINCT size FROM products WHERE size IS NOT NULL ORDER BY size")) {
                while (rs.next()) {
                    String val = rs.getString("size");
                    if (val != null && !val.isEmpty())
                        sizes.add(val);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            try (Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(
                            "SELECT DISTINCT color FROM products WHERE color IS NOT NULL ORDER BY color")) {
                while (rs.next()) {
                    String val = rs.getString("color");
                    if (val != null && !val.isEmpty())
                        colors.add(val);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            try (Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(
                            "SELECT DISTINCT brand FROM products WHERE brand IS NOT NULL ORDER BY brand")) {
                while (rs.next()) {
                    String val = rs.getString("brand");
                    if (val != null && !val.isEmpty())
                        brands.add(val);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            // Build WHERE clause
            StringBuilder whereClause = new StringBuilder("WHERE 1=1");
            List<Object> params = new ArrayList<>();

            // Filter out products with no stock
            whereClause.append(" AND in_stock = TRUE AND stock_quantity > 0");

            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                whereClause.append(" AND (LOWER(name) LIKE LOWER(?) OR LOWER(category) LIKE LOWER(?))");
                params.add("%" + searchQuery + "%");
                params.add("%" + searchQuery + "%");
            }

            if (productType != null && !productType.trim().isEmpty()) {
                whereClause.append(" AND product_type = ?");
                params.add(productType);
            }

            if (size != null && !size.trim().isEmpty()) {
                whereClause.append(" AND size = ?");
                params.add(size);
            }

            if (color != null && !color.trim().isEmpty()) {
                whereClause.append(" AND color = ?");
                params.add(color);
            }

            if (brand != null && !brand.trim().isEmpty()) {
                whereClause.append(" AND brand = ?");
                params.add(brand);
            }

            if (priceRange != null && !priceRange.isEmpty()) {
                switch (priceRange) {
                    case "0-50":
                        whereClause.append(" AND price BETWEEN 0 AND 50");
                        break;
                    case "50-100":
                        whereClause.append(" AND price BETWEEN 50 AND 100");
                        break;
                    case "100-200":
                        whereClause.append(" AND price BETWEEN 100 AND 200");
                        break;
                    case "200":
                        whereClause.append(" AND price > 200");
                        break;
                }
            }

            // Determine ORDER BY clause
            String orderByClause = "";
            if ("priceAsc".equals(sortParam)) {
                orderByClause = " ORDER BY price ASC";
            } else if ("priceDesc".equals(sortParam)) {
                orderByClause = " ORDER BY price DESC";
            } else if ("nameAsc".equals(sortParam)) {
                orderByClause = " ORDER BY name ASC";
            } else if ("nameDesc".equals(sortParam)) {
                orderByClause = " ORDER BY name DESC";
            } else {
                orderByClause = " ORDER BY name ASC";
            }

            String sql = "SELECT product_id, name, price, image, seller_username, category, product_type, size, color, brand, material, rating, in_stock, stock_quantity FROM products "
                    + whereClause.toString() + orderByClause;

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (int i = 0; i < params.size(); i++) {
                    stmt.setString(i + 1, params.get(i).toString());
                }

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Product p = new Product();
                        p.setId(rs.getInt("product_id"));
                        p.setName(rs.getString("name"));
                        p.setPrice(rs.getDouble("price"));
                        p.setImage(rs.getString("image") != null ? rs.getString("image") : "");
                        p.setCategory(rs.getString("category") != null ? rs.getString("category") : "");
                        p.setSellerUsername(
                                rs.getString("seller_username") != null ? rs.getString("seller_username") : "");
                        p.setProductType(rs.getString("product_type") != null ? rs.getString("product_type") : "");
                        p.setSize(rs.getString("size") != null ? rs.getString("size") : "");
                        p.setColor(rs.getString("color") != null ? rs.getString("color") : "");
                        p.setBrand(rs.getString("brand") != null ? rs.getString("brand") : "");
                        p.setMaterial(rs.getString("material") != null ? rs.getString("material") : "");
                        p.setRating(rs.getDouble("rating"));
                        p.setInStock(rs.getBoolean("in_stock"));
                        products.add(p);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load products: " + e.getMessage());
        }

        req.setAttribute("products", products);
        req.setAttribute("productTypes", productTypes);
        req.setAttribute("sizes", sizes);
        req.setAttribute("colors", colors);
        req.setAttribute("brands", brands);
        req.setAttribute("searchQuery", searchQuery != null ? searchQuery : "");
        req.setAttribute("sortParam", sortParam != null ? sortParam : "");
        req.setAttribute("selectedProductType", productType != null ? productType : "");
        req.setAttribute("selectedSize", size != null ? size : "");
        req.setAttribute("selectedColor", color != null ? color : "");
        req.setAttribute("selectedBrand", brand != null ? brand : "");
        req.setAttribute("selectedPriceRange", priceRange != null ? priceRange : "");

        req.getRequestDispatcher("/products.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || (!"seller".equals(user.getRole()) && !"admin".equals(user.getRole()))) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null || action.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/sellerShop.jsp");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            if ("add".equalsIgnoreCase(action)) {
                String name = req.getParameter("name");
                String priceStr = req.getParameter("price");
                String image = req.getParameter("image");
                String category = req.getParameter("category");
                String productType = req.getParameter("productType");
                String size = req.getParameter("size");
                String color = req.getParameter("color");
                String brand = req.getParameter("brand");

                double price = 0.0;
                try {
                    price = Double.parseDouble(priceStr);
                } catch (NumberFormatException ignored) {
                    price = 0.0;
                }

                String insertSql = "INSERT INTO products (name, price, image, seller_username, category, product_type, size, color, brand) "
                        + "VALUES (?,?,?,?,?,?,?,?,?)";
                try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                    stmt.setString(1, name != null ? name : "");
                    stmt.setDouble(2, price);
                    stmt.setString(3, image != null ? image : "");
                    stmt.setString(4, user.getUsername());
                    stmt.setString(5, category != null ? category : "");
                    stmt.setString(6, productType != null ? productType : "");
                    stmt.setString(7, size != null ? size : "");
                    stmt.setString(8, color != null ? color : "");
                    stmt.setString(9, brand != null ? brand : "");
                    stmt.executeUpdate();
                }
            } else if ("update".equalsIgnoreCase(action)) {
                String idParam = req.getParameter("id");
                String name = req.getParameter("name");
                String priceStr = req.getParameter("price");
                String image = req.getParameter("image");
                String category = req.getParameter("category");
                String productType = req.getParameter("productType");
                String size = req.getParameter("size");
                String color = req.getParameter("color");
                String brand = req.getParameter("brand");
                String material = req.getParameter("material");
                String stockStr = req.getParameter("stock");
                String description = req.getParameter("description");

                int productId = 0;
                double price = 0.0;
                int stock = 0;
                
                try {
                    productId = Integer.parseInt(idParam);
                    price = Double.parseDouble(priceStr);
                    stock = Integer.parseInt(stockStr);
                } catch (NumberFormatException ignored) {
                }

                String updateSql = "UPDATE products SET name=?, price=?, image=?, category=?, product_type=?, size=?, color=?, brand=?, material=?, stock_quantity=?, description=? WHERE product_id=? AND seller_username=?";
                try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                    stmt.setString(1, name != null ? name : "");
                    stmt.setDouble(2, price);
                    stmt.setString(3, image != null ? image : "");
                    stmt.setString(4, category != null ? category : "");
                    stmt.setString(5, productType != null ? productType : "");
                    stmt.setString(6, size != null ? size : "");
                    stmt.setString(7, color != null ? color : "");
                    stmt.setString(8, brand != null ? brand : "");
                    stmt.setString(9, material != null ? material : "");
                    stmt.setInt(10, stock);
                    stmt.setString(11, description != null ? description : "");
                    stmt.setInt(12, productId);
                    stmt.setString(13, user.getUsername());
                    stmt.executeUpdate();
                }
            } else if ("delete".equalsIgnoreCase(action)) {
                String idParam = req.getParameter("id");
                int productId = 0;
                try {
                    productId = Integer.parseInt(idParam);
                } catch (NumberFormatException ignored) {
                    productId = 0;
                }

                String deleteSql = "DELETE FROM products WHERE product_id = ? AND seller_username = ?";
                try (PreparedStatement stmt = conn.prepareStatement(deleteSql)) {
                    stmt.setInt(1, productId);
                    stmt.setString(2, user.getUsername());
                    stmt.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        res.sendRedirect(req.getContextPath() + "/sellerShop.jsp");
    }
}
