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
    String productSql = "SELECT product_id, name, price, image, product_type, size, color, brand FROM products WHERE seller_username = ? ORDER BY product_id DESC";
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
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 50px; }
        .add-product-box { background: #fff; border: 1px solid #eee; padding: 40px; margin-bottom: 50px; }
        .add-product-box h2 { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 400; letter-spacing: 1px; margin-bottom: 30px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr auto; gap: 15px; align-items: end; }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 0.8em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 8px; }
        .form-group input { padding: 14px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; }
        .form-group input:focus { outline: none; border-color: #1a1a1a; }
        .add-btn { padding: 14px 35px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .add-btn:hover { background: #333; }
        .products-section h2 { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 400; letter-spacing: 1px; margin-bottom: 30px; }
        .products-table { background: #fff; border: 1px solid #eee; width: 100%; border-collapse: collapse; }
        .products-table th { background: #f5f5f5; padding: 18px; text-align: left; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; border-bottom: 1px solid #eee; }
        .products-table td { padding: 18px; border-bottom: 1px solid #eee; }
        .products-table tr:last-child td { border-bottom: none; }
        .product-image-cell { width: 80px; height: 80px; background: #f5f5f5; display: flex; align-items: center; justify-content: center; font-size: 1.5em; color: #ddd; overflow: hidden; }
        .product-image-cell img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .delete-btn { padding: 10px 20px; background: transparent; color: #d32f2f; border: 1px solid #d32f2f; font-size: 0.75em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.3s; }
        .delete-btn:hover { background: #d32f2f; color: #fff; }
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
            <a href="sellerDashboard.jsp">Dashboard</a>
            <a href="sellerShop.jsp">My Shop</a>
            <a href="products">View Store</a>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="container">
        <h1>Manage Products</h1>
        <div class="add-product-box">
            <h2>Add New Product</h2>
            <form action="products" method="post">
                <input type="hidden" name="action" value="add">
                <div class="form-row">
                    <div class="form-group">
                        <label for="name">Product Name</label>
                        <input type="text" id="name" name="name" placeholder="Enter product name" required>
                    </div>
                    <div class="form-group">
                        <label for="price">Price ($)</label>
                        <input type="number" id="price" name="price" step="0.01" min="0" placeholder="0.00" required>
                    </div>
                    <div class="form-group">
                        <label for="image">Image URL</label>
                        <input type="url" id="image" name="image" placeholder="https://..." aria-label="Image URL">
                    </div>
                </div>
                <div class="form-row" style="margin-top:15px; grid-template-columns: repeat(4, 1fr);">
                    <div class="form-group">
                        <label for="category">Category</label>
                        <input type="text" id="category" name="category" placeholder="e.g. Women" aria-label="Category">
                    </div>
                    <div class="form-group">
                        <label for="productType">Type</label>
                        <input type="text" id="productType" name="productType" placeholder="e.g. Dress" aria-label="Product type">
                    </div>
                    <div class="form-group">
                        <label for="size">Size</label>
                        <input type="text" id="size" name="size" placeholder="e.g. M" aria-label="Size">
                    </div>
                    <div class="form-group">
                        <label for="color">Color</label>
                        <input type="text" id="color" name="color" placeholder="e.g. Black" aria-label="Color">
                    </div>
                </div>
                <div class="form-row" style="margin-top:15px; grid-template-columns: repeat(4, 1fr);">
                    <div class="form-group">
                        <label for="brand">Brand</label>
                        <input type="text" id="brand" name="brand" placeholder="e.g. Maison" aria-label="Brand">
                    </div>
                    <div class="form-group" style="grid-column: span 3;">
                        <label>&nbsp;</label>
                        <button type="submit" class="add-btn" style="width:100%;">Add Product</button>
                    </div>
                </div>
            </form>
        </div>
        <div class="products-section">
            <h2>Product Inventory</h2>
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
                            <th>Links</th>
                            <th>Action</th>
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
                                <td><a href="product?id=<%= p.getId() %>" style="text-decoration:none; color:#1a1a1a;">View</a></td>
                                <td>
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
