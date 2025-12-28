<%@ page import="com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    
    String msg = (String) request.getAttribute("msg");
    Integer rating = (Integer) request.getAttribute("rating");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Submitted - OCSP</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: #fff;
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
            max-width: 500px;
            margin: 0 auto;
            padding: 80px 30px;
        }
        .success-card {
            background: #fff;
            border: 1px solid #eee;
            padding: 60px 50px;
            text-align: center;
        }
        .success-icon {
            width: 100px;
            height: 100px;
            background: #1a1a1a;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0 auto 35px;
            animation: scaleIn 0.5s ease-out;
        }
        .success-icon svg {
            width: 50px;
            height: 50px;
            stroke: #fff;
            stroke-width: 2;
            fill: none;
        }
        @keyframes scaleIn {
            0% {
                transform: scale(0);
                opacity: 0;
            }
            100% {
                transform: scale(1);
                opacity: 1;
            }
        }
        h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.2em;
            font-weight: 400;
            letter-spacing: 2px;
            margin-bottom: 15px;
        }
        .message {
            color: #666;
            font-size: 14px;
            line-height: 1.8;
            margin-bottom: 25px;
        }
        .stars {
            font-size: 2em;
            color: #1a1a1a;
            margin-bottom: 40px;
            letter-spacing: 5px;
        }
        .stars .empty {
            color: #ddd;
        }
        .btn-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn {
            display: inline-block;
            padding: 16px 35px;
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 2px;
            text-transform: uppercase;
            text-decoration: none;
            transition: all 0.3s;
        }
        .btn-primary {
            background: #1a1a1a;
            color: #fff;
            border: 1px solid #1a1a1a;
        }
        .btn-primary:hover {
            background: #333;
            border-color: #333;
        }
        .btn-secondary {
            background: #fff;
            color: #1a1a1a;
            border: 1px solid #1a1a1a;
        }
        .btn-secondary:hover {
            background: #1a1a1a;
            color: #fff;
        }
        .footer {
            background: #1a1a1a;
            color: #fff;
            padding: 50px;
            text-align: center;
            margin-top: 80px;
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
    </style>
</head>
<body>
    <div class="top-bar">
        Thank You For Your Feedback
    </div>

    <nav class="navbar">
        <a href="index.jsp" class="logo">OCSP</a>
        <div class="nav-links">
            <a href="products">Shop</a>
            <a href="cart">Bag</a>
            <a href="tracking">Orders</a>
            <span class="user-info"><%= user.getUsername() %></span>
            <a href="logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="success-card">
            <div class="success-icon">
                <svg viewBox="0 0 24 24">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
            </div>
            <h1>Thank You</h1>
            <p class="message"><%= msg != null ? msg : "Your review has been submitted successfully. We appreciate your feedback!" %></p>
            
            <% if (rating != null) { %>
                <div class="stars">
                    <% for (int i = 0; i < rating; i++) { %>★<% } %><% for (int i = rating; i < 5; i++) { %><span class="empty">★</span><% } %>
                </div>
            <% } %>
            
            <div class="btn-group">
                <a href="products" class="btn btn-primary">Continue Shopping</a>
                <a href="tracking" class="btn btn-secondary">View Orders</a>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-logo">OCSP</div>
        <p>© 2024 Online Shopping Clothing Platform. All Rights Reserved.</p>
    </footer>
</body>
</html>
