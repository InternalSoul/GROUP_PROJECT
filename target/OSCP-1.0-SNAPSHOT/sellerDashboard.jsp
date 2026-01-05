<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"seller".equals(user.getRole())) {
        response.sendRedirect("login");
        return;
    }

    int productCount = 0;
    double totalValue = 0.0;
    List<Product> latestProducts = new ArrayList<>();
    List<Map<String, Object>> recentOrders = new ArrayList<>();
    int orderCount = 0;

    try (Connection conn = DatabaseConnection.getConnection()) {
        String countSql = "SELECT COUNT(*) AS cnt, COALESCE(SUM(price),0) AS total_val FROM products WHERE seller_username = ?";
        try (PreparedStatement ps = conn.prepareStatement(countSql)) {
            ps.setString(1, user.getUsername());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    productCount = rs.getInt("cnt");
                    totalValue = rs.getDouble("total_val");
                }
            }
        }

        // Get order count for this seller
        String orderCountSql = "SELECT COUNT(DISTINCT order_id) as cnt FROM order_items WHERE seller_username = ?";
        try (PreparedStatement ps = conn.prepareStatement(orderCountSql)) {
            ps.setString(1, user.getUsername());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    orderCount = rs.getInt("cnt");
                }
            }
        }

        // Get recent orders
        String ordersSql = "SELECT DISTINCT o.order_id, o.user_username, o.total_amount, o.status, o.created_at " +
                          "FROM orders o " +
                          "JOIN order_items oi ON o.order_id = oi.order_id " +
                          "WHERE oi.seller_username = ? " +
                          "ORDER BY o.created_at DESC LIMIT 5";
        try (PreparedStatement ps = conn.prepareStatement(ordersSql)) {
            ps.setString(1, user.getUsername());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> order = new HashMap<>();
                    order.put("orderId", rs.getInt("order_id"));
                    order.put("customerUsername", rs.getString("user_username"));
                    order.put("totalAmount", rs.getDouble("total_amount"));
                    order.put("status", rs.getString("status"));
                    order.put("createdAt", rs.getTimestamp("created_at"));
                    recentOrders.add(order);
                }
            }
        }

        String latestSql = "SELECT product_id, name, price, image FROM products WHERE seller_username = ? ORDER BY product_id DESC LIMIT 5";
        try (PreparedStatement ps = conn.prepareStatement(latestSql)) {
            ps.setString(1, user.getUsername());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("product_id"));
                    p.setName(rs.getString("name"));
                    p.setPrice(rs.getDouble("price"));
                    p.setImage(rs.getString("image") != null ? rs.getString("image") : "");
                    latestProducts.add(p);
                }
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
    <title>Seller Dashboard - Clothing Store</title>
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
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 10px; }
        .welcome-text { color: #888; font-size: 1.05em; margin-bottom: 30px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-top: 20px; }
        .stat-card { background: #fff; border: 1px solid #eee; padding: 24px; border-radius: 10px; }
        .stat-label { font-size: 0.85em; letter-spacing: 0.5px; text-transform: uppercase; color: #666; margin-bottom: 6px; }
        .stat-value { font-size: 2em; font-weight: 700; color: #1a1a1a; }
        .stat-sub { color: #888; font-size: 0.9em; margin-top: 4px; }
        .section { margin-top: 32px; background: #fff; border: 1px solid #eee; border-radius: 10px; padding: 24px; }
        .section h2 { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 1px; margin-bottom: 12px; }
        .section p { color: #666; margin-bottom: 12px; }
        .table { width: 100%; border-collapse: collapse; }
        .table th, .table td { padding: 12px; border-bottom: 1px solid #f0f0f0; text-align: left; }
        .table th { text-transform: uppercase; letter-spacing: 0.5px; font-size: 0.85em; color: #666; }
        .table img { width: 50px; height: 50px; object-fit: cover; border: 1px solid #eee; border-radius: 6px; }
        .actions { display: flex; gap: 12px; margin-top: 16px; flex-wrap: wrap; }
        .btn { padding: 12px 18px; border: 1px solid #1a1a1a; background: #1a1a1a; color: #fff; text-decoration: none; letter-spacing: 0.8px; text-transform: uppercase; font-weight: 600; }
        .btn.secondary { background: transparent; color: #1a1a1a; }
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
                <div class="stat-sub">Sum of your product prices</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Orders</div>
                <div class="stat-value"><%= orderCount %></div>
                <div class="stat-sub">Total orders received</div>
            </div>
        </div>

        <% 
            String successMsg = (String) request.getAttribute("success");
            String errorMsg = (String) request.getAttribute("error");
        %>
        <% if (successMsg != null) { %>
            <div style="margin-top: 20px; padding: 12px 16px; background: #f0fff4; border: 1px solid #c6f6d5; color: #22543d; border-radius: 8px;"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div style="margin-top: 20px; padding: 12px 16px; background: #fff5f5; border: 1px solid #ffcccc; color: #b00020; border-radius: 8px;"><%= errorMsg %></div>
        <% } %>

        <div class="section">
            <h2>Recent Orders</h2>
            <p>Orders containing your products.</p>
            <% if (recentOrders.isEmpty()) { %>
                <p style="color:#888; margin-top: 12px;">No orders yet.</p>
            <% } else { %>
                <table class="table">
                    <thead>
                        <tr><th>Order ID</th><th>Customer</th><th>Amount</th><th>Status</th><th>Date</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> order : recentOrders) { %>
                            <tr>
                                <td>ORD<%= order.get("orderId") %></td>
                                <td><%= order.get("customerUsername") %></td>
                                <td>$<%= String.format("%.2f", (Double)order.get("totalAmount")) %></td>
                                <td><%= order.get("status") %></td>
                                <td><%= order.get("createdAt") != null ? ((java.sql.Timestamp)order.get("createdAt")).toLocalDateTime().toLocalDate().toString() : "N/A" %></td>
                                <td>
                                    <form action="updateOrderStatus" method="post" style="display: inline-flex; gap: 8px; align-items: center;">
                                        <input type="hidden" name="orderId" value="<%= order.get("orderId") %>">
                                        <select name="status" style="padding: 6px 10px; border: 1px solid #ddd; font-size: 0.85em;">
                                            <option value="Pending" <%= "Pending".equals(order.get("status")) ? "selected" : "" %>>Pending</option>
                                            <option value="Processing" <%= "Processing".equals(order.get("status")) ? "selected" : "" %>>Processing</option>
                                            <option value="Shipped" <%= "Shipped".equals(order.get("status")) ? "selected" : "" %>>Shipped</option>
                                            <option value="Delivered" <%= "Delivered".equals(order.get("status")) ? "selected" : "" %>>Delivered</option>
                                            <option value="Cancelled" <%= "Cancelled".equals(order.get("status")) ? "selected" : "" %>>Cancelled</option>
                                        </select>
                                        <button type="submit" style="padding: 6px 12px; background: #1a1a1a; color: #fff; border: none; cursor: pointer; font-size: 0.85em;">Update</button>
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
                        <tr><th>Item</th><th>Price</th><th></th></tr>
                    </thead>
                    <tbody>
                        <% for (Product p : latestProducts) { %>
                            <tr>
                                <td>
                                    <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                        <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                                    <% } %>
                                    <span style="margin-left:10px;"><%= p.getName() %></span>
                                </td>
                                <td>$<%= String.format("%.2f", p.getPrice()) %></td>
                                <td><a href="product?id=<%= p.getId() %>" style="text-decoration:none; color:#1a1a1a;">View</a></td>
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
                <a class="btn secondary" href="products">View Storefront</a>
            </div>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
