<%@ page import="java.util.*, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    List<Order> orders = (List<Order>) request.getAttribute("orders");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Track Orders - OCSP</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container { max-width: 900px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; }
        .no-orders { text-align: center; padding: 80px 40px; background: #fff; border: 1px solid #eee; }
        .no-orders h2 { font-family: 'Playfair Display', serif; font-size: 1.5em; font-weight: 400; margin-bottom: 15px; }
        .no-orders p { color: #888; margin-bottom: 30px; }
        .no-orders a { display: inline-block; padding: 16px 40px; background: #1a1a1a; color: #fff; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; }
        .order-card { background: #fff; border: 1px solid #eee; margin-bottom: 25px; }
        .order-header { display: flex; justify-content: space-between; align-items: center; padding: 25px 30px; border-bottom: 1px solid #eee; background: #fafafa; }
        .order-number { font-weight: 600; letter-spacing: 1px; }
        .order-date { color: #888; font-size: 0.9em; }
        .order-status { padding: 8px 16px; font-size: 0.75em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-processing { background: #cce5ff; color: #004085; }
        .status-shipped { background: #d4edda; color: #155724; }
        .status-delivered { background: #1a1a1a; color: #fff; }
        .order-body { padding: 25px 30px; }
        .order-row { display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 0.95em; }
        .order-row.total { font-weight: 600; font-size: 1.1em; padding-top: 15px; margin-top: 15px; border-top: 1px solid #eee; }
        .order-actions { display: flex; gap: 15px; margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee; }
        .btn-small { padding: 12px 24px; background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; text-decoration: none; font-size: 0.8em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: all 0.3s; }
        .btn-small:hover { background: #1a1a1a; color: #fff; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 80px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">OCSP</a>
        <div class="nav-links">
            <a href="products">Shop</a>
            <a href="cart">Cart</a>
            <a href="tracking">Track Order</a>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="container">
        <h1>My Orders</h1>
        <% if (orders == null || orders.isEmpty()) { %>
            <div class="no-orders">
                <h2>No orders yet</h2>
                <p>Start shopping to see your orders here</p>
                <a href="products">Start Shopping</a>
            </div>
        <% } else { %>
            <% for (Order order : orders) { %>
                <div class="order-card">
                    <div class="order-header">
                        <div>
                            <span class="order-number">Order #<%= order.getId() %></span>
                            <span class="order-date" style="margin-left: 20px;"><%= order.getOrderDate() %></span>
                        </div>
                        <span class="order-status status-<%= order.getStatus().toLowerCase() %>"><%= order.getStatus() %></span>
                    </div>
                    <div class="order-body">
                        <div class="order-row"><span>Delivery Address</span><span><%= order.getAddress() %></span></div>
                        <div class="order-row total"><span>Total</span><span>RM <%= String.format("%.2f", order.getTotal()) %></span></div>
                        <div class="order-actions">
                            <a href="review.jsp?orderId=<%= order.getId() %>" class="btn-small">Write Review</a>
                        </div>
                    </div>
                </div>
            <% } %>
        <% } %>
    </div>
    <footer class="footer"><div class="footer-logo">OCSP</div><p>© 2025 OCSP. All rights reserved.</p></footer>
</body>
</html>
