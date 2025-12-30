package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.*;
import java.util.Base64;
import com.mycompany.oscp.model.*;

@WebServlet("/products")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 10, // 10 MB
        maxRequestSize = 1024 * 1024 * 50 // 50 MB
)
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
        String sortParam = req.getParameter("sort");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql;
            PreparedStatement stmt;

            // Determine ORDER BY clause based on sort parameter
            String orderByClause = "";
            if ("priceAsc".equals(sortParam)) {
                orderByClause = " ORDER BY PRICE ASC";
            } else if ("priceDesc".equals(sortParam)) {
                orderByClause = " ORDER BY PRICE DESC";
            } else if ("nameAsc".equals(sortParam)) {
                orderByClause = " ORDER BY NAME ASC";
            } else if ("nameDesc".equals(sortParam)) {
                orderByClause = " ORDER BY NAME DESC";
            }

            // Search functionality
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                sql = "SELECT * FROM PRODUCTS WHERE UPPER(NAME) LIKE UPPER(?)" + orderByClause;
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, "%" + searchQuery + "%");
            } else {
                sql = "SELECT * FROM PRODUCTS" + orderByClause;
                stmt = conn.prepareStatement(sql);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("PRODUCT_ID"));
                    p.setName(rs.getString("NAME"));
                    p.setPrice(rs.getDouble("PRICE"));
                    // Handle IMAGE column as BLOB
                    try {
                        Blob imageBlob = rs.getBlob("IMAGE");
                        if (imageBlob != null && imageBlob.length() > 0) {
                            byte[] imageBytes = imageBlob.getBytes(1, (int) imageBlob.length());
                            String base64Image = "data:image/jpeg;base64,"
                                    + Base64.getEncoder().encodeToString(imageBytes);
                            p.setImage(base64Image);
                        } else {
                            p.setImage("");
                        }
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

        System.out.println("=== ProductsServlet doPost called ===");
        System.out.println("Content-Type: " + req.getContentType());

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = req.getParameter("action");
        System.out.println("Action parameter: " + action);
        System.out.println("User role: " + user.getRole());

        // Only sellers can add/delete products
        if (!"seller".equalsIgnoreCase(user.getRole())) {
            System.out.println("User is not a seller, redirecting...");
            res.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        String errorMsg = null;

        try (Connection conn = DatabaseConnection.getConnection()) {
            System.out.println("Database connection successful");

            if ("delete".equals(action)) {
                String idParam = req.getParameter("id");
                if (idParam != null && !idParam.isEmpty()) {
                    int id = Integer.parseInt(idParam);
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM PRODUCTS WHERE PRODUCT_ID = ?")) {
                        ps.setInt(1, id);
                        int rows = ps.executeUpdate();
                        System.out.println("Deleted " + rows + " product(s) with ID: " + id);
                    }
                }
            } else if ("add".equals(action)) {
                String name = req.getParameter("name");
                String priceParam = req.getParameter("price");
                System.out.println("Adding product - Name: " + name + ", Price: " + priceParam);

                // Handle file upload as BLOB
                byte[] imageBytes = null;
                try {
                    Part filePart = req.getPart("image");
                    if (filePart != null && filePart.getSize() > 0) {
                        try (InputStream fileContent = filePart.getInputStream()) {
                            imageBytes = fileContent.readAllBytes();
                            System.out.println("Image read: " + imageBytes.length + " bytes");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("File upload error: " + e.getMessage());
                    e.printStackTrace();
                    // Continue without image
                }

                if (name != null && !name.trim().isEmpty() && priceParam != null && !priceParam.isEmpty()) {
                    double price = Double.parseDouble(priceParam);
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO PRODUCTS (NAME, PRICE, IMAGE) VALUES (?, ?, ?)")) {
                        ps.setString(1, name.trim());
                        ps.setDouble(2, price);
                        if (imageBytes != null) {
                            ps.setBytes(3, imageBytes);
                        } else {
                            ps.setNull(3, Types.BLOB);
                        }
                        int rows = ps.executeUpdate();
                        System.out
                                .println("Added product: " + name + " (Price: " + price + ") - Rows affected: " + rows);
                    }
                } else {
                    errorMsg = "Product name and price are required";
                    System.err.println(errorMsg);
                }
            }
        } catch (SQLException e) {
            errorMsg = "Database error: " + e.getMessage();
            System.err.println(errorMsg);
            e.printStackTrace();
        } catch (NumberFormatException e) {
            errorMsg = "Invalid number format: " + e.getMessage();
            System.err.println(errorMsg);
            e.printStackTrace();
        }

        // Redirect sellers back to their shop management page
        res.sendRedirect(req.getContextPath() + "/sellerShop.jsp");
    }
}
