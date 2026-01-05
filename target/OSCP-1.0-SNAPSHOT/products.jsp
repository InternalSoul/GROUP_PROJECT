<%@ page import="java.util.*, java.net.URLEncoder, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
    Set<String> productTypes = (Set<String>) request.getAttribute("productTypes");
    Set<String> sizes = (Set<String>) request.getAttribute("sizes");
    Set<String> colors = (Set<String>) request.getAttribute("colors");
    Set<String> brands = (Set<String>) request.getAttribute("brands");
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    int cartCount = (cart != null) ? cart.size() : 0;
    String currentSearch = request.getParameter("search") != null ? request.getParameter("search") : "";
    String currentSort = request.getParameter("sort") != null ? request.getParameter("sort") : "";
    String selectedProductType = request.getParameter("productType") != null ? request.getParameter("productType") : "";
    String selectedSize = request.getParameter("size") != null ? request.getParameter("size") : "";
    String selectedColor = request.getParameter("color") != null ? request.getParameter("color") : "";
    String selectedBrand = request.getParameter("brand") != null ? request.getParameter("brand") : "";
    String selectedPriceRange = request.getParameter("priceRange") != null ? request.getParameter("priceRange") : "";
    String errorMessage = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shop - Clothing Store</title>
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
        .search-form { max-width: 100%; display: flex; flex-direction: column; gap: 15px; }
        .search-main-row { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
        .search-main-row input[type="text"] { flex: 1; min-width: 220px; padding: 14px 18px; border: 1px solid #ddd; font-size: 0.95em; font-family: 'Inter', sans-serif; }
        .search-main-row input[type="text"]:focus { outline: none; border-color: #1a1a1a; }
        .search-main-row select { padding: 14px 16px; border: 1px solid #ddd; font-size: 0.9em; font-family: 'Inter', sans-serif; background: #fff; cursor: pointer; }
        .search-main-row select:focus { outline: none; border-color: #1a1a1a; }
        .search-main-row button[type="submit"] { padding: 14px 24px; background: #1a1a1a; color: #fff; border: none; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .search-main-row button[type="submit"]:hover { background: #333; }
        .clear-link { font-size: 0.8em; text-transform: uppercase; letter-spacing: 1px; color: #666; text-decoration: none; padding: 0 6px; }
        .clear-link:hover { text-decoration: underline; }
        .filter-toggle { display: inline-flex; align-items: center; gap: 6px; padding: 12px 16px; border: 1px solid #1a1a1a; background: #fff; cursor: pointer; letter-spacing: 1px; text-transform: uppercase; font-size: 0.75em; font-weight: 600; transition: background 0.2s, color 0.2s; }
        .filter-toggle:hover { background: #1a1a1a; color: #fff; }
        .filters-panel { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 15px; }
        .filters-panel.collapsed { display: none; }
        .filters-panel select { padding: 14px 16px; border: 1px solid #ddd; font-size: 0.9em; font-family: 'Inter', sans-serif; background: #fff; cursor: pointer; }
        .filters-panel select:focus { outline: none; border-color: #1a1a1a; }
        .container { max-width: 1400px; margin: 0 auto; padding: 50px 60px; }
        .products-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 30px; }
        .product-card { background: #fff; border: 1px solid #eee; transition: border-color 0.3s; cursor: pointer; }
        .product-card:hover { border-color: #1a1a1a; }
        .image-link { display: block; color: inherit; }
        .product-image { height: 300px; background: #f5f5f5; display: flex; justify-content: center; align-items: center; overflow: hidden; position: relative; cursor: pointer; }
        .product-image img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .product-placeholder { font-size: 4em; color: #ddd; }
        .product-badge { position: absolute; top: 10px; right: 10px; background: #1a1a1a; color: #fff; padding: 4px 8px; font-size: 0.65em; font-weight: 600; text-transform: uppercase; }
        .product-info { padding: 25px; text-align: center; }
        .product-name { font-size: 0.95em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 10px; color: #1a1a1a; }
        .seller-row { display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 8px; }
        .seller-avatar { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid #ddd; }
        .seller-link { display: inline-flex; align-items: center; gap: 6px; color: #1a1a1a; font-size: 0.78em; letter-spacing: 0.5px; text-transform: uppercase; text-decoration: none; }
        .seller-link:hover { text-decoration: underline; }
        .product-rating { font-size: 0.8em; color: #f39c12; margin-bottom: 10px; }
        .product-price { font-size: 1em; color: #1a1a1a; margin-bottom: 20px; }
        .details-link { display: inline-block; margin-bottom: 12px; font-size: 0.8em; letter-spacing: 1px; text-transform: uppercase; color: #1a1a1a; text-decoration: none; border: 1px solid #1a1a1a; padding: 10px 14px; transition: background 0.3s, color 0.3s; }
        .details-link:hover { background: #1a1a1a; color: #fff; }
        .add-to-cart-btn { width: 100%; padding: 14px; background: #1a1a1a; color: #fff; border: none; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .add-to-cart-btn:hover { background: #333; }
        .no-products { text-align: center; padding: 80px; color: #888; }
        .no-products h2 { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 400; margin-bottom: 15px; color: #1a1a1a; }
        .error-banner { margin: 20px 60px 0; padding: 12px 16px; border: 1px solid #ffcccc; background: #fff5f5; color: #b00020; font-size: 0.9em; }
        .products-count { font-size: 0.9em; color: #666; margin-bottom: 20px; }
        .footer { background: #1a1a1a; color: #fff; padding: 50px 60px; margin-top: 60px; text-align: center; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 20px; }
        .footer p { color: #666; font-size: 0.8em; }
        @media (max-width: 1200px) { .products-grid { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 900px) { .products-grid { grid-template-columns: repeat(2, 1fr); } .navbar { padding: 15px 30px; } .search-main-row { flex-direction: column; align-items: stretch; } .search-main-row > * { width: 100%; } .filters-panel { grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); } }
        @media (max-width: 600px) { .products-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    <div class="page-header">
        <h1>Shop All</h1>
        <p>Curated collection of premium fashion</p>
    </div>
    <% if (errorMessage != null) { %>
        <div class="error-banner"><%= errorMessage %></div>
    <% } %>
    <div class="search-section">
        <form class="search-form" action="products" method="get">
            <div class="search-main-row">
                <input type="text" name="search" placeholder="Search products..." value="<%= currentSearch %>">

                <select name="sort">
                    <option value="">Sort by</option>
                    <option value="priceAsc" <%= "priceAsc".equals(currentSort) ? "selected" : "" %>>Price: Low to High</option>
                    <option value="priceDesc" <%= "priceDesc".equals(currentSort) ? "selected" : "" %>>Price: High to Low</option>
                    <option value="nameAsc" <%= "nameAsc".equals(currentSort) ? "selected" : "" %>>Name: A to Z</option>
                    <option value="nameDesc" <%= "nameDesc".equals(currentSort) ? "selected" : "" %>>Name: Z to A</option>
                </select>

                <button type="submit">Search</button>

                <% if (!currentSearch.isEmpty() || !currentSort.isEmpty() || !selectedProductType.isEmpty() || !selectedSize.isEmpty() || !selectedColor.isEmpty() || !selectedBrand.isEmpty() || !selectedPriceRange.isEmpty()) { %>
                    <a href="products" class="clear-link">Clear</a>
                <% } %>

                <button type="button" class="filter-toggle" id="filterToggle">Filters ▾</button>
            </div>

            <div class="filters-panel" id="filterPanel">
                <% if (productTypes != null && !productTypes.isEmpty()) { %>
                <select name="productType">
                    <option value="">All Types</option>
                    <% List<String> typeList = new ArrayList<>(productTypes);
                       java.util.Collections.sort(typeList);
                       for (String t : typeList) { %>
                        <option value="<%= t %>" <%= selectedProductType.equals(t) ? "selected" : "" %>><%= t %></option>
                    <% } %>
                </select>
                <% } %>

                <% if (sizes != null && !sizes.isEmpty()) { %>
                <select name="size">
                    <option value="">All Sizes</option>
                    <% List<String> sizeList = new ArrayList<>(sizes);
                       java.util.Collections.sort(sizeList);
                       for (String s : sizeList) { %>
                        <option value="<%= s %>" <%= selectedSize.equals(s) ? "selected" : "" %>><%= s %></option>
                    <% } %>
                </select>
                <% } %>

                <% if (colors != null && !colors.isEmpty()) { %>
                <select name="color">
                    <option value="">All Colors</option>
                    <% List<String> colorList = new ArrayList<>(colors);
                       java.util.Collections.sort(colorList);
                       for (String c : colorList) { %>
                        <option value="<%= c %>" <%= selectedColor.equals(c) ? "selected" : "" %>><%= c %></option>
                    <% } %>
                </select>
                <% } %>

                <% if (brands != null && !brands.isEmpty()) { %>
                <select name="brand">
                    <option value="">All Brands</option>
                    <% List<String> brandList = new ArrayList<>(brands);
                       java.util.Collections.sort(brandList);
                       for (String b : brandList) { %>
                        <option value="<%= b %>" <%= selectedBrand.equals(b) ? "selected" : "" %>><%= b %></option>
                    <% } %>
                </select>
                <% } %>

                <select name="priceRange">
                    <option value="">All Prices</option>
                    <option value="0-50" <%= selectedPriceRange.equals("0-50") ? "selected" : "" %>>$0 - $50</option>
                    <option value="50-100" <%= selectedPriceRange.equals("50-100") ? "selected" : "" %>>$50 - $100</option>
                    <option value="100-200" <%= selectedPriceRange.equals("100-200") ? "selected" : "" %>>$100 - $200</option>
                    <option value="200" <%= selectedPriceRange.equals("200") ? "selected" : "" %>>$200+</option>
                </select>
            </div>
        </form>
    </div>
    <div class="container">
        <% if (products != null && !products.isEmpty()) { %>
            <p class="products-count">Showing <%= products.size() %> products</p>
        <% } %>
        <% if (products == null || products.isEmpty()) { %>
            <div class="no-products"><h2>No products found</h2><p>Try a different search or check back later!</p></div>
        <% } else { %>
            <div class="products-grid">
                <% for (Product p : products) { %>
                    <div class="product-card">
                        <div class="product-image">
                            <% String productUrl = request.getContextPath() + "/product?id=" + p.getId(); %>
                            <% if (p.getImage() != null && !p.getImage().isEmpty()) { %>
                                <a href="<%= productUrl %>">
                                    <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                                </a>
                            <% } else { %>
                                <a href="<%= productUrl %>">
                                    <span class="product-placeholder">◇</span>
                                </a>
                            <% } %>
                        </div>
                        <div class="product-info">
                            <h3 class="product-name"><%= p.getName() %></h3>
                            <div class="seller-row">
                                <% String sellerName = !p.getSellerUsername().isEmpty() ? p.getSellerUsername() : "Unknown"; %>
                                <% String sellerUrl = "sellerStore.jsp?seller=" + URLEncoder.encode(sellerName, "UTF-8"); %>
                                <% String avatarUrl = "https://ui-avatars.com/api/?background=111111&color=fff&name=" + URLEncoder.encode(sellerName, "UTF-8"); %>
                                <span class="seller-link" role="link" tabindex="0" style="cursor:pointer;" onclick="event.stopPropagation(); window.location.href='<%= sellerUrl %>';" onkeypress="if(event.key==='Enter'){ event.stopPropagation(); window.location.href='<%= sellerUrl %>'; }">
                                    <img class="seller-avatar" src="<%= avatarUrl %>" alt="<%= sellerName %>">
                                    <span>Shop: <%= sellerName %></span>
                                </span>
                            </div>
                            
                                <p class="product-rating">★ <%= String.format("%.1f", p.getRating()) %></p>
                            
                            <p class="product-price">$<%= String.format("%.2f", p.getPrice()) %></p>
                        </div>
                        
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
<script>
    (function() {
        const toggle = document.getElementById('filterToggle');
        const panel = document.getElementById('filterPanel');
        let open = true;
        const hasActiveFilters = '<%= (!selectedProductType.isEmpty() || !selectedSize.isEmpty() || !selectedColor.isEmpty() || !selectedBrand.isEmpty() || !selectedPriceRange.isEmpty() || !currentSort.isEmpty()) %>' === 'true';

        if (!hasActiveFilters) {
            panel.classList.add('collapsed');
            open = false;
            toggle.textContent = 'Filters ▸';
        }

        toggle.addEventListener('click', () => {
            open = !open;
            if (open) {
                panel.classList.remove('collapsed');
                toggle.textContent = 'Filters ▾';
            } else {
                panel.classList.add('collapsed');
                toggle.textContent = 'Filters ▸';
            }
        });
    })();
</script>
</html>
