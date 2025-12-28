<%@ page import="com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    
    String productId = (String) request.getAttribute("productId");
    String productName = (String) request.getAttribute("productName");
    if (productName == null) productName = request.getParameter("productName");
    if (productId == null) productId = request.getParameter("productId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Write a Review - OCSP</title>
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
            max-width: 600px;
            margin: 0 auto;
            padding: 60px 30px;
        }
        .page-header {
            text-align: center;
            margin-bottom: 50px;
        }
        .page-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.5em;
            font-weight: 400;
            letter-spacing: 3px;
            margin-bottom: 15px;
        }
        .page-header p {
            color: #888;
            font-size: 14px;
            letter-spacing: 1px;
        }
        .review-card {
            background: #fff;
            border: 1px solid #eee;
            padding: 50px;
        }
        .product-info {
            background: #fafafa;
            border: 1px solid #eee;
            padding: 25px;
            margin-bottom: 40px;
            text-align: center;
        }
        .product-info h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.3em;
            font-weight: 400;
            margin-bottom: 8px;
        }
        .product-info p {
            color: #888;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 30px;
        }
        .form-group label {
            display: block;
            margin-bottom: 12px;
            font-size: 12px;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: #1a1a1a;
        }
        .rating-container {
            text-align: center;
            padding: 20px 0;
        }
        .rating-stars {
            display: inline-flex;
            flex-direction: row-reverse;
            gap: 8px;
        }
        .rating-stars input[type="radio"] {
            display: none;
        }
        .rating-stars label {
            font-size: 2.5em;
            cursor: pointer;
            color: #ddd;
            transition: all 0.2s;
        }
        .rating-stars label:hover,
        .rating-stars label:hover ~ label,
        .rating-stars input[type="radio"]:checked ~ label {
            color: #1a1a1a;
        }
        textarea {
            width: 100%;
            padding: 18px;
            border: 1px solid #ddd;
            font-size: 14px;
            font-family: 'Inter', sans-serif;
            resize: vertical;
            min-height: 150px;
            transition: border-color 0.3s;
        }
        textarea:focus {
            outline: none;
            border-color: #1a1a1a;
        }
        textarea::placeholder {
            color: #aaa;
        }
        .btn {
            width: 100%;
            padding: 18px;
            background: #1a1a1a;
            color: #fff;
            border: none;
            font-size: 13px;
            font-weight: 500;
            letter-spacing: 2px;
            text-transform: uppercase;
            cursor: pointer;
            transition: background 0.3s;
        }
        .btn:hover {
            background: #333;
        }
        .error {
            background: #fafafa;
            color: #c00;
            padding: 15px;
            border: 1px solid #eee;
            margin-bottom: 25px;
            text-align: center;
            font-size: 14px;
        }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 30px;
            color: #1a1a1a;
            text-decoration: none;
            font-size: 13px;
            letter-spacing: 1px;
            transition: opacity 0.3s;
        }
        .back-link:hover {
            opacity: 0.6;
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
        Share Your Experience With Us
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
        <div class="page-header">
            <h1>Write a Review</h1>
            <p>We value your feedback</p>
        </div>

        <div class="review-card">
            <% if (request.getAttribute("error") != null) { %>
                <div class="error"><%= request.getAttribute("error") %></div>
            <% } %>

            <div class="product-info">
                <h3>Product Review</h3>
                <p><%= productName != null ? productName : "Share your shopping experience" %></p>
            </div>

            <form action="review" method="post">
                <input type="hidden" name="productId" value="<%= productId != null ? productId : "" %>">
                
                <div class="form-group">
                    <label>Your Rating</label>
                    <div class="rating-container">
                        <div class="rating-stars">
                            <input type="radio" name="rating" id="star5" value="5" required>
                            <label for="star5">★</label>
                            <input type="radio" name="rating" id="star4" value="4">
                            <label for="star4">★</label>
                            <input type="radio" name="rating" id="star3" value="3">
                            <label for="star3">★</label>
                            <input type="radio" name="rating" id="star2" value="2">
                            <label for="star2">★</label>
                            <input type="radio" name="rating" id="star1" value="1">
                            <label for="star1">★</label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="comment">Your Review</label>
                    <textarea id="comment" name="comment" placeholder="Tell us about your experience with this product..." required></textarea>
                </div>

                <button type="submit" class="btn">Submit Review</button>
            </form>

            <a href="products" class="back-link">← Back to Shop</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-logo">OCSP</div>
        <p>© 2024 Online Shopping Clothing Platform. All Rights Reserved.</p>
    </footer>
</body>
</html>
