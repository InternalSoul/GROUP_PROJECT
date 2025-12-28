<%@ page import="java.util.*, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute("cart", cart);
    }
    double total = 0;
    for (Product p : cart) {
        total += p.getPrice();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cart - OCSP</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container { max-width: 1000px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; }
        .cart-empty { text-align: center; padding: 80px 40px; background: #fff; border: 1px solid #eee; }
        .cart-empty h2 { font-family: 'Playfair Display', serif; font-size: 1.5em; font-weight: 400; margin-bottom: 15px; }
        .cart-empty p { color: #888; margin-bottom: 30px; }
        .cart-empty a { display: inline-block; padding: 16px 40px; background: #1a1a1a; color: #fff; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; transition: background 0.3s; }
        .cart-empty a:hover { background: #333; }
        .cart-items { background: #fff; border: 1px solid #eee; }
        .cart-item { display: flex; align-items: center; padding: 30px; border-bottom: 1px solid #eee; }
        .cart-item:last-child { border-bottom: none; }
        .item-image { width: 100px; height: 100px; background: #f5f5f5; display: flex; justify-content: center; align-items: center; margin-right: 30px; font-size: 2em; color: #ddd; }
        .item-details { flex: 1; }
        .item-name { font-size: 1em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 8px; }
        .item-price { color: #1a1a1a; font-size: 1.1em; }
        .remove-btn { padding: 12px 24px; background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; font-size: 0.8em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.3s; }
        .remove-btn:hover { background: #1a1a1a; color: #fff; }
        .cart-summary { background: #fff; border: 1px solid #eee; padding: 40px; margin-top: 30px; }
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 15px; font-size: 1em; }
        .summary-row.total { font-size: 1.3em; font-weight: 600; padding-top: 20px; border-top: 1px solid #eee; margin-top: 20px; }
        .checkout-btn { display: block; width: 100%; padding: 18px; background: #1a1a1a; color: #fff; text-align: center; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; margin-top: 25px; transition: background 0.3s; border: none; cursor: pointer; }
        .checkout-btn:hover { background: #333; }
        .continue-shopping { display: block; text-align: center; margin-top: 20px; color: #888; text-decoration: none; font-size: 0.9em; }
        .continue-shopping:hover { color: #1a1a1a; }
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
        <h1>Shopping Bag</h1>
        <% if (cart.isEmpty()) { %>
            <div class="cart-empty">
                <h2>Your bag is empty</h2>
                <p>Looks like you haven't added anything yet</p>
                <a href="products">Continue Shopping</a>
            </div>
        <% } else { %>
            <div class="cart-items">
                <% for (int i = 0; i < cart.size(); i++) { Product p = cart.get(i); %>
                    <div class="cart-item">
                        <div class="item-image">◇</div>
                        <div class="item-details">
                            <div class="item-name"><%= p.getName() %></div>
                            <div class="item-price">RM <%= String.format("%.2f", p.getPrice()) %></div>
                        </div>
                        <form action="cart" method="post">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="index" value="<%= i %>">
                            <button type="submit" class="remove-btn">Remove</button>
                        </form>
                    </div>
                <% } %>
            </div>
            <div class="cart-summary">
                <div class="summary-row"><span>Subtotal</span><span>RM <%= String.format("%.2f", total) %></span></div>
                <div class="summary-row"><span>Shipping</span><span>Calculated at checkout</span></div>
                <div class="summary-row total"><span>Total</span><span>RM <%= String.format("%.2f", total) %></span></div>
                <form action="order" method="post">
                    <button type="submit" class="checkout-btn">Proceed to Checkout</button>
                </form>
                <a href="products" class="continue-shopping">← Continue Shopping</a>
            </div>
        <% } %>
    </div>
    <footer class="footer"><div class="footer-logo">OCSP</div><p>© 2025 OCSP. All rights reserved.</p></footer>
</body>
</html>
