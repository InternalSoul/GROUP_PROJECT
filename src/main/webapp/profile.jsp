<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    
    String successMsg = (String) session.getAttribute("success");
    String errorMsg = (String) session.getAttribute("error");
    if (successMsg != null) session.removeAttribute("success");
    if (errorMsg != null) session.removeAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .top-bar { background: #1a1a1a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container { max-width: 800px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; }
        .success-message { background: #f0fff4; border: 1px solid #c6f6d5; color: #22543d; padding: 14px 18px; border-radius: 8px; margin-bottom: 20px; }
        .error-message { background: #fff5f5; border: 1px solid #ffcccc; color: #b00020; padding: 14px 18px; border-radius: 8px; margin-bottom: 20px; }
        .profile-card { background: #fff; border: 1px solid #eee; padding: 40px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); animation: slideInUp 0.6s ease-out; }
        @keyframes slideInUp { from { opacity: 0; transform: translateY(40px); } to { opacity: 1; transform: translateY(0); } }
        .section { margin-bottom: 40px; animation: fadeIn 0.8s ease-out backwards; }
        .section:nth-child(1) { animation-delay: 0.2s; }
        .section:nth-child(2) { animation-delay: 0.4s; }
        .section:nth-child(3) { animation-delay: 0.6s; }
        @keyframes fadeIn { from { opacity: 0; transform: translateX(-20px); } to { opacity: 1; transform: translateX(0); } }
        .section:last-child { margin-bottom: 0; }
        .section h2 { font-family: 'Playfair Display', serif; font-size: 1.5em; font-weight: 400; letter-spacing: 1px; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee; }
        .form-row { display: grid; gap: 20px; margin-bottom: 20px; }
        .form-row.two-col { grid-template-columns: 1fr 1fr; }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 0.85em; font-weight: 600; letter-spacing: 0.5px; text-transform: uppercase; margin-bottom: 8px; color: #555; }
        .form-group input, .form-group textarea { padding: 14px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; border-radius: 6px; transition: border-color 0.2s; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #1a1a1a; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(26,26,26,0.1); }
        .form-group input:read-only { background: #f5f5f5; color: #888; cursor: not-allowed; }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-group small { color: #888; font-size: 0.85em; margin-top: 5px; }
        .button-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn { padding: 14px 35px; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.3s; border-radius: 6px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; border: none; }
        .btn-primary { background: #1a1a1a; color: #fff; }
        .btn-primary:hover { background: #333; }
        .btn-secondary { background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; }
        .btn-secondary:hover { background: #f5f5f5; }
        .info-badge { display: inline-block; padding: 6px 12px; background: #e0e7ff; color: #3730a3; border-radius: 999px; font-size: 0.8em; font-weight: 600; letter-spacing: 0.5px; text-transform: uppercase; margin-bottom: 20px; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 80px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
        @media (max-width: 768px) {
            .navbar { padding: 15px 30px; flex-wrap: wrap; }
            .container { padding: 40px 20px; }
            h1 { font-size: 2em; }
            .profile-card { padding: 30px 20px; }
            .form-row.two-col { grid-template-columns: 1fr; }
            .button-group { flex-direction: column; }
            .btn { width: 100%; }
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    <div class="container">
        <h1>My Profile</h1>
        
        <% if (successMsg != null) { %>
        <div class="success-message"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="error-message"><%= errorMsg %></div>
        <% } %>

        <div class="profile-card">
            <div class="info-badge"><%= user.getRole() %></div>
            
            <form action="profile" method="post">
                <div class="section">
                    <h2>Account Information</h2>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">Username</label>
                            <input type="text" id="username" name="username" value="<%= user.getUsername() %>" readonly>
                            <small>Username cannot be changed</small>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" value="<%= user.getEmail() != null ? user.getEmail() : "" %>" required>
                        </div>
                    </div>
                </div>

                <div class="section">
                    <h2>Contact Information</h2>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" id="phone" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" placeholder="555-0123">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="address">Address</label>
                            <textarea id="address" name="address" placeholder="Enter your full address"><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                        </div>
                    </div>
                </div>

                <div class="section">
                    <h2>Change Password</h2>
                    <small style="display: block; margin-bottom: 15px; color: #888;">Leave blank if you don't want to change your password</small>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="currentPassword">Current Password</label>
                            <input type="password" id="currentPassword" name="currentPassword" placeholder="Enter current password">
                        </div>
                    </div>
                    <div class="form-row two-col">
                        <div class="form-group">
                            <label for="newPassword">New Password</label>
                            <input type="password" id="newPassword" name="newPassword" placeholder="Enter new password">
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password">
                        </div>
                    </div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                    <a href="<%= "customer".equals(user.getRole()) ? "products" : "sellerDashboard" %>" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">DORMDEALZ</div><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
