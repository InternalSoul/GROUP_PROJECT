<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DormDealz - Your Campus Marketplace</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/uitm-theme.css">
    <link rel="stylesheet" href="css/home.css">
</head>
<body>
    <jsp:include page="header.jsp" />
    <section class="hero">
        <h1>DORMDEALZ</h1>
        <p>Your Campus Marketplace</p>
        <div class="hero-buttons">
            <a href="<%= (user != null) ? "products" : "login" %>" class="btn btn-primary">
                <%= (user != null) ? "Browse" : "Get Started" %>
            </a>
            <% if (user == null) { %>
            <a href="register" class="btn btn-secondary">Sign Up</a>
            <% } %>
        </div>
    </section>
    <section class="features-section">
        <div class="features">
            <div class="feature">
                <div class="feature-icon">✦</div>
                <h3>Student Community</h3>
            </div>
            <div class="feature">
                <div class="feature-icon">◈</div>
                <h3>Great Deals</h3>
            </div>
            <div class="feature">
                <div class="feature-icon">◇</div>
                <h3>Easy Meetups</h3>
            </div>
        </div>
    </section>
    <footer class="footer">
        <div class="footer-logo">DORMDEALZ</div>
        <div class="footer-links">
            <a href="#">About Us</a>
            <a href="#">Contact</a>
            <a href="#">Privacy Policy</a>
            <a href="#">Terms & Conditions</a>
        </div>
        <p>© 2026 DormDealz. All rights reserved.</p>
    </footer>
</body>
</html>
