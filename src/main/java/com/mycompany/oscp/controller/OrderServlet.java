package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import com.mycompany.oscp.model.*;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Forward to payment page
        req.getRequestDispatcher("/payment.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            @SuppressWarnings("unchecked")
            List<Product> cart = (List<Product>) session.getAttribute("cart");

            if (cart == null || cart.isEmpty()) {
                req.setAttribute("error", "Your cart is empty");
                req.getRequestDispatcher("/cart.jsp").forward(req, res);
                return;
            }

            // Calculate total from cart
            double total = 0;
            List<OrderDetails> detailsList = new ArrayList<>();

            for (Product p : cart) {
                OrderDetails od = new OrderDetails(1, p.getPrice(), p);
                detailsList.add(od);
                total += p.getPrice();
            }

            // Create Order with list of OrderDetails
            Order order = new Order();
            order.setOrderDetails(detailsList);
            order.setStatus("Pending");
            order.setUser((User) session.getAttribute("user"));

            // Store order in session
            session.setAttribute("order", order);
            session.setAttribute("orderTotal", total);

            // Redirect to payment page
            res.sendRedirect(req.getContextPath() + "/payment.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to create order: " + e.getMessage());
            req.getRequestDispatcher("/cart.jsp").forward(req, res);
        }
    }
}
