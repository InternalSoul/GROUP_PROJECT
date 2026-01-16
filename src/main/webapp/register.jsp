<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/uitm-theme.css">
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">DORMDEALZ</a>
        <div class="nav-links"><a href="login">Login</a></div>
    </nav>
    <div class="main-content">
        <div class="register-container">
            <h2>Create Account</h2>
            <p class="subtitle">Join our community today</p>
            <% if (request.getAttribute("error") != null) { %><div class="error"><%= request.getAttribute("error") %></div><% } %>
            <form method="post" action="register">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="Choose a username" required>
                </div>
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" placeholder="Enter your email" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Create a password" required>
                </div>
                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea id="address" name="address" rows="2" placeholder="Enter your address"></textarea>
                </div>
                <div class="form-group">
                    <label for="role">Account Type</label>
                    <select id="role" name="role">
                        <option value="customer">Customer</option>
                        <option value="seller">Seller</option>
                    </select>
                </div>
                <button type="submit" class="btn">Create Account</button>
            </form>
            <div class="links">
                <p>Already have an account? <a href="login">Sign in</a></p>
                <p><a href="index.jsp">← Back to Home</a></p>
            </div>
        </div>
    </div>
    <footer class="footer"><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
