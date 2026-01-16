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
    // Group cart by product so multiple units of the same
    // product appear as a single line with a quantity.
    Map<Integer, Product> productById = new LinkedHashMap<>();
    Map<Integer, Integer> quantityById = new LinkedHashMap<>();
    for (Product p : cart) {
        int id = p.getId();
        if (!productById.containsKey(id)) {
            productById.put(id, p);
            quantityById.put(id, 0);
        }
        quantityById.put(id, quantityById.get(id) + 1);
    }

    double total = 0;
    for (Map.Entry<Integer, Product> entry : productById.entrySet()) {
        int id = entry.getKey();
        Product p = entry.getValue();
        int qty = quantityById.get(id);
        total += p.getPrice() * qty;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cart - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/uitm-theme.css">
    <link rel="stylesheet" href="css/pages.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .top-bar { background: #1a1a1a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .cart-count { background: #1a1a1a; color: #fff; padding: 2px 8px; font-size: 0.75em; margin-left: 5px; }
        .user-name { color: #888; font-size: 0.85em; }
        .container { max-width: 1000px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; }
        .cart-empty { text-align: center; padding: 80px 40px; background: #fff; border: 1px solid #eee; }
        .cart-empty h2 { font-family: 'Playfair Display', serif; font-size: 1.5em; font-weight: 400; margin-bottom: 15px; }
        .cart-empty p { color: #888; margin-bottom: 30px; }
        .cart-empty a { display: inline-block; padding: 16px 40px; background: #1a1a1a; color: #fff; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; transition: background 0.3s; }
        .cart-empty a:hover { background: #333; }
        .cart-items { background: #fff; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
        .cart-item { display: flex; align-items: center; padding: 30px; border-bottom: 1px solid #eee; opacity: 0; animation: slideInRight 0.5s ease-out forwards; transition: all 0.3s ease; }
        .cart-item:nth-child(1) { animation-delay: 0.1s; }
        .cart-item:nth-child(2) { animation-delay: 0.2s; }
        .cart-item:nth-child(3) { animation-delay: 0.3s; }
        .cart-item:nth-child(4) { animation-delay: 0.4s; }
        .cart-item:nth-child(5) { animation-delay: 0.5s; }
        @keyframes slideInRight { from { opacity: 0; transform: translateX(-30px); } to { opacity: 1; transform: translateX(0); } }
        .cart-item:hover { background: #f8fafc; }
        .cart-item:last-child { border-bottom: none; }
        .item-image { width: 100px; height: 100px; background: #f5f5f5; display: flex; justify-content: center; align-items: center; margin-right: 30px; font-size: 2em; color: #ddd; overflow: hidden; }
        .item-image img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .item-details { flex: 1; }
        .item-name { font-size: 1em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 8px; }
        .item-price { color: #1a1a1a; font-size: 1.1em; }
        .item-qty { color: #666; font-size: 0.9em; margin-top: 4px; }
        .remove-btn { padding: 12px 24px; background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; font-size: 0.8em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.3s; }
        .remove-btn:hover { background: #1a1a1a; color: #fff; }
        .cart-summary { background: #fff; border: 1px solid #eee; padding: 40px; margin-top: 30px; }
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 15px; font-size: 1em; }
        .summary-row.total { font-size: 1.3em; font-weight: 600; padding-top: 20px; border-top: 1px solid #eee; margin-top: 20px; }
        .checkout-btn { display: block; width: 100%; padding: 18px; background: #1a1a1a; color: #fff; text-align: center; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; margin-top: 25px; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); border: none; cursor: pointer; position: relative; overflow: hidden; }
        .checkout-btn::before { content: ''; position: absolute; top: 50%; left: 50%; width: 0; height: 0; border-radius: 50%; background: rgba(255,255,255,0.2); transform: translate(-50%, -50%); transition: width 0.6s, height 0.6s; }
        .checkout-btn:hover { background: #333; transform: translateY(-2px); box-shadow: 0 10px 25px rgba(0,0,0,0.2); }
        .checkout-btn:hover::before { width: 400px; height: 400px; }
        .checkout-btn:active { transform: translateY(0); }
        .continue-shopping { display: block; text-align: center; margin-top: 20px; color: #888; text-decoration: none; font-size: 0.9em; }
        .continue-shopping:hover { color: #1a1a1a; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 80px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }        .breadcrumbs { font-size: 0.85em; color: #888; margin-bottom: 20px; }
        .breadcrumbs a { color: #1a1a1a; text-decoration: none; transition: opacity 0.3s; }
        .breadcrumbs a:hover { opacity: 0.6; }
        .success-message { background: #f0fff4; border: 1px solid #c6f6d5; color: #22543d; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9em; }
        .error-message { background: #fff5f5; border: 1px solid #ffcccc; color: #b00020; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9em; }        @media (max-width: 900px) {
            .navbar { padding: 15px 30px; flex-wrap: wrap; }
            .navbar .nav-links { gap: 15px; flex-wrap: wrap; }
            .container { padding: 40px 30px; }
            .cart-items { gap: 20px; }
            .cart-summary { margin-top: 30px; }
        }
        @media (max-width: 600px) {
            .navbar { padding: 12px 20px; }
            .navbar .logo { font-size: 1.4em; }
            .navbar .nav-links { font-size: 0.75em; gap: 12px; }
            .container { padding: 30px 20px; }
            .container h1 { font-size: 2em; }
            .cart-item { flex-direction: column; align-items: center; text-align: center; padding: 20px; }
            .item-image { width: 100%; height: 200px; }
            .item-details { align-items: center; }
            .remove-btn { margin-top: 15px; }
            .footer { padding: 30px 20px; }
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    <div class="container">
        <div class="breadcrumbs">
            <a href="index.jsp">Home</a> / <a href="products">Shop</a> / <span style="opacity: 0.65;">Shopping Bag</span>
        </div>
        <% 
            String successMsg = (String) request.getAttribute("success");
            String errorMsg = (String) request.getAttribute("error");
        %>
        <% if (successMsg != null) { %>
            <div class="success-message"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="error-message"><%= errorMsg %></div>
        <% } %>
        <h1>Shopping Bag</h1>
        <% if (cart.isEmpty()) { %>
            <div class="cart-empty">
                <h2>Your bag is empty</h2>
                <p>Looks like you haven't added anything yet</p>
                <a href="products">Continue Shopping</a>
            </div>
        <% } else { %>
            <div class="cart-items">
                <% for (Map.Entry<Integer, Product> entry : productById.entrySet()) { Product p = entry.getValue(); int pid = entry.getKey(); int qty = quantityById.get(pid); %>
                    <div class="cart-item">
                        <div class="item-image">
                            <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                <a href="product?id=<%= p.getId() %>">
                                    <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                                </a>
                            <% } else { %>
                                ◇
                            <% } %>
                        </div>
                        <div class="item-details">
                            <div class="item-name"><%= p.getName() %></div>
                            <div class="item-price">$<%= String.format("%.2f", p.getPrice()) %> each</div>
                            <div class="item-qty">Qty: <%= qty %></div>
                        </div>
                        <form action="cart" method="post">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="productId" value="<%= pid %>">
                            <button type="submit" class="remove-btn">Remove</button>
                        </form>
                    </div>
                <% } %>
            </div>
            <div class="cart-summary">
                <div class="summary-row"><span>Subtotal</span><span>$<%= String.format("%.2f", total) %></span></div>
                <div class="summary-row"><span>Shipping</span><span>Free</span></div>
                <div class="summary-row total"><span>Total</span><span>$<%= String.format("%.2f", total) %></span></div>
                <a href="payment.jsp" class="checkout-btn">Proceed to Checkout</a>
                <a href="products" class="continue-shopping">← Continue Shopping</a>
            </div>
        <% } %>
    </div>
    <footer class="footer"><div class="footer-logo">DORMDEALZ</div><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
