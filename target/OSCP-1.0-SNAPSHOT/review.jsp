<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    
    String productIdParam = request.getParameter("productId");
    if (productIdParam == null || productIdParam.isEmpty()) {
        session.setAttribute("error", "No product specified for review");
        response.sendRedirect("orderHistory");
        return;
    }
    
    int productId = 0;
    String productName = "Product";
    String productImage = "";
    boolean hasPurchased = false;
    
    try {
        productId = Integer.parseInt(productIdParam);
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if user has purchased this product
            String checkSql = "SELECT COUNT(*) FROM orders o " +
                            "JOIN order_items oi ON o.id = oi.order_id " +
                            "WHERE user_username = ? AND oi.product_id = ? AND status = 'Delivered'";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, user.getUsername());
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        hasPurchased = true;
                    }
                }
            }
            
            if (!hasPurchased) {
                session.setAttribute("error", "You can only review products you have purchased");
                response.sendRedirect("orderHistory");
                return;
            }
            
            // Get product details
            String productSql = "SELECT name, image FROM products WHERE product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(productSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        productName = rs.getString("name");
                        productImage = rs.getString("image");
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("error", "Error loading review page: " + e.getMessage());
        response.sendRedirect("orderHistory");
        return;
    }
    
    String errorMsg = (String) session.getAttribute("error");
    if (errorMsg != null) {
        session.removeAttribute("error");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Write Review - Clothing Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container { max-width: 700px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; }
        .review-box { background: #fff; border: 1px solid #eee; padding: 50px; }
        .form-group { margin-bottom: 30px; }
        .form-group label { display: block; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 12px; color: #1a1a1a; }
        .form-group input[type="text"] { width: 100%; padding: 16px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; }
        .form-group textarea { width: 100%; padding: 16px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; min-height: 150px; resize: vertical; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #1a1a1a; }
        .rating-input { display: flex; gap: 10px; }
        .rating-input input[type="radio"] { display: none; }
        .rating-input label { font-size: 1.8em; cursor: pointer; color: #ddd; transition: color 0.2s; }
        .rating-input input[type="radio"]:checked ~ label, .rating-input label:hover, .rating-input label:hover ~ label { color: #1a1a1a; }
        .submit-btn { width: 100%; padding: 18px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .submit-btn:hover { background: #333; }
        .back-link { display: block; text-align: center; margin-top: 25px; color: #888; text-decoration: none; font-size: 0.9em; }
        .back-link:hover { color: #1a1a1a; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 60px; }
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
    <div class="container">
        <h1>Write a Review</h1>
        <% if (errorMsg != null) { %>
        <div style="background:#fef2f2; border:1px solid #fecaca; color:#b91c1c; padding:14px; margin-bottom:20px; border-radius:8px;">
            <%= errorMsg %>
        </div>
        <% } %>
        <div class="review-box">
            <% if (productImage != null && !productImage.isEmpty()) { %>
            <div style="text-align:center; margin-bottom:30px;">
                <img src="<%= productImage %>" alt="<%= productName %>" style="max-width:200px; max-height:200px; object-fit:cover; border-radius:8px;">
            </div>
            <% } %>
            <form action="review" method="post">
                <input type="hidden" name="productId" value="<%= productId %>">
                <div class="form-group">
                    <label for="productName">Product</label>
                    <input type="text" id="productName" name="productName" value="<%= productName %>" readonly style="background:#f5f5f5;">
                </div>
                <div class="form-group">
                    <label>Rating</label>
                    <div class="rating-input">
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
                <div class="form-group">
                    <label for="comment">Your Review</label>
                    <textarea id="comment" name="comment" placeholder="Share your experience with this product..." required></textarea>
                </div>
                <button type="submit" class="submit-btn">Submit Review</button>
                <a href="products" class="back-link">← Back to Shop</a>
            </form>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
