<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clothing Store - Premium Fashion Online</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fff; min-height: 100vh; color: #1a1a1a; }
        .top-bar { background: #1a1a1a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 35px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.9em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .hero { height: 80vh; background: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)), url('https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1600') center/cover; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; color: #fff; }
        .hero h1 { font-family: 'Playfair Display', serif; font-size: 4em; font-weight: 400; letter-spacing: 8px; margin-bottom: 20px; }
        .hero p { font-size: 1.1em; letter-spacing: 3px; margin-bottom: 40px; font-weight: 300; }
        .hero-buttons { display: flex; gap: 20px; }
        .btn { display: inline-block; padding: 16px 45px; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; transition: all 0.3s ease; }
        .btn-primary { background: #fff; color: #1a1a1a; border: 2px solid #fff; }
        .btn-primary:hover { background: transparent; color: #fff; }
        .btn-secondary { background: transparent; color: #fff; border: 2px solid #fff; }
        .btn-secondary:hover { background: #fff; color: #1a1a1a; }
        .features-section { padding: 80px 60px; background: #fafafa; }
        .features-section h2 { text-align: center; font-family: 'Playfair Display', serif; font-size: 2.2em; font-weight: 400; margin-bottom: 50px; letter-spacing: 2px; }
        .features { display: grid; grid-template-columns: repeat(3, 1fr); gap: 40px; max-width: 1000px; margin: 0 auto; }
        .feature { text-align: center; padding: 30px; }
        .feature-icon { font-size: 2.5em; margin-bottom: 20px; }
        .feature h3 { font-size: 1em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 12px; }
        .feature-text { color: #666; font-size: 0.9em; line-height: 1.6; }
        .footer { background: #1a1a1a; color: #fff; padding: 60px; text-align: center; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 25px; }
        .footer-links { display: flex; justify-content: center; gap: 30px; margin-bottom: 30px; }
        .footer-links a { color: #999; text-decoration: none; font-size: 0.85em; letter-spacing: 1px; transition: color 0.3s; }
        .footer-links a:hover { color: #fff; }
        .footer p { color: #666; font-size: 0.8em; }
        @media (max-width: 900px) { .navbar { padding: 15px 30px; } .features { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    <section class="hero">
        <h1>CLOTHING STORE</h1>
        <p>Slow Fashion & Modern Culture</p>
        <div class="hero-buttons">
            <a href="<%= (user != null) ? "products" : "login" %>" class="btn btn-primary">
                <%= (user != null) ? "Shop Now" : "Shop Now" %>
            </a>
            <a href="<%= (user != null) ? "orderHistory" : "register" %>" class="btn btn-secondary">
                <%= (user != null) ? "View Orders" : "Join Us" %>
            </a>
        </div>
    </section>
    <section class="features-section">
        <h2>Why Shop With Us</h2>
        <div class="features">
            <div class="feature">
                <div class="feature-icon">✦</div>
                <h3>Curated Selection</h3>
                <p class="feature-text">Handpicked pieces from premium brands worldwide</p>
            </div>
            <div class="feature">
                <div class="feature-icon">◈</div>
                <h3>Secure Payment</h3>
                <p class="feature-text">Multiple payment options with encrypted checkout</p>
            </div>
            <div class="feature">
                <div class="feature-icon">◇</div>
                <h3>Fast Delivery</h3>
                <p class="feature-text">Express shipping to your doorstep</p>
            </div>
        </div>
    </section>
    <footer class="footer">
        <div class="footer-logo">CLOTHING STORE</div>
        <div class="footer-links">
            <a href="#">About Us</a>
            <a href="#">Contact</a>
            <a href="#">Privacy Policy</a>
            <a href="#">Terms & Conditions</a>
        </div>
        <p>© 2026 Clothing Store. All rights reserved.</p>
    </footer>
</body>
</html>
