<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"seller".equals(user.getRole())) {
        response.sendRedirect("login");
        return;
    }
    
    String productId = request.getParameter("id");
    if (productId == null || productId.isEmpty()) {
        response.sendRedirect("sellerShop.jsp");
        return;
    }
    
    Product product = null;
    String sql = "SELECT product_id, name, price, image, category, product_type, size, color, brand, material, stock_quantity, description, seller_username FROM products WHERE product_id = ? AND seller_username = ?";
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, Integer.parseInt(productId));
        stmt.setString(2, user.getUsername());
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                product = new Product();
                product.setId(rs.getInt("product_id"));
                product.setName(rs.getString("name"));
                product.setPrice(rs.getDouble("price"));
                product.setImage(rs.getString("image"));
                product.setCategory(rs.getString("category"));
                product.setProductType(rs.getString("product_type"));
                product.setSize(rs.getString("size"));
                product.setColor(rs.getString("color"));
                product.setBrand(rs.getString("brand"));
                product.setMaterial(rs.getString("material"));
                product.setStockQuantity(rs.getInt("stock_quantity"));
                product.setDescription(rs.getString("description"));
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    if (product == null) {
        response.sendRedirect("sellerShop.jsp");
        return;
    }
    
    String successMsg = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container { max-width: 900px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 15px; }
        .subtitle { color: #888; font-size: 1.05em; margin-bottom: 40px; }
        .success-message { background: #f0fff4; border: 1px solid #c6f6d5; color: #22543d; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; }
        .error-message { background: #fff5f5; border: 1px solid #ffcccc; color: #b00020; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; }
        .form-card { background: #fff; border: 1px solid #eee; padding: 40px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .form-section { margin-bottom: 30px; }
        .form-section h3 { font-family: 'Playfair Display', serif; font-size: 1.3em; font-weight: 400; letter-spacing: 1px; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee; }
        .form-row { display: grid; gap: 20px; margin-bottom: 20px; }
        .form-row.two-col { grid-template-columns: 1fr 1fr; }
        .form-row.three-col { grid-template-columns: 1fr 1fr 1fr; }
        .form-row.four-col { grid-template-columns: repeat(4, 1fr); }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 0.85em; font-weight: 600; letter-spacing: 0.5px; text-transform: uppercase; margin-bottom: 8px; color: #555; }
        .form-group input, .form-group textarea, .form-group select { padding: 14px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; border-radius: 6px; transition: border-color 0.2s; }
        .form-group input:focus, .form-group textarea:focus, .form-group select:focus { outline: none; border-color: #1a1a1a; }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-group small { color: #888; font-size: 0.85em; margin-top: 5px; }
        .button-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn { padding: 14px 35px; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.3s; border-radius: 6px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; border: none; }
        .btn-primary { background: #1a1a1a; color: #fff; }
        .btn-primary:hover { background: #333; }
        .btn-secondary { background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; }
        .btn-secondary:hover { background: #f5f5f5; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 80px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
        @media (max-width: 768px) {
            .navbar { padding: 15px 30px; flex-wrap: wrap; }
            .container { padding: 40px 20px; }
            h1 { font-size: 2em; }
            .form-card { padding: 30px 20px; }
            .form-row.two-col, .form-row.three-col, .form-row.four-col { grid-template-columns: 1fr; }
            .button-group { flex-direction: column; }
            .btn { width: 100%; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">DORMDEALZ</a>
        <div class="nav-links">
            <a href="sellerDashboard">Dashboard</a>
            <a href="sellerShop.jsp">My Shop</a>
            <a href="products">View Store</a>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="container">
        <h1>Edit Product</h1>
        <p class="subtitle">Update the details for "<%= product.getName() %>"</p>
        
        <% if (successMsg != null) { %>
            <div class="success-message"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="error-message"><%= errorMsg %></div>
        <% } %>

        <div class="form-card">
            <form action="products" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<%= product.getId() %>">
                
                <div class="form-section">
                    <h3>Basic Information</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="name">Product Name *</label>
                            <input type="text" id="name" name="name" value="<%= product.getName() != null ? product.getName() : "" %>" required>
                            <small>Give your product a clear, descriptive name</small>
                        </div>
                    </div>
                    <div class="form-row two-col">
                        <div class="form-group">
                            <label for="price">Price ($) *</label>
                            <input type="number" id="price" name="price" step="0.01" min="0" value="<%= product.getPrice() %>" required>
                            <small>Set the selling price</small>
                        </div>
                        <div class="form-group">
                            <label for="category">Category</label>
                            <select id="category" name="category">
                                <option value="">Select category</option>
                                <option value="Men" <%= "Men".equals(product.getCategory()) ? "selected" : "" %>>Men</option>
                                <option value="Women" <%= "Women".equals(product.getCategory()) ? "selected" : "" %>>Women</option>
                                <option value="Kids" <%= "Kids".equals(product.getCategory()) ? "selected" : "" %>>Kids</option>
                                <option value="Accessories" <%= "Accessories".equals(product.getCategory()) ? "selected" : "" %>>Accessories</option>
                                <option value="Shoes" <%= "Shoes".equals(product.getCategory()) ? "selected" : "" %>>Shoes</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h3>Product Details</h3>
                    <div class="form-row four-col">
                        <div class="form-group">
                            <label for="productType">Type</label>
                            <input type="text" id="productType" name="productType" value="<%= product.getProductType() != null ? product.getProductType() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="size">Size</label>
                            <input type="text" id="size" name="size" value="<%= product.getSize() != null ? product.getSize() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="color">Color</label>
                            <input type="text" id="color" name="color" value="<%= product.getColor() != null ? product.getColor() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="brand">Brand</label>
                            <input type="text" id="brand" name="brand" value="<%= product.getBrand() != null ? product.getBrand() : "" %>">
                        </div>
                    </div>
                    <div class="form-row two-col">
                        <div class="form-group">
                            <label for="material">Material</label>
                            <input type="text" id="material" name="material" value="<%= product.getMaterial() != null ? product.getMaterial() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="stock">Stock Quantity *</label>
                            <input type="number" id="stock" name="stock" min="0" value="<%= product.getStockQuantity() %>" required>
                            <small>Number of units available</small>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h3>Description & Media</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea id="description" name="description"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                            <small>Provide details about the product, its features, and benefits</small>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="image">Image URL</label>
                            <input type="url" id="image" name="image" value="<%= product.getImage() != null ? product.getImage() : "" %>">
                            <small>Provide a direct link to the product image</small>
                        </div>
                    </div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Update Product</button>
                    <a href="sellerShop.jsp" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">DORMDEALZ</div><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
