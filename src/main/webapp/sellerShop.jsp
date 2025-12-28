<%@ page import="java.util.*, java.sql.*, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"seller".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login");
        return;
    }
    
    // Fetch products from database
    List<Product> products = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = "SELECT * FROM PRODUCTS";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("PRODUCT_ID"));
                p.setName(rs.getString("NAME"));
                p.setPrice(rs.getDouble("PRICE"));
                try {
                    p.setImage(rs.getString("IMAGE"));
                } catch (SQLException e) {
                    p.setImage("");
                }
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
    <title>My Products - OCSP</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: #fafafa;
            color: #1a1a1a;
            min-height: 100vh;
        }
        .top-bar {
            background: #1a1a1a;
            color: #fff;
            text-align: center;
            padding: 10px;
            font-size: 12px;
            letter-spacing: 1px;
            text-transform: uppercase;
        }
        .navbar {
            background: #fff;
            padding: 20px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
        }
        .navbar .logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.8em;
            font-weight: 700;
            color: #1a1a1a;
            text-decoration: none;
            letter-spacing: 2px;
        }
        .navbar .nav-links {
            display: flex;
            gap: 35px;
            align-items: center;
        }
        .navbar a {
            color: #1a1a1a;
            text-decoration: none;
            font-size: 13px;
            letter-spacing: 1px;
            text-transform: uppercase;
            transition: opacity 0.3s;
        }
        .navbar a:hover {
            opacity: 0.6;
        }
        .navbar .user-info {
            font-size: 13px;
            color: #666;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 50px 30px;
        }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 50px;
        }
        .page-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.5em;
            font-weight: 400;
            letter-spacing: 2px;
        }
        .product-count {
            color: #888;
            font-size: 14px;
            letter-spacing: 1px;
        }
        .section-card {
            background: #fff;
            border: 1px solid #eee;
            padding: 40px;
            margin-bottom: 30px;
        }
        .section-card h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.5em;
            font-weight: 400;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .add-product-form {
            display: grid;
            grid-template-columns: 2fr 1fr 2fr auto;
            gap: 20px;
            align-items: end;
        }
        .form-group {
            display: flex;
            flex-direction: column;
        }
        .form-group label {
            margin-bottom: 10px;
            font-size: 12px;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: #666;
        }
        .form-group input {
            padding: 15px;
            border: 1px solid #ddd;
            font-size: 14px;
            font-family: 'Inter', sans-serif;
            transition: border-color 0.3s;
        }
        .form-group input:focus {
            outline: none;
            border-color: #1a1a1a;
        }
        .form-group input::placeholder {
            color: #aaa;
        }
        .btn {
            padding: 15px 30px;
            border: none;
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 2px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        .btn-primary {
            background: #1a1a1a;
            color: #fff;
        }
        .btn-primary:hover {
            background: #333;
        }
        .btn-danger {
            background: #fff;
            color: #c00;
            border: 1px solid #c00;
            padding: 10px 20px;
            font-size: 11px;
        }
        .btn-danger:hover {
            background: #c00;
            color: #fff;
        }
        .products-table {
            width: 100%;
            border-collapse: collapse;
        }
        .products-table th,
        .products-table td {
            padding: 20px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        .products-table th {
            font-size: 11px;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: #888;
            font-weight: 500;
            background: #fafafa;
        }
        .products-table tr:hover {
            background: #fafafa;
        }
        .product-name {
            font-weight: 500;
            color: #1a1a1a;
        }
        .product-price {
            font-family: 'Playfair Display', serif;
            font-size: 1.1em;
        }
        .product-image {
            width: 60px;
            height: 60px;
            object-fit: cover;
            background: #f5f5f5;
        }
        .empty-state {
            text-align: center;
            padding: 60px;
            color: #666;
        }
        .empty-state-icon {
            font-size: 3em;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        .empty-state h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.5em;
            font-weight: 400;
            margin-bottom: 10px;
            color: #1a1a1a;
        }
        .empty-state p {
            font-size: 14px;
            color: #888;
        }
        .footer {
            background: #1a1a1a;
            color: #fff;
            padding: 50px;
            text-align: center;
            margin-top: 50px;
        }
        .footer-logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.5em;
            letter-spacing: 3px;
            margin-bottom: 20px;
        }
        .footer p {
            font-size: 12px;
            color: #888;
            letter-spacing: 1px;
        }
        @media (max-width: 768px) {
            .add-product-form {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="top-bar">
        Product Management — Add, Edit, Remove Products
    </div>

    <nav class="navbar">
        <a href="index.jsp" class="logo">OCSP</a>
        <div class="nav-links">
            <a href="sellerDashboard.jsp">Dashboard</a>
            <a href="sellerShop.jsp">My Products</a>
            <a href="products">View Store</a>
            <span class="user-info"><%= user.getUsername() %></span>
            <a href="logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h1>My Products</h1>
            <span class="product-count"><%= products.size() %> Products</span>
        </div>

        <div class="section-card">
            <h2>Add New Product</h2>
            <form action="products" method="post" class="add-product-form">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label for="name">Product Name</label>
                    <input type="text" id="name" name="name" placeholder="e.g., Cotton T-Shirt" required>
                </div>
                <div class="form-group">
                    <label for="price">Price (RM)</label>
                    <input type="number" id="price" name="price" step="0.01" min="0" placeholder="49.90" required>
                </div>
                <div class="form-group">
                    <label for="image">Image URL</label>
                    <input type="text" id="image" name="image" placeholder="https://...">
                </div>
                <button type="submit" class="btn btn-primary">Add Product</button>
            </form>
        </div>

        <div class="section-card">
            <h2>Product Inventory</h2>
            
            <% if (products.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">📦</div>
                    <h3>No Products Yet</h3>
                    <p>Add your first product using the form above.</p>
                </div>
            <% } else { %>
                <table class="products-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Product Name</th>
                            <th>Price</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Product p : products) { %>
                            <tr>
                                <td>
                                    <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                        <img src="<%= p.getImage() %>" alt="<%= p.getName() %>" class="product-image">
                                    <% } else { %>
                                        <div class="product-image" style="display: flex; align-items: center; justify-content: center; color: #aaa;">📷</div>
                                    <% } %>
                                </td>
                                <td class="product-name"><%= p.getName() %></td>
                                <td class="product-price">RM <%= String.format("%.2f", p.getPrice()) %></td>
                                <td>
                                    <form action="products" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="productId" value="<%= p.getId() %>">
                                        <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this product?')">Remove</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-logo">OCSP</div>
        <p>© 2024 Online Clothing Shopping Platform. All Rights Reserved.</p>
    </footer>
</body>
</html>
