<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    String orderId = (String) request.getAttribute("orderId");
    if (orderId == null) orderId = "ORD" + System.currentTimeMillis();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed - Clothing Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; display: flex; flex-direction: column; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .main-content { flex: 1; display: flex; justify-content: center; align-items: center; padding: 60px 30px; }
        .success-box { background: #fff; border: 1px solid #eee; padding: 80px 60px; text-align: center; max-width: 550px; }
        .success-icon { font-size: 4em; margin-bottom: 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2em; font-weight: 400; letter-spacing: 2px; margin-bottom: 15px; }
        .subtitle { color: #888; font-size: 1em; margin-bottom: 35px; line-height: 1.6; }
        .order-id { background: #f5f5f5; padding: 20px 30px; margin-bottom: 40px; }
        .order-id span { font-size: 0.8em; color: #888; text-transform: uppercase; letter-spacing: 1px; display: block; margin-bottom: 8px; }
        .order-id strong { font-size: 1.2em; letter-spacing: 2px; }
        .btn { display: inline-block; padding: 16px 40px; background: #1a1a1a; color: #fff; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; transition: background 0.3s; margin: 8px; }
        .btn:hover { background: #333; }
        .btn-outline { background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; }
        .btn-outline:hover { background: #1a1a1a; color: #fff; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">CLOTHING STORE</a>
        <div class="nav-links">
            <a href="products">Shop</a>
            <a href="cart">Cart</a>
            <a href="tracking">Track Order</a>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="main-content">
        <div class="success-box">
            <div class="success-icon">✓</div>
            <h1>Order Confirmed</h1>
            <p class="subtitle">Thank you for your purchase. We've received your order and will begin processing it right away.</p>
            <div class="order-id">
                <span>Order Number</span>
                <strong><%= orderId %></strong>
            </div>
            <a href="products" class="btn">Continue Shopping</a>
            <a href="tracking" class="btn btn-outline">Track Order</a>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
