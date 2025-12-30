<%@ page import="java.util.*, java.sql.*, com.mycompany.oscp.model.*" %>
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
    
    // Fetch statistics from database
    int totalProducts = 0;
    int totalOrders = 0;
    double totalRevenue = 0;
    List<Map<String, Object>> recentProducts = new ArrayList<>();
    
    try (Connection conn = DatabaseConnection.getConnection()) {
        // Count products
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM PRODUCTS");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                totalProducts = rs.getInt(1);
            }
        }
        
        // Get recent products (last 5)
        try (PreparedStatement ps = conn.prepareStatement("SELECT PRODUCT_ID, NAME, PRICE FROM PRODUCTS ORDER BY PRODUCT_ID DESC FETCH FIRST 5 ROWS ONLY");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
                product.put("id", rs.getInt("PRODUCT_ID"));
                product.put("name", rs.getString("NAME"));
                product.put("price", rs.getDouble("PRICE"));
                recentProducts.add(product);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    // Get current time for greeting
    int hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);
    String greeting = hour < 12 ? "Good Morning" : (hour < 18 ? "Good Afternoon" : "Good Evening");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard - OCSP</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
            color: #1a1a1a;
            min-height: 100vh;
        }
        .top-bar {
            background: linear-gradient(90deg, #1a1a1a 0%, #2d2d2d 100%);
            color: #fff;
            text-align: center;
            padding: 12px;
            font-size: 12px;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        .top-bar span {
            color: #ffd700;
        }
        .navbar {
            background: #fff;
            padding: 20px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 20px rgba(0,0,0,0.05);
            position: sticky;
            top: 0;
            z-index: 100;
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
            transition: all 0.3s;
            padding: 8px 0;
            border-bottom: 2px solid transparent;
        }
        .navbar a:hover, .navbar a.active {
            color: #1a1a1a;
            border-bottom-color: #1a1a1a;
        }
        .navbar .user-info {
            font-size: 13px;
            color: #666;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .navbar .user-info::before {
            content: "👤";
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 30px;
        }
        
        /* Welcome Section */
        .welcome-section {
            background: linear-gradient(135deg, #1a1a1a 0%, #333 100%);
            border-radius: 20px;
            padding: 50px;
            margin-bottom: 40px;
            color: #fff;
            position: relative;
            overflow: hidden;
        }
        .welcome-section::before {
            content: "";
            position: absolute;
            top: -50%;
            right: -10%;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(255,215,0,0.1) 0%, transparent 70%);
            border-radius: 50%;
        }
        .welcome-section::after {
            content: "";
            position: absolute;
            bottom: -30%;
            left: 10%;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%);
            border-radius: 50%;
        }
        .welcome-content {
            position: relative;
            z-index: 1;
        }
        .welcome-greeting {
            font-size: 14px;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: #ffd700;
            margin-bottom: 10px;
        }
        .welcome-title {
            font-family: 'Playfair Display', serif;
            font-size: 2.8em;
            font-weight: 600;
            margin-bottom: 15px;
        }
        .welcome-subtitle {
            font-size: 16px;
            color: rgba(255,255,255,0.7);
            max-width: 500px;
        }
        .welcome-date {
            position: absolute;
            top: 50px;
            right: 50px;
            text-align: right;
            z-index: 1;
        }
        .welcome-date .day {
            font-family: 'Playfair Display', serif;
            font-size: 3.5em;
            font-weight: 700;
            line-height: 1;
        }
        .welcome-date .month-year {
            font-size: 14px;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: rgba(255,255,255,0.6);
        }
        
        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 25px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: #fff;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.1);
        }
        .stat-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
        }
        .stat-card:nth-child(1)::before { background: linear-gradient(180deg, #667eea 0%, #764ba2 100%); }
        .stat-card:nth-child(2)::before { background: linear-gradient(180deg, #f093fb 0%, #f5576c 100%); }
        .stat-card:nth-child(3)::before { background: linear-gradient(180deg, #4facfe 0%, #00f2fe 100%); }
        .stat-card:nth-child(4)::before { background: linear-gradient(180deg, #43e97b 0%, #38f9d7 100%); }
        
        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5em;
        }
        .stat-card:nth-child(1) .stat-icon { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .stat-card:nth-child(2) .stat-icon { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .stat-card:nth-child(3) .stat-icon { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
        .stat-card:nth-child(4) .stat-icon { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); }
        
        .stat-trend {
            font-size: 12px;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: 500;
        }
        .stat-trend.up {
            background: rgba(67, 233, 123, 0.15);
            color: #22c55e;
        }
        .stat-trend.down {
            background: rgba(239, 68, 68, 0.15);
            color: #ef4444;
        }
        .stat-value {
            font-family: 'Playfair Display', serif;
            font-size: 2.2em;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 5px;
        }
        .stat-label {
            color: #888;
            font-size: 13px;
            letter-spacing: 0.5px;
        }
        
        /* Content Grid */
        .content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }
        
        /* Section Cards */
        .section-card {
            background: #fff;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .section-header h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.4em;
            font-weight: 600;
        }
        .section-header a {
            font-size: 13px;
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s;
        }
        .section-header a:hover {
            color: #764ba2;
        }
        
        /* Recent Products Table */
        .products-list {
            list-style: none;
        }
        .products-list li {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 15px 0;
            border-bottom: 1px solid #f5f5f5;
            transition: background 0.3s;
        }
        .products-list li:last-child {
            border-bottom: none;
        }
        .products-list li:hover {
            background: #fafafa;
            margin: 0 -15px;
            padding: 15px;
            border-radius: 8px;
        }
        .product-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .product-avatar {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: 600;
            font-size: 14px;
        }
        .product-name {
            font-weight: 500;
            color: #1a1a1a;
            margin-bottom: 3px;
        }
        .product-id {
            font-size: 12px;
            color: #888;
        }
        .product-price {
            font-family: 'Playfair Display', serif;
            font-weight: 600;
            font-size: 1.1em;
            color: #1a1a1a;
        }
        
        /* Quick Actions */
        .quick-actions {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        .action-card {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 20px;
            background: #fafafa;
            border-radius: 12px;
            text-decoration: none;
            color: #1a1a1a;
            transition: all 0.3s;
            border: 1px solid transparent;
        }
        .action-card:hover {
            background: #fff;
            border-color: #667eea;
            transform: translateX(5px);
        }
        .action-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3em;
            flex-shrink: 0;
        }
        .action-card:nth-child(1) .action-icon { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .action-card:nth-child(2) .action-icon { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .action-card:nth-child(3) .action-icon { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
        .action-card:nth-child(4) .action-icon { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); }
        
        .action-content h3 {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 3px;
        }
        .action-content p {
            font-size: 12px;
            color: #888;
        }
        .action-arrow {
            margin-left: auto;
            color: #ccc;
            font-size: 1.2em;
            transition: all 0.3s;
        }
        .action-card:hover .action-arrow {
            color: #667eea;
            transform: translateX(5px);
        }
        
        /* Performance Card */
        .performance-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 16px;
            padding: 30px;
            color: #fff;
        }
        .performance-card h3 {
            font-size: 14px;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 20px;
            opacity: 0.9;
        }
        .performance-score {
            font-family: 'Playfair Display', serif;
            font-size: 3.5em;
            font-weight: 700;
            margin-bottom: 10px;
        }
        .performance-label {
            font-size: 14px;
            opacity: 0.8;
        }
        .performance-bar {
            height: 8px;
            background: rgba(255,255,255,0.2);
            border-radius: 4px;
            margin-top: 20px;
            overflow: hidden;
        }
        .performance-fill {
            height: 100%;
            width: 85%;
            background: #fff;
            border-radius: 4px;
        }
        
        /* Footer */
        .footer {
            background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
            color: #fff;
            padding: 50px;
            text-align: center;
            margin-top: 40px;
            border-radius: 20px 20px 0 0;
        }
        .footer-logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.8em;
            letter-spacing: 3px;
            margin-bottom: 15px;
        }
        .footer p {
            font-size: 13px;
            color: rgba(255,255,255,0.5);
            letter-spacing: 1px;
        }
        
        @media (max-width: 1024px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .content-grid {
                grid-template-columns: 1fr;
            }
            .welcome-date {
                display: none;
            }
        }
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .navbar {
                padding: 15px 20px;
            }
            .navbar .nav-links {
                gap: 20px;
            }
            .welcome-section {
                padding: 30px;
            }
            .welcome-title {
                font-size: 2em;
            }
        }
    </style>
</head>
<body>
    <div class="top-bar">
        Seller Dashboard — <span>Premium Account</span>
    </div>

    <nav class="navbar">
        <a href="index.jsp" class="logo">OCSP</a>
        <div class="nav-links">
            <a href="sellerDashboard.jsp" class="active">Dashboard</a>
            <a href="sellerShop.jsp">My Products</a>
            <a href="products">View Store</a>
            <span class="user-info"><%= user.getUsername() %></span>
            <a href="logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-content">
                <p class="welcome-greeting"><%= greeting %></p>
                <h1 class="welcome-title">Welcome back, <%= user.getUsername() %>!</h1>
                <p class="welcome-subtitle">Here's what's happening with your store today. Keep up the great work!</p>
            </div>
            <div class="welcome-date">
                <div class="day"><%= Calendar.getInstance().get(Calendar.DAY_OF_MONTH) %></div>
                <div class="month-year">
                    <%= new java.text.SimpleDateFormat("MMMM yyyy").format(new java.util.Date()) %>
                </div>
            </div>
        </div>

        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">📦</div>
                    <span class="stat-trend up">Active</span>
                </div>
                <div class="stat-value"><%= totalProducts %></div>
                <div class="stat-label">Total Products</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">🛒</div>
                    <span class="stat-trend up">+12%</span>
                </div>
                <div class="stat-value"><%= totalOrders %></div>
                <div class="stat-label">Total Orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">💰</div>
                    <span class="stat-trend up">+8%</span>
                </div>
                <div class="stat-value">RM <%= String.format("%.0f", totalRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">⭐</div>
                    <span class="stat-trend up">Great</span>
                </div>
                <div class="stat-value">4.8</div>
                <div class="stat-label">Average Rating</div>
            </div>
        </div>

        <!-- Content Grid -->
        <div class="content-grid">
            <!-- Recent Products -->
            <div class="section-card">
                <div class="section-header">
                    <h2>Recent Products</h2>
                    <a href="sellerShop.jsp">View All →</a>
                </div>
                <% if (recentProducts.isEmpty()) { %>
                    <p style="color: #888; text-align: center; padding: 40px;">No products yet. Add your first product!</p>
                <% } else { %>
                    <ul class="products-list">
                        <% for (Map<String, Object> product : recentProducts) { 
                            String name = (String) product.get("name");
                            String initials = name.length() >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
                        %>
                            <li>
                                <div class="product-info">
                                    <div class="product-avatar"><%= initials %></div>
                                    <div>
                                        <div class="product-name"><%= name %></div>
                                        <div class="product-id">ID: #<%= product.get("id") %></div>
                                    </div>
                                </div>
                                <div class="product-price">RM <%= String.format("%.2f", product.get("price")) %></div>
                            </li>
                        <% } %>
                    </ul>
                <% } %>
            </div>

            <!-- Quick Actions -->
            <div>
                <div class="section-card" style="margin-bottom: 25px;">
                    <div class="section-header">
                        <h2>Quick Actions</h2>
                    </div>
                    <div class="quick-actions">
                        <a href="sellerShop.jsp" class="action-card">
                            <div class="action-icon">➕</div>
                            <div class="action-content">
                                <h3>Add New Product</h3>
                                <p>List a new item for sale</p>
                            </div>
                            <span class="action-arrow">→</span>
                        </a>
                        <a href="sellerShop.jsp" class="action-card">
                            <div class="action-icon">📋</div>
                            <div class="action-content">
                                <h3>Manage Inventory</h3>
                                <p>Update product details</p>
                            </div>
                            <span class="action-arrow">→</span>
                        </a>
                        <a href="products" class="action-card">
                            <div class="action-icon">👁️</div>
                            <div class="action-content">
                                <h3>View Store</h3>
                                <p>See your products live</p>
                            </div>
                            <span class="action-arrow">→</span>
                        </a>
                    </div>
                </div>
                
                <!-- Performance Card -->
                <div class="performance-card">
                    <h3>Store Performance</h3>
                    <div class="performance-score">85%</div>
                    <div class="performance-label">Your store is performing great!</div>
                    <div class="performance-bar">
                        <div class="performance-fill"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-logo">OCSP</div>
        <p>© 2025 Online Shopping Clothing Platform. All Rights Reserved.</p>
    </footer>
</body>
</html>
