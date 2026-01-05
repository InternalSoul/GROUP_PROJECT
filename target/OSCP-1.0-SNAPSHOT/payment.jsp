<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.mycompany.oscp.model.*, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    double total = 0;
    if (cart != null) {
        for (Product p : cart) {
            total += p.getPrice();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - Clothing Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container { max-width: 800px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; }
        .payment-box { background: #fff; border: 1px solid #eee; padding: 50px; }
        .order-summary { background: #f5f5f5; padding: 30px; margin-bottom: 40px; }
        .order-summary h2 { font-family: 'Playfair Display', serif; font-size: 1.3em; font-weight: 400; margin-bottom: 20px; letter-spacing: 1px; }
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 12px; }
        .summary-row.total { font-size: 1.3em; font-weight: 600; padding-top: 15px; border-top: 1px solid #ddd; margin-top: 15px; }
        .form-group { margin-bottom: 30px; }
        .form-group label { display: block; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 12px; color: #1a1a1a; }
        .form-group select { width: 100%; padding: 16px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; background: #fff; }
        .form-group select:focus { outline: none; border-color: #1a1a1a; }
        .pay-btn { width: 100%; padding: 18px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .pay-btn:hover { background: #333; }
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
        <h1>Payment</h1>
        <div class="payment-box">
            <div class="order-summary">
                <h2>Order Summary</h2>
                <div class="summary-row"><span>Subtotal</span><span>$<%= String.format("%.2f", total) %></span></div>
                <div class="summary-row"><span>Shipping</span><span>Free</span></div>
                <div class="summary-row total"><span>Total</span><span>$<%= String.format("%.2f", total) %></span></div>
            </div>
            <form action="payment" method="post">
                <div class="form-group">
                    <label for="method">Payment Method</label>
                    <select name="method" id="method" required>
                        <option value="">Select payment method</option>
                        <option value="Online">Online Banking</option>
                        <option value="Cash">Cash on Delivery</option>
                        <option value="Card">Credit/Debit Card</option>
                    </select>
                </div>
                <button type="submit" class="pay-btn">Complete Payment</button>
                <a href="cart" class="back-link">← Back to Cart</a>
            </form>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
