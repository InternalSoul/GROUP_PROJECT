package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.*;
import model.Product;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/cart.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        if (session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        @SuppressWarnings("unchecked")
        List<Product> cart = (List<Product>) session.getAttribute("cart");

        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        if ("add".equals(action)) {
            // Add item to cart
            String name = req.getParameter("name");
            double price = Double.parseDouble(req.getParameter("price"));
            int id = Integer.parseInt(req.getParameter("id"));
            String image = req.getParameter("image");

            Product product = new Product(id, name, price, image != null ? image : "");
            cart.add(product);

            res.sendRedirect(req.getContextPath() + "/products");

        } else if ("remove".equals(action)) {
            // Remove item from cart
            int index = Integer.parseInt(req.getParameter("index"));
            if (index >= 0 && index < cart.size()) {
                cart.remove(index);
            }
            res.sendRedirect(req.getContextPath() + "/cart");

        } else if ("clear".equals(action)) {
            // Clear cart
            cart.clear();
            res.sendRedirect(req.getContextPath() + "/cart");

        } else {
            // Default: add to cart (for backward compatibility)
            String name = req.getParameter("name");
            double price = Double.parseDouble(req.getParameter("price"));
            int id = Integer.parseInt(req.getParameter("id"));

            cart.add(new Product(id, name, price));
            res.sendRedirect(req.getContextPath() + "/products");
        }
    }
}
