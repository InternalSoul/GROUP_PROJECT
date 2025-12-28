<%@ page import="java.util.*, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("cart");
        return;
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
    <title>Payment - OCSP</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .container { max-width: 600px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.2em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; }
        .payment-box { background: #fff; border: 1px solid #eee; padding: 50px; }
        .order-summary { margin-bottom: 40px; padding-bottom: 30px; border-bottom: 1px solid #eee; }
        .order-summary h3 { font-size: 0.9em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 20px; color: #888; }
        .order-item { display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 0.95em; }
        .order-total { display: flex; justify-content: space-between; font-size: 1.2em; font-weight: 600; margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee; }
        .payment-methods { margin-bottom: 35px; }
        .payment-methods h3 { font-size: 0.9em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 20px; color: #888; }
        .payment-option { display: flex; align-items: center; padding: 20px; border: 1px solid #eee; margin-bottom: 12px; cursor: pointer; transition: border-color 0.3s; }
        .payment-option:hover { border-color: #1a1a1a; }
        .payment-option input { margin-right: 15px; }
        .payment-option label { flex: 1; cursor: pointer; font-size: 0.95em; }
        .form-group { margin-bottom: 25px; }
        .form-group label { display: block; margin-bottom: 10px; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; color: #888; }
        .form-group input, .form-group textarea { width: 100%; padding: 16px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #1a1a1a; }
        .btn { width: 100%; padding: 18px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .btn:hover { background: #333; }
        .back-link { display: block; text-align: center; margin-top: 25px; color: #888; text-decoration: none; font-size: 0.9em; }
        .back-link:hover { color: #1a1a1a; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 80px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">OCSP</a>
    </nav>
    <div class="container">
        <h1>Checkout</h1>
        <div class="payment-box">
            <div class="order-summary">
                <h3>Order Summary</h3>
                <% for (Product p : cart) { %>
                    <div class="order-item"><span><%= p.getName() %></span><span>RM <%= String.format("%.2f", p.getPrice()) %></span></div>
                <% } %>
                <div class="order-total"><span>Total</span><span>RM <%= String.format("%.2f", total) %></span></div>
            </div>
            <form action="payment" method="post">
                <input type="hidden" name="total" value="<%= total %>">
                <div class="payment-methods">
                    <h3>Payment Method</h3>
                    <div class="payment-option">
                        <input type="radio" id="cash" name="paymentMethod" value="cash" required>
                        <label for="cash">Cash on Delivery</label>
                    </div>
                    <div class="payment-option">
                        <input type="radio" id="banking" name="paymentMethod" value="online_banking">
                        <label for="banking">Online Banking</label>
                    </div>
                </div>
                <div id="bankingDetails" style="display:none;">
                    <div class="form-group">
                        <label>Bank Name</label>
                        <input type="text" name="bankName" placeholder="e.g. Maybank, CIMB, RHB">
                    </div>
                    <div class="form-group">
                        <label>Account Number</label>
                        <input type="text" name="accountNumber" placeholder="Enter your account number">
                    </div>
                </div>
                <div class="form-group">
                    <label>Delivery Address</label>
                    <textarea name="address" rows="3" placeholder="Enter your full delivery address" required><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                </div>
                <button type="submit" class="btn">Complete Order</button>
            </form>
            <a href="cart" class="back-link">← Back to Cart</a>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">OCSP</div><p>© 2025 OCSP. All rights reserved.</p></footer>
    <script>
        document.querySelectorAll('input[name="paymentMethod"]').forEach(function(radio) {
            radio.addEventListener('change', function() {
                document.getElementById('bankingDetails').style.display = this.value === 'online_banking' ? 'block' : 'none';
            });
        });
    </script>
</body>
</html>
