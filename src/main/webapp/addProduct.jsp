<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"seller".equals(user.getRole())) {
        response.sendRedirect("login");
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
    <title>Add Product - Clothing Store</title>
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
        <a href="index.jsp" class="logo">CLOTHING STORE</a>
        <div class="nav-links">
            <a href="sellerDashboard">Dashboard</a>
            <a href="sellerShop.jsp">My Shop</a>
            <a href="products">View Store</a>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="container">
        <h1>Add New Product</h1>
        <p class="subtitle">Fill in the details below to list a new product in your shop.</p>
        
        <% if (successMsg != null) { %>
            <div class="success-message"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="error-message"><%= errorMsg %></div>
        <% } %>

        <div class="form-card">
            <form action="products" method="post">
                <input type="hidden" name="action" value="add">
                
                <div class="form-section">
                    <h3>Basic Information</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="name">Product Name *</label>
                            <input type="text" id="name" name="name" placeholder="Enter product name" required>
                            <small>Give your product a clear, descriptive name</small>
                        </div>
                    </div>
                    <div class="form-row two-col">
                        <div class="form-group">
                            <label for="price">Price ($) *</label>
                            <input type="number" id="price" name="price" step="0.01" min="0" placeholder="0.00" required>
                            <small>Set the selling price</small>
                        </div>
                        <div class="form-group">
                            <label for="category">Category</label>
                            <select id="category" name="category">
                                <option value="">Select category</option>
                                <option value="Men">Men</option>
                                <option value="Women">Women</option>
                                <option value="Kids">Kids</option>
                                <option value="Accessories">Accessories</option>
                                <option value="Shoes">Shoes</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h3>Product Details</h3>
                    <div class="form-row four-col">
                        <div class="form-group">
                            <label for="productType">Type</label>
                            <input type="text" id="productType" name="productType" placeholder="e.g., T-Shirt, Dress">
                        </div>
                        <div class="form-group">
                            <label for="size">Size</label>
                            <input type="text" id="size" name="size" placeholder="e.g., S, M, L, XL">
                        </div>
                        <div class="form-group">
                            <label for="color">Color</label>
                            <input type="text" id="color" name="color" placeholder="e.g., Black, White">
                        </div>
                        <div class="form-group">
                            <label for="brand">Brand</label>
                            <input type="text" id="brand" name="brand" placeholder="e.g., Nike, Adidas">
                        </div>
                    </div>
                    <div class="form-row two-col">
                        <div class="form-group">
                            <label for="material">Material</label>
                            <input type="text" id="material" name="material" placeholder="e.g., Cotton, Polyester">
                        </div>
                        <div class="form-group">
                            <label for="stock">Stock Quantity *</label>
                            <input type="number" id="stock" name="stock" min="0" placeholder="0" value="0" required>
                            <small>Number of units available</small>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h3>Description & Media</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea id="description" name="description" placeholder="Describe your product..."></textarea>
                            <small>Provide details about the product, its features, and benefits</small>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="image">Image URL</label>
                            <input type="url" id="image" name="image" placeholder="https://example.com/image.jpg">
                            <small>Provide a direct link to the product image</small>
                        </div>
                    </div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Add Product</button>
                    <a href="sellerShop.jsp" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
