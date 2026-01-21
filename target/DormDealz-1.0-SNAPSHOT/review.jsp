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
    <title>Write Review - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/uitm-theme.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-secondary); min-height: 100vh; color: var(--text-primary); }
        .container { max-width: 700px; margin: 0 auto; padding: 60px 30px; background: var(--bg-primary); border-radius: 12px; box-shadow: var(--shadow-md); }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; color: var(--primary-purple); }
        .review-box { background: var(--bg-primary); border: 1px solid var(--border-light); padding: 50px; border-radius: 10px; box-shadow: var(--shadow-sm); }
        .form-group { margin-bottom: 30px; }
        .form-group label { display: block; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 12px; color: var(--primary-purple); }
        .form-group input[type="text"], .form-group textarea { width: 100%; padding: 16px; border: 1px solid var(--border-medium); font-size: 1em; font-family: 'Inter', sans-serif; border-radius: 6px; background: var(--bg-secondary); }
        .form-group textarea { min-height: 150px; resize: vertical; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: var(--primary-purple); box-shadow: 0 0 0 2px #e8dce9; }
        .rating-input { display: flex; gap: 6px; font-size: 1.8em; cursor: pointer; }
        .rating-input input[type="radio"] { display: none; }
        .rating-input label { cursor: pointer; color: #ddd; transition: color 0.15s ease-in-out; }
        .rating-input label.active { color: var(--accent-gold); }
        .submit-btn { width: 100%; padding: 18px; background: var(--primary-purple); color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; border-radius: 8px; transition: background 0.3s; }
        .submit-btn:hover { background: var(--primary-dark); }
        .back-link { display: block; text-align: center; margin-top: 25px; color: var(--primary-purple); text-decoration: none; font-size: 0.9em; font-weight: 500; }
        .back-link:hover { color: var(--primary-dark); }
        .footer { background: rgba(245, 245, 245, 0.5); color: var(--text-secondary); padding: 40px; text-align: center; margin-top: 60px; border-top: 1px solid rgba(255,255,255,0.3); }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; color: var(--primary-purple); }
        .footer p { color: var(--text-light); font-size: 0.8em; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
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
                    <div class="rating-input" data-rating-group="review-main">
                        <input type="radio" name="rating" id="star5" value="5.0" required>
                        <label for="star5" data-value="5.0">★</label>
                        <input type="radio" name="rating" id="star4_5" value="4.5">
                        <label for="star4_5" data-value="4.5">★</label>
                        <input type="radio" name="rating" id="star4" value="4.0">
                        <label for="star4" data-value="4.0">★</label>
                        <input type="radio" name="rating" id="star3_5" value="3.5">
                        <label for="star3_5" data-value="3.5">★</label>
                        <input type="radio" name="rating" id="star3" value="3.0">
                        <label for="star3" data-value="3.0">★</label>
                        <input type="radio" name="rating" id="star2_5" value="2.5">
                        <label for="star2_5" data-value="2.5">★</label>
                        <input type="radio" name="rating" id="star2" value="2.0">
                        <label for="star2" data-value="2.0">★</label>
                        <input type="radio" name="rating" id="star1_5" value="1.5">
                        <label for="star1_5" data-value="1.5">★</label>
                        <input type="radio" name="rating" id="star1" value="1.0">
                        <label for="star1" data-value="1.0">★</label>
                        <input type="radio" name="rating" id="star0_5" value="0.5">
                        <label for="star0_5" data-value="0.5">★</label>
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
    <footer class="footer"><div class="footer-logo">DORMDEALZ</div><p>© 2026 DormDealz. All rights reserved.</p></footer>
    <script>
        (function() {
            const group = document.querySelector('.rating-input[data-rating-group="review-main"]');
            if (!group) return;

            const labels = Array.from(group.querySelectorAll('label'));

            function setActive(value) {
                labels.forEach(label => {
                    const v = parseFloat(label.dataset.value);
                    label.classList.toggle('active', v <= value);
                });
            }

            labels.forEach(label => {
                const value = parseFloat(label.dataset.value);
                label.addEventListener('mouseenter', () => setActive(value));
                label.addEventListener('click', () => {
                    const input = group.querySelector('input[name="rating"][value="' + value + '"]');
                    if (input) {
                        input.checked = true;
                    }
                    group.dataset.selected = value;
                    setActive(value);
                });
            });

            group.addEventListener('mouseleave', () => {
                const selected = parseFloat(group.dataset.selected || '0');
                setActive(selected);
            });
        })();
    </script>
</body>
</html>
