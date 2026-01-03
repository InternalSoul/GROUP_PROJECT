package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import model.Product;

public class CartServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        HttpSession session = req.getSession();
        List<Product> cart = (List<Product>) session.getAttribute("cart");

        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        String name = req.getParameter("name");
        double price = Double.parseDouble(req.getParameter("price"));
        int id = Integer.parseInt(req.getParameter("id"));

        cart.add(new Product(id, name, price));
        res.sendRedirect("products.jsp");
    }
}
