<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"seller".equals(user.getRole())) {
        response.sendRedirect("login");
        return;
    }

    // Fetch only the current seller's products
    List<Product> products = new ArrayList<>();
    String productSql = "SELECT product_id, name, price, image, product_type, size, color, brand, stock_quantity FROM products WHERE seller_username = ? ORDER BY product_id DESC";
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(productSql)) {
        stmt.setString(1, user.getUsername());
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getDouble("price"));
                try {
                    String image = rs.getString("image");
                    p.setImage(image != null ? image : "");
                } catch (SQLException e) {
                    p.setImage("");
                }
                p.setProductType(rs.getString("product_type") != null ? rs.getString("product_type") : "");
                p.setSize(rs.getString("size") != null ? rs.getString("size") : "");
                p.setColor(rs.getString("color") != null ? rs.getString("color") : "");
                p.setBrand(rs.getString("brand") != null ? rs.getString("brand") : "");
                p.setStockQuantity(rs.getInt("stock_quantity"));
                products.add(p);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Shop - Clothing Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container { max-width: 1200px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; }
        .add-btn { padding: 14px 35px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; border-radius: 6px; }
        .add-btn { padding: 14px 35px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; border-radius: 6px; }
        .add-btn:hover { background: #333; }
        .products-section { margin-top: 0; }
        .products-table { background: #fff; border: 1px solid #eee; width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; }
        .products-table th { background: #f5f5f5; padding: 18px; text-align: left; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; border-bottom: 1px solid #eee; }
        .products-table td { padding: 18px; border-bottom: 1px solid #eee; }
        .products-table tbody tr { opacity: 0; animation: fadeInRow 0.5s ease-out forwards; transition: background 0.2s ease; }
        .products-table tbody tr:nth-child(1) { animation-delay: 0.1s; }
        .products-table tbody tr:nth-child(2) { animation-delay: 0.2s; }
        .products-table tbody tr:nth-child(3) { animation-delay: 0.3s; }
        .products-table tbody tr:nth-child(4) { animation-delay: 0.4s; }
        .products-table tbody tr:nth-child(5) { animation-delay: 0.5s; }
        @keyframes fadeInRow { from { opacity: 0; transform: translateX(-20px); } to { opacity: 1; transform: translateX(0); } }
        .products-table tbody tr:hover { background: #fafafa; }
        .products-table tr:last-child td { border-bottom: none; }
        .product-image-cell { width: 80px; height: 80px; background: #f5f5f5; display: flex; align-items: center; justify-content: center; font-size: 1.5em; color: #ddd; overflow: hidden; }
        .product-image-cell img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .edit-btn { padding: 10px 20px; background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; font-size: 0.75em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); text-decoration: none; display: inline-block; }
        .edit-btn:hover { background: #1a1a1a; color: #fff; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .delete-btn { padding: 10px 20px; background: transparent; color: #d32f2f; border: 1px solid #d32f2f; font-size: 0.75em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .delete-btn:hover { background: #d32f2f; color: #fff; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(211, 47, 47, 0.2); }
        .no-products { text-align: center; padding: 60px; color: #888; background: #fff; border: 1px solid #eee; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 80px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">CLOTHING STORE</a>
        <div class="nav-links">
            <a href="sellerDashboard">Dashboard</a>
            <a href="sellerShop.jsp">My Shop</a>
            <a href="products">View Store</a>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 50px;">
            <h1 style="margin-bottom: 0;">Product Inventory</h1>
            <a href="addProduct.jsp" class="add-btn" style="text-decoration: none; display: inline-block;">Add New Product</a>
        </div>
        <div class="products-section">
            <% if (products.isEmpty()) { %>
                <div class="no-products">
                    <p>No products yet. Add your first product above!</p>
                </div>
            <% } else { %>
                <table class="products-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Product Name</th>
                            <th>Type</th>
                            <th>Size</th>
                            <th>Color</th>
                            <th>Brand</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Links</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Product p : products) { %>
                            <tr>
                                <td>
                                    <div class="product-image-cell">
                                        <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                            <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                                        <% } else { %>
                                            ◇
                                        <% } %>
                                    </div>
                                </td>
                                <td><%= p.getName() %></td>
                                <td><%= p.getProductType() %></td>
                                <td><%= p.getSize() %></td>
                                <td><%= p.getColor() %></td>
                                <td><%= p.getBrand() %></td>
                                <td>$<%= String.format("%.2f", p.getPrice()) %></td>
                                <td><%= p.getStockQuantity() %></td>
                                <td><a href="product?id=<%= p.getId() %>" style="text-decoration:none; color:#1a1a1a;">View</a></td>
                                <td style="display:flex; gap:10px;">
                                    <a href="editProduct.jsp?id=<%= p.getId() %>" class="edit-btn">Edit</a>
                                    <form action="products" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= p.getId() %>">
                                        <button type="submit" class="delete-btn" onclick="return confirm('Delete this product?')">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
