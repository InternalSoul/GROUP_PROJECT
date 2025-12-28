package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import com.mycompany.oscp.model.*;

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

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

        Order order = (Order) session.getAttribute("order");
        if (order == null) {
            res.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        String method = req.getParameter("method");
        Payment payment;

        if ("Online".equalsIgnoreCase(method)) {
            OnlineBanking ob = new OnlineBanking();
            ob.setAmount(order.calcTotal());
            ob.setPaymentMethod("Online Banking");
            ob.setStatus("Pending");
            ob.setBankName(req.getParameter("bankName"));
            ob.setAccountNumber(req.getParameter("accountNumber"));
            payment = ob;
        } else {
            Cash cash = new Cash();
            cash.setAmount(order.calcTotal());
            cash.setPaymentMethod("Cash on Delivery");
            cash.setStatus("Pending");
            payment = cash;
        }

        // Process payment
        payment.processPayment();

        // Update order status
        order.setPayment(payment);
        order.setStatus(payment.getStatus());

        // Clear the cart after successful order
        session.removeAttribute("cart");

        // Store payment info for confirmation
        session.setAttribute("lastPayment", payment);

        // Redirect to order success page
        res.sendRedirect(req.getContextPath() + "/orderSuccess.jsp");
    }
}
