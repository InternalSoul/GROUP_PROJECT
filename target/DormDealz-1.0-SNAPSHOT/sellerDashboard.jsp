<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"seller".equals(user.getRole())) {
        response.sendRedirect("login");
        return;
    }

    // Get attributes from servlet
    Integer productCount = (Integer) request.getAttribute("productCount");
    Double totalValue = (Double) request.getAttribute("totalValue");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    Integer orderCount = (Integer) request.getAttribute("orderCount");
    Integer pendingOrders = (Integer) request.getAttribute("pendingOrders");
    
    @SuppressWarnings("unchecked")
    List<Product> latestProducts = (List<Product>) request.getAttribute("latestProducts");
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> recentOrders = (List<Map<String, Object>>) request.getAttribute("recentOrders");
    
    // Set defaults if attributes are null (direct JSP access)
    if (productCount == null) productCount = 0;
    if (totalValue == null) totalValue = 0.0;
    if (totalRevenue == null) totalRevenue = 0.0;
    if (orderCount == null) orderCount = 0;
    if (pendingOrders == null) pendingOrders = 0;
    if (latestProducts == null) latestProducts = new ArrayList<>();
    if (recentOrders == null) recentOrders = new ArrayList<>();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/uitm-theme.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #f3e6fa; min-height: 100vh; color: #4b1556; }
            .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #e5c6f6; background: #85358c; }
            .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #fff; }
        .navbar .nav-links { display: flex; gap: 30px; }
            .navbar .nav-links a { text-decoration: none; color: #fff; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
            .navbar .nav-links a:hover { opacity: 0.7; }
        .container { max-width: 1200px; margin: 0 auto; padding: 60px 30px; background: #fff; border-radius: 16px; box-shadow: 0 2px 12px #e5c6f6; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 10px; }
        .welcome-text { color: #85358c; font-size: 1.05em; margin-bottom: 30px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-top: 20px; }
        .stat-card { background: #e5c6f6; border: 1px solid #85358c; padding: 24px; border-radius: 10px; }
        .stat-label { font-size: 0.85em; letter-spacing: 0.5px; text-transform: uppercase; color: #85358c; margin-bottom: 6px; }
        .stat-value { font-size: 2em; font-weight: 700; color: #4b1556; }
        .stat-sub { color: #85358c; font-size: 0.9em; margin-top: 4px; }
        .section { margin-top: 32px; background: #f3e6fa; border: 1px solid #85358c; border-radius: 10px; padding: 24px; }
        .section h2 { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 1px; margin-bottom: 12px; color: #85358c; }
        .section p { color: #85358c; margin-bottom: 12px; }
        .table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 8px; overflow: hidden; }
        .table th, .table td { padding: 12px; border-bottom: 1px solid #e5c6f6; text-align: left; }
        .table th { text-transform: uppercase; letter-spacing: 0.5px; font-size: 0.85em; color: #85358c; background: #f3e6fa; }
        .table img { width: 50px; height: 50px; object-fit: cover; border: 1px solid #e5c6f6; border-radius: 6px; }
        .actions { display: flex; gap: 12px; margin-top: 16px; flex-wrap: wrap; }
        .btn { padding: 12px 18px; border: 1px solid #85358c; background: #85358c; color: #fff; text-decoration: none; letter-spacing: 0.8px; text-transform: uppercase; font-weight: 600; transition: background 0.3s, border 0.3s; }
        .btn.secondary { background: transparent; color: #85358c; border: 1px solid #85358c; }
        .footer { background: #85358c; color: #fff; padding: 40px; text-align: center; margin-top: 80px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; color: #fff; }
        .footer p { color: #e5c6f6; font-size: 0.8em; }
        .success-message { background: #e5c6f6; border: 1px solid #85358c; color: #4b1556; padding: 12px 16px; border-radius: 8px; margin-top: 20px; }
        .error-message { background: #f3e6fa; border: 1px solid #85358c; color: #b00020; padding: 12px 16px; border-radius: 8px; margin-top: 20px; }
        @media (max-width: 1024px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 768px) {
            .navbar { padding: 15px 30px; flex-wrap: wrap; }
            .navbar .nav-links { gap: 15px; flex-wrap: wrap; }
            .container { padding: 40px 20px; }
            h1 { font-size: 2em; }
            .stats-grid { grid-template-columns: 1fr; }
            .table { font-size: 0.9em; }
            .table th, .table td { padding: 8px; }
            .actions { flex-direction: column; }
            .actions .btn { width: 100%; text-align: center; }
        }
        @media (max-width: 480px) {
            .navbar { padding: 12px 15px; }
            .navbar .logo { font-size: 1.4em; }
            .navbar .nav-links { font-size: 0.75em; gap: 10px; }
            .container { padding: 30px 15px; }
            h1 { font-size: 1.7em; }
            .table { display: block; overflow-x: auto; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">DORMDEALZ</a>
        <div class="nav-links">
            <a href="sellerDashboard">Dashboard</a>
            <a href="sellerShop.jsp">My Shop</a>
            <a href="sellerStore.jsp?seller=<%= user.getUsername() %>">View Store</a>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="container">
        <h1>Seller Dashboard</h1>
        <p class="welcome-text">Welcome back, <%= user.getUsername() %>. Here is your shop at a glance.</p>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Products</div>
                <div class="stat-value"><%= productCount %></div>
                <div class="stat-sub">Active listings</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Catalog Value</div>
                <div class="stat-value">$<%= String.format("%.2f", totalValue) %></div>
                <div class="stat-sub">Sum of product prices</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Revenue</div>
                <div class="stat-value">$<%= String.format("%.2f", totalRevenue) %></div>
                <div class="stat-sub">From <%= orderCount %> orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Pending Orders</div>
                <div class="stat-value"><%= pendingOrders %></div>
                <div class="stat-sub">Awaiting processing</div>
            </div>
        </div>

        <% 
            String successMsg = (String) request.getAttribute("success");
            String errorMsg = (String) request.getAttribute("error");
        %>
        <% if (successMsg != null) { %>
            <div class="success-message"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="error-message"><%= errorMsg %></div>
        <% } %>

        <div class="section">
            <h2>Recent Orders</h2>
            <p>Orders containing your products. Amount shown is your portion of each order.</p>
            <% if (recentOrders.isEmpty()) { %>
                <p style="color:#888; margin-top: 12px;">No orders yet.</p>
            <% } else { %>
                <table class="table">
                    <thead>
                        <tr><th>Order ID</th><th>Customer</th><th>Your Amount</th><th>Status</th><th>Date</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> order : recentOrders) { %>
                            <tr>
                                <td>ORD<%= order.get("orderId") %></td>
                                <td><%= order.get("customerUsername") %></td>
                                <td>$<%= String.format("%.2f", (Double)order.get("sellerTotal")) %></td>
                                <td>
                                    <span style="padding: 4px 8px; border-radius: 4px; font-size: 0.85em; <%
                                        String status = (String)order.get("status");
                                        if ("Delivered".equals(status)) {
                                            out.print("background: #d1fae5; color: #065f46;");
                                        } else if ("Shipped".equals(status)) {
                                            out.print("background: #dbeafe; color: #1e40af;");
                                        } else if ("Processing".equals(status)) {
                                            out.print("background: #fef3c7; color: #92400e;");
                                        } else if ("Cancelled".equals(status)) {
                                            out.print("background: #fee2e2; color: #991b1b;");
                                        } else {
                                            out.print("background: #f3f4f6; color: #374151;");
                                        }
                                    %>"><%= status %></span>
                                </td>
                                <td><%= order.get("createdAt") != null ? ((java.sql.Timestamp)order.get("createdAt")).toLocalDateTime().toLocalDate().toString() : "N/A" %></td>
                                <td>
                                    <form action="updateOrderStatus" method="post" style="display: inline-flex; gap: 8px; align-items: center;">
                                        <input type="hidden" name="orderId" value="<%= order.get("orderId") %>">
                                        <select name="status" style="padding: 6px 10px; border: 1px solid #ddd; font-size: 0.85em; border-radius: 4px;">
                                            <option value="Pending" <%= "Pending".equals(order.get("status")) ? "selected" : "" %>>Pending</option>
                                            <option value="Processing" <%= "Processing".equals(order.get("status")) ? "selected" : "" %>>Processing</option>
                                            <option value="Shipped" <%= "Shipped".equals(order.get("status")) ? "selected" : "" %>>Shipped</option>
                                            <option value="Delivered" <%= "Delivered".equals(order.get("status")) ? "selected" : "" %>>Delivered</option>
                                            <option value="Cancelled" <%= "Cancelled".equals(order.get("status")) ? "selected" : "" %>>Cancelled</option>
                                        </select>
                                        <button type="submit" style="padding: 6px 12px; background: #1a1a1a; color: #fff; border: none; cursor: pointer; font-size: 0.85em; border-radius: 4px; transition: background 0.2s;">Update</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>

        <div class="section">
            <h2>Latest Products</h2>
            <p>Your five most recent listings.</p>
            <% if (latestProducts.isEmpty()) { %>
                <p style="color:#888;">No products yet. Add your first product to see it here.</p>
            <% } else { %>
                <table class="table">
                    <thead>
                        <tr><th>Item</th><th>Price</th><th>Stock</th><th>Status</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                        <% for (Product p : latestProducts) { %>
                            <tr>
                                <td style="display: flex; align-items: center; gap: 10px;">
                                    <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                        <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                                    <% } else { %>
                                        <div style="width: 50px; height: 50px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; border-radius: 6px; color: #ccc;">◇</div>
                                    <% } %>
                                    <span><%= p.getName() %></span>
                                </td>
                                <td>$<%= String.format("%.2f", p.getPrice()) %></td>
                                <td><%= p.getStockQuantity() %> units</td>
                                <td>
                                    <% if (p.isInStock() && p.getStockQuantity() > 0) { %>
                                        <span style="color: #10b981; font-weight: 500;">✓ In Stock</span>
                                    <% } else { %>
                                        <span style="color: #ef4444; font-weight: 500;">✗ Out of Stock</span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="product?id=<%= p.getId() %>" style="text-decoration:none; color:#1a1a1a; margin-right: 12px;">View</a>
                                    <a href="sellerShop.jsp" style="text-decoration:none; color:#666;">Edit</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>

        <div class="section">
            <h2>Quick Actions</h2>
            <div class="actions">
                <a class="btn" href="sellerShop.jsp">Manage Products</a>
                <a class="btn secondary" href="sellerStore.jsp?seller=<%= user.getUsername() %>">View Storefront</a>
            </div>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">DORMDEALZ</div><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
