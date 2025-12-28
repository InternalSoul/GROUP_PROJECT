<%@ page import="java.util.*, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    if (!"seller".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("products");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard - OCSP</title>
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
            max-width: 1100px;
            margin: 0 auto;
            padding: 50px 30px;
        }
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 50px;
        }
        .dashboard-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.5em;
            font-weight: 400;
            letter-spacing: 2px;
        }
        .seller-badge {
            background: #1a1a1a;
            color: #fff;
            padding: 10px 25px;
            font-size: 11px;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
            margin-bottom: 50px;
        }
        .stat-card {
            background: #fff;
            border: 1px solid #eee;
            padding: 35px;
            text-align: center;
        }
        .stat-icon {
            font-size: 2em;
            margin-bottom: 15px;
            opacity: 0.8;
        }
        .stat-value {
            font-family: 'Playfair Display', serif;
            font-size: 2.5em;
            color: #1a1a1a;
            margin-bottom: 8px;
        }
        .stat-label {
            color: #888;
            font-size: 12px;
            letter-spacing: 1px;
            text-transform: uppercase;
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
            grid-template-columns: 1fr 1fr 1fr auto;
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
        }
        .btn-primary {
            background: #1a1a1a;
            color: #fff;
        }
        .btn-primary:hover {
            background: #333;
        }
        .quick-links {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        .quick-link {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 25px;
            background: #fafafa;
            border: 1px solid #eee;
            text-decoration: none;
            color: #1a1a1a;
            transition: all 0.3s;
        }
        .quick-link:hover {
            background: #1a1a1a;
            color: #fff;
            border-color: #1a1a1a;
        }
        .quick-link span {
            font-size: 13px;
            letter-spacing: 1px;
            text-transform: uppercase;
        }
        .quick-link .arrow {
            font-size: 1.2em;
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
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .add-product-form {
                grid-template-columns: 1fr;
            }
            .quick-links {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="top-bar">
        Seller Dashboard — Manage Your Store
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
        <div class="dashboard-header">
            <h1>Dashboard</h1>
            <span class="seller-badge">Seller Account</span>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">📦</div>
                <div class="stat-value">—</div>
                <div class="stat-label">Total Products</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">🛒</div>
                <div class="stat-value">—</div>
                <div class="stat-label">Total Orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">💰</div>
                <div class="stat-value">—</div>
                <div class="stat-label">Total Revenue</div>
            </div>
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
                    <input type="number" id="price" name="price" step="0.01" min="0" placeholder="e.g., 49.90" required>
                </div>
                <div class="form-group">
                    <label for="image">Image URL</label>
                    <input type="text" id="image" name="image" placeholder="Optional image URL">
                </div>
                <button type="submit" class="btn btn-primary">Add Product</button>
            </form>
        </div>

        <div class="section-card">
            <h2>Quick Links</h2>
            <div class="quick-links">
                <a href="sellerShop.jsp" class="quick-link">
                    <span>Manage Products</span>
                    <span class="arrow">→</span>
                </a>
                <a href="products" class="quick-link">
                    <span>View Store Front</span>
                    <span class="arrow">→</span>
                </a>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-logo">OCSP</div>
        <p>© 2024 Online Shopping Clothing Platform. All Rights Reserved.</p>
    </footer>
</body>
</html>
