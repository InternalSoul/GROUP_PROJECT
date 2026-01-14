<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, java.net.URLEncoder, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }

    String sellerParam = request.getParameter("seller");
    if (sellerParam == null || sellerParam.trim().isEmpty()) {
        response.sendRedirect("products");
        return;
    }

    String sellerUsername = sellerParam.trim();

    List<Product> products = new ArrayList<>();
    String sql = "SELECT product_id, name, price, image, category, product_type, size, color, brand, rating " +
                 "FROM products WHERE seller_username = ? ORDER BY product_id DESC";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, sellerUsername);
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getDouble("price"));
                try {
                    String img = rs.getString("image");
                    p.setImage(img != null ? img : "");
                } catch (SQLException e) {
                    p.setImage("");
                }
                p.setCategory(rs.getString("category") != null ? rs.getString("category") : "");
                p.setProductType(rs.getString("product_type") != null ? rs.getString("product_type") : "");
                p.setSize(rs.getString("size") != null ? rs.getString("size") : "");
                p.setColor(rs.getString("color") != null ? rs.getString("color") : "");
                p.setBrand(rs.getString("brand") != null ? rs.getString("brand") : "");
                p.setRating(rs.getDouble("rating"));
                products.add(p);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    List<Product> cart = (List<Product>) session.getAttribute("cart");
    int cartCount = (cart != null) ? cart.size() : 0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= sellerUsername %> - Listings | DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fff; min-height: 100vh; color: #1a1a1a; }
        .top-bar { background: #1a1a1a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .cart-count { background: #1a1a1a; color: #fff; padding: 2px 8px; font-size: 0.75em; margin-left: 5px; }
        .user-name { color: #888; font-size: 0.85em; }
        .page-header { padding: 60px 60px 30px; border-bottom: 1px solid #eee; display:flex; align-items:center; gap:20px; }
        .seller-avatar-lg { width: 64px; height: 64px; border-radius: 50%; object-fit: cover; border: 1px solid #ddd; }
        .page-header-title { display:flex; flex-direction:column; gap:6px; }
        .page-header-title h1 { font-family: 'Playfair Display', serif; font-size: 2.4em; font-weight: 400; letter-spacing: 2px; }
        .page-header-title p { color: #888; font-size: 0.95em; }
        .container { max-width: 1400px; margin: 0 auto; padding: 40px 60px 60px; }
        .products-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 30px; }
        .product-card { background: #fff; border: 1px solid #eee; transition: border-color 0.3s; cursor: pointer; }
        .product-card:hover { border-color: #1a1a1a; }
        .product-image { height: 260px; background: #f5f5f5; display: flex; justify-content: center; align-items: center; overflow: hidden; position: relative; }
        .product-image img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .product-placeholder { font-size: 3em; color: #ddd; }
        .product-info { padding: 20px; text-align: center; }
        .product-name { font-size: 0.95em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 8px; color: #1a1a1a; }
        .product-rating { font-size: 0.8em; color: #f39c12; margin-bottom: 8px; }
        .product-price { font-size: 1em; color: #1a1a1a; margin-bottom: 12px; }
        .add-to-cart-btn { width: 100%; padding: 12px; background: #1a1a1a; color: #fff; border: none; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .add-to-cart-btn:hover { background: #333; }
        .no-products { text-align: center; padding: 80px; color: #888; }
        .footer { background: #1a1a1a; color: #fff; padding: 50px 60px; margin-top: 60px; text-align: center; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 20px; }
        .footer p { color: #666; font-size: 0.8em; }
        @media (max-width: 1200px) { .products-grid { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 900px) { .products-grid { grid-template-columns: repeat(2, 1fr); } .navbar { padding: 15px 30px; } .page-header { padding: 40px 30px 20px; } .container { padding: 30px; } }
        @media (max-width: 600px) { .products-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="page-header">
        <% String avatarUrl = "https://ui-avatars.com/api/?background=111111&color=fff&name=" + URLEncoder.encode(sellerUsername, "UTF-8"); %>
        <img class="seller-avatar-lg" src="<%= avatarUrl %>" alt="<%= sellerUsername %>">
        <div class="page-header-title">
            <h1><%= sellerUsername %></h1>
            <p>All products from this shop</p>
        </div>
    </div>

    <div class="container">
        <% if (products.isEmpty()) { %>
            <div class="no-products">This shop has no products yet.</div>
        <% } else { %>
            <div class="products-grid">
                <% for (Product p : products) { %>
                    <div class="product-card" onclick="window.location.href='<%= request.getContextPath() %>/product?id=<%= p.getId() %>'">
                        <div class="product-image">
                            <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                            <% } else { %>
                                <span class="product-placeholder">◇</span>
                            <% } %>
                        </div>
                        <div class="product-info">
                            <div class="product-name"><%= p.getName() %></div>
                            
                                <div class="product-rating">★ <%= String.format("%.1f", p.getRating()) %></div>
                            
                            <div class="product-price">$<%= String.format("%.2f", p.getPrice()) %></div>
                            <form action="cart" method="post" onclick="event.stopPropagation();">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                <input type="hidden" name="name" value="<%= p.getName() %>">
                                <input type="hidden" name="price" value="<%= p.getPrice() %>">
                                <input type="hidden" name="image" value="<%= p.getImage() != null ? p.getImage() : "" %>">
                                <button type="submit" class="add-to-cart-btn">Add to Cart</button>
                            </form>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <footer class="footer"><div class="footer-logo">DORMDEALZ</div><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
