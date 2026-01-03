<%@ page import="java.util.*, java.net.URLEncoder, model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    Product product = (Product) request.getAttribute("product");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    Double averageRating = (Double) request.getAttribute("averageRating");
    Integer reviewCount = (Integer) request.getAttribute("reviewCount");
    String description = (String) request.getAttribute("description");
    if (product == null) {
        response.sendRedirect("products");
        return;
    }
    if (reviews == null) { reviews = new ArrayList<>(); }
    if (averageRating == null) { averageRating = 0.0; }
    if (reviewCount == null) { reviewCount = 0; }
    if (description == null) { description = "This piece is crafted with attention to detail. Check specs below for sizing and materials."; }
    List<String> specs = new ArrayList<>();
    if (product.getProductType() != null && !product.getProductType().isEmpty()) specs.add("Type: " + product.getProductType());
    if (product.getBrand() != null && !product.getBrand().isEmpty()) specs.add("Brand: " + product.getBrand());
    if (product.getCategory() != null && !product.getCategory().isEmpty()) specs.add("Category: " + product.getCategory());
    if (product.getSize() != null && !product.getSize().isEmpty()) specs.add("Size: " + product.getSize());
    if (product.getColor() != null && !product.getColor().isEmpty()) specs.add("Color: " + product.getColor());
    if (product.getMaterial() != null && !product.getMaterial().isEmpty()) specs.add("Material: " + product.getMaterial());
    if (product.getStockQuantity() > 0) specs.add("Stock: " + product.getStockQuantity() + " pcs available");
    if (product.getCreatedAt() != null) specs.add("Listed on: " + product.getCreatedAt().toLocalDateTime().toLocalDate());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getName() %> - Details</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;700&family=Manrope:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Manrope', sans-serif; background: linear-gradient(135deg, #f7f7f2, #f0f4ff); color: #0f172a; }
        .top-bar { background: #0f172a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eaeaea; background: #fff; position: sticky; top: 0; z-index: 10; }
        .navbar .logo { font-family: 'Cormorant Garamond', serif; font-size: 1.9em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #0f172a; }
        .navbar .nav-links { display: flex; gap: 26px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #0f172a; font-size: 0.9em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; opacity: 0.8; transition: opacity 0.2s; }
        .navbar .nav-links a:hover { opacity: 1; }
        .user-name { color: #475569; font-size: 0.85em; }
        .page { max-width: 1200px; margin: 40px auto 60px; padding: 0 40px; }
        .breadcrumbs { font-size: 0.85em; color: #475569; margin-bottom: 20px; }
        .layout { display: grid; grid-template-columns: 1.1fr 0.9fr; gap: 40px; align-items: start; }
        .media { background: #fff; border: 1px solid #e2e8f0; border-radius: 20px; padding: 20px; box-shadow: 0 12px 40px rgba(15, 23, 42, 0.05); }
        .hero-img { width: 100%; aspect-ratio: 4 / 5; background: #f1f5f9; border-radius: 12px; display: flex; align-items: center; justify-content: center; overflow: hidden; }
        .hero-img img { width: 100%; height: 100%; object-fit: cover; }
        .hero-placeholder { font-size: 4em; color: #cbd5e1; }
        .detail-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 20px; padding: 28px; box-shadow: 0 12px 40px rgba(15, 23, 42, 0.05); }
        .title { font-family: 'Cormorant Garamond', serif; font-size: 2.4em; letter-spacing: 1px; margin-bottom: 8px; }
        .meta { color: #475569; font-size: 0.95em; margin-bottom: 12px; }
        .seller-row { display: inline-flex; align-items: center; gap: 10px; }
        .seller-avatar { width: 40px; height: 40px; border-radius: 50%; border: 1px solid #e2e8f0; object-fit: cover; }
        .seller-link { display: inline-flex; align-items: center; gap: 10px; color: #0f172a; text-decoration: none; font-weight: 700; letter-spacing: 0.5px; }
        .seller-link:hover { text-decoration: underline; }
        .price { font-size: 1.8em; font-weight: 700; color: #0f172a; margin: 14px 0 6px; }
        .stock-row { display:flex; align-items:center; gap:10px; margin-bottom: 12px; font-size:0.9em; color:#475569; }
        .stock-pill { padding:4px 10px; border-radius:999px; font-size:0.75em; letter-spacing:0.5px; text-transform:uppercase; }
        .stock-pill.in { background:#ecfdf3; color:#166534; border:1px solid #bbf7d0; }
        .stock-pill.out { background:#fef2f2; color:#b91c1c; border:1px solid #fecaca; }
        .badges { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 12px; }
        .badge { padding: 6px 10px; border-radius: 999px; font-size: 0.75em; letter-spacing: 0.5px; text-transform: uppercase; }
        .badge-dark { background: #0f172a; color: #fff; }
        .badge-outline { border: 1px solid #0f172a; color: #0f172a; background: #fff; }
        .rating { display: flex; align-items: center; gap: 8px; color: #f59e0b; font-weight: 700; margin-bottom: 10px; }
        .rating span { color: #0f172a; font-weight: 600; }
        .desc { color: #1e293b; line-height: 1.6; margin: 12px 0 20px; }
        .actions { display: flex; gap: 12px; margin-top: 16px; flex-wrap: wrap; }
        .btn { border: none; cursor: pointer; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; border-radius: 10px; padding: 14px 18px; transition: transform 0.2s, box-shadow 0.2s; }
        .btn-primary { background: #0f172a; color: #fff; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.2); }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 16px 36px rgba(15, 23, 42, 0.25); }
        .btn-ghost { background: transparent; border: 1px solid #0f172a; color: #0f172a; }
        .specs { margin-top: 28px; }
        .spec-title { font-size: 0.95em; font-weight: 700; letter-spacing: 1px; color: #475569; margin-bottom: 10px; text-transform: uppercase; }
        .spec-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; }
        .spec-chip { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px; font-size: 0.95em; color: #0f172a; }
        .section { background: #fff; border: 1px solid #e2e8f0; border-radius: 18px; padding: 24px; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04); margin-top: 30px; }
        .section h2 { font-family: 'Cormorant Garamond', serif; font-size: 1.8em; margin-bottom: 10px; }
        .section p { color: #1e293b; line-height: 1.6; }
        .reviews { display: grid; gap: 14px; margin-top: 16px; }
        .review { border: 1px solid #e2e8f0; border-radius: 14px; padding: 14px; background: #f8fafc; }
        .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; color: #475569; font-size: 0.9em; }
        .review-rating { color: #f59e0b; font-weight: 700; }
        .review-comment { color: #0f172a; line-height: 1.5; }
        .empty { padding: 18px; border: 1px dashed #cbd5e1; border-radius: 10px; color: #475569; background: #f8fafc; }
        @media (max-width: 1024px) { .layout { grid-template-columns: 1fr; } .navbar { padding: 16px 30px; } .page { padding: 0 24px; } }
    </style>
</head>
<body>
    <div class="top-bar">Complimentary shipping on orders over $200</div>
    <nav class="navbar">
        <a href="index.jsp" class="logo">CLOTHING STORE</a>
        <div class="nav-links">
            <a href="products">Shop</a>
            <a href="cart">Cart</a>
            <a href="tracking">Track Order</a>
            <% if ("seller".equals(user.getRole()) || "admin".equals(user.getRole())) { %><a href="sellerShop.jsp">My Shop</a><% } %>
            <span class="user-name">Hi, <%= user.getUsername() %></span>
            <a href="logout">Logout</a>
        </div>
    </nav>

    <div class="page">
        <div class="breadcrumbs"><a href="products" style="color:#0f172a; text-decoration:none;">Shop</a> / <span style="opacity:0.65;"><%= product.getName() %></span></div>
        <div class="layout">
            <div class="media">
                <div class="hero-img">
                    <% if (product.getImage() != null && !product.getImage().isEmpty()) { %>
                        <img src="<%= product.getImage() %>" alt="<%= product.getName() %>">
                    <% } else { %>
                        <span class="hero-placeholder">◇</span>
                    <% } %>
                </div>
            </div>
            <div class="detail-card">
                <h1 class="title"><%= product.getName() %></h1>
                <div class="meta">
                    <% String sellerName = product.getSellerUsername() != null && !product.getSellerUsername().isEmpty() ? product.getSellerUsername() : "Unknown"; %>
                    <% String sellerUrl = "sellerStore.jsp?seller=" + URLEncoder.encode(sellerName, "UTF-8"); %>
                    <% String avatarUrl = "https://ui-avatars.com/api/?background=111111&color=fff&name=" + URLEncoder.encode(sellerName, "UTF-8"); %>
                    <a class="seller-link" href="<%= sellerUrl %>">
                        <img class="seller-avatar" src="<%= avatarUrl %>" alt="<%= sellerName %>">
                        <span><%= sellerName %></span>
                    </a>
                </div>
                <div class="rating">★ <%= String.format("%.1f", averageRating) %> <span>(<%= reviewCount %> reviews)</span></div>
                <div class="price">$<%= String.format("%.2f", product.getPrice()) %></div>
                <div class="stock-row">
                    <% if (product.isInStock()) { %>
                        <span class="stock-pill in">In Stock</span>
                    <% } else { %>
                        <span class="stock-pill out">Out of Stock</span>
                    <% } %>
                    <% if (product.getStockQuantity() > 0) { %>
                        <span><%= product.getStockQuantity() %> pieces available</span>
                    <% } %>
                </div>
                <p class="desc"><%= description %></p>
                <div class="actions">
                    <form action="cart" method="post" style="display:flex; gap:12px; flex-wrap: wrap; align-items: center;">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="id" value="<%= product.getId() %>">
                        <input type="hidden" name="name" value="<%= product.getName() %>">
                        <input type="hidden" name="price" value="<%= product.getPrice() %>">
                        <input type="hidden" name="image" value="<%= (product.getImage() != null ? product.getImage() : "") %>">
                        <button type="submit" class="btn btn-primary">Add to Cart</button>
                    </form>
                    <a href="products" class="btn btn-ghost" style="text-decoration:none; display:inline-flex; align-items:center;">Back to Shop</a>
                </div>

                <div class="specs">
                    <div class="spec-title">Key Specs</div>
                    <% if (specs.isEmpty()) { %>
                        <div class="empty">No specs provided for this item yet.</div>
                    <% } else { %>
                        <div class="spec-grid">
                            <% for (String s : specs) { %>
                                <div class="spec-chip"><%= s %></div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="section" style="margin-top: 32px;">
            <h2>Reviews</h2>
            <p>See what shoppers say about this piece.</p>
            <% if (reviews.isEmpty()) { %>
                <div class="empty" style="margin-top:12px;">No reviews yet. Be the first to share your thoughts.</div>
            <% } else { %>
                <div class="reviews">
                    <% for (Review r : reviews) { %>
                        <div class="review">
                            <div class="review-header">
                                <span><%= r.getUsername() != null && !r.getUsername().isEmpty() ? r.getUsername() : "Verified buyer" %></span>
                                <span class="review-rating">★ <%= r.getRating() %></span>
                            </div>
                            <% if (r.getCreatedAt() != null) { %>
                                <div style="color:#94a3b8; font-size:0.85em; margin-bottom:6px;">Posted on <%= r.getCreatedAt().toLocalDateTime().toLocalDate() %></div>
                            <% } %>
                            <div class="review-comment"><%= r.getComment() != null && !r.getComment().isEmpty() ? r.getComment() : "No comment provided." %></div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
