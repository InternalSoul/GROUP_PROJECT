<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/uitm-theme.css">
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">DORMDEALZ</a>
        <div class="nav-links"><a href="register">Register</a></div>
    </nav>
    <div class="main-content">
        <div class="login-container">
            <h2>Welcome Back</h2>
            <p class="subtitle">Sign in to your account</p>
            <% if (request.getAttribute("error") != null) { %><div class="error"><%= request.getAttribute("error") %></div><% } %>
            <% if (request.getAttribute("success") != null) { %><div class="success"><%= request.getAttribute("success") %></div><% } %>
            <form method="post" action="login">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="Enter your username" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                </div>
                <button type="submit" class="btn">Sign In</button>
            </form>
            <div class="links">
                <p>Don't have an account? <a href="register">Create one</a></p>
                <p><a href="index.jsp">← Back to Home</a></p>
            </div>
        </div>
    </div>
    <footer class="footer"><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
