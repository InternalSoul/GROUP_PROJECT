<%@ page import="java.util.*, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    int cartCount = (cart != null) ? cart.size() : 0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shop - OCSP</title>
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
        .page-header { padding: 60px 60px 40px; text-align: center; border-bottom: 1px solid #eee; }
        .page-header h1 { font-family: 'Playfair Display', serif; font-size: 2.8em; font-weight: 400; letter-spacing: 3px; margin-bottom: 10px; }
        .page-header p { color: #888; font-size: 1em; letter-spacing: 1px; }
        .search-section { padding: 30px 60px; background: #fafafa; border-bottom: 1px solid #eee; }
        .search-bar { display: flex; gap: 15px; max-width: 600px; margin: 0 auto; }
        .search-bar input { flex: 1; padding: 16px 24px; border: 1px solid #ddd; font-size: 0.95em; font-family: 'Inter', sans-serif; }
        .search-bar input:focus { outline: none; border-color: #1a1a1a; }
        .search-bar button { padding: 16px 30px; background: #1a1a1a; color: #fff; border: none; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .search-bar button:hover { background: #333; }
        .search-bar .clear-btn { background: #666; }
        .container { max-width: 1400px; margin: 0 auto; padding: 50px 60px; }
        .products-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 30px; }
        .product-card { background: #fff; border: 1px solid #eee; transition: border-color 0.3s; }
        .product-card:hover { border-color: #1a1a1a; }
        .product-image { height: 300px; background: #f5f5f5; display: flex; justify-content: center; align-items: center; overflow: hidden; }
        .product-image img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .product-placeholder { font-size: 4em; color: #ddd; }
        .product-info { padding: 25px; text-align: center; }
        .product-name { font-size: 0.95em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 10px; color: #1a1a1a; }
        .product-price { font-size: 1em; color: #1a1a1a; margin-bottom: 20px; }
        .add-to-cart-btn { width: 100%; padding: 14px; background: #1a1a1a; color: #fff; border: none; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .add-to-cart-btn:hover { background: #333; }
        .no-products { text-align: center; padding: 80px; color: #888; }
        .no-products h2 { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 400; margin-bottom: 15px; color: #1a1a1a; }
        .footer { background: #1a1a1a; color: #fff; padding: 50px 60px; margin-top: 60px; text-align: center; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 20px; }
        .footer p { color: #666; font-size: 0.8em; }
        @media (max-width: 1200px) { .products-grid { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 900px) { .products-grid { grid-template-columns: repeat(2, 1fr); } .navbar { padding: 15px 30px; } }
        @media (max-width: 600px) { .products-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="top-bar">FREE SHIPPING ON ORDERS OVER RM200</div>
    <nav class="navbar">
        <a href="index.jsp" class="logo">OCSP</a>
        <div class="nav-links">
            <a href="products">Shop</a>
            <a href="cart">Cart<span class="cart-count"><%= cartCount %></span></a>
            <a href="tracking">Track Order</a>
            <% if ("seller".equals(user.getRole())) { %><a href="sellerShop.jsp">My Shop</a><% } %>
            <span class="user-name">Hi, <%= user.getUsername() %></span>
            <a href="logout">Logout</a>
        </div>
    </nav>
    <div class="page-header">
        <h1>Shop All</h1>
        <p>Curated collection of premium fashion</p>
    </div>
    <div class="search-section">
        <form class="search-bar" action="products" method="get">
            <input type="text" name="search" placeholder="Search products..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
            <button type="submit">Search</button>
            <% if (request.getParameter("search") != null && !request.getParameter("search").isEmpty()) { %>
                <a href="products"><button type="button" class="clear-btn">Clear</button></a>
            <% } %>
        </form>
    </div>
    <div class="container">
        <% if (products == null || products.isEmpty()) { %>
            <div class="no-products"><h2>No products found</h2><p>Try a different search or check back later!</p></div>
        <% } else { %>
            <div class="products-grid">
                <% for (Product p : products) { %>
                    <div class="product-card">
                        <div class="product-image">
                            <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                            <% } else { %><span class="product-placeholder">◇</span><% } %>
                        </div>
                        <div class="product-info">
                            <h3 class="product-name"><%= p.getName() %></h3>
                            <p class="product-price">RM <%= String.format("%.2f", p.getPrice()) %></p>
                            <form action="cart" method="post">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                <input type="hidden" name="name" value="<%= p.getName() %>">
                                <input type="hidden" name="price" value="<%= p.getPrice() %>">
                                <input type="hidden" name="image" value="<%= p.getImage() %>">
                                <button type="submit" class="add-to-cart-btn">Add to Cart</button>
                            </form>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
    <footer class="footer"><div class="footer-logo">OCSP</div><p>© 2025 OCSP. All rights reserved.</p></footer>
</body>
</html>
