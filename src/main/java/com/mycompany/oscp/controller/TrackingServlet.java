package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import com.mycompany.oscp.model.*;

@WebServlet("/tracking")
public class TrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Order order = (Order) session.getAttribute("order");

        if (order != null) {
            req.setAttribute("orderStatus", order.getStatus());
            req.setAttribute("orderDate", order.getDate());
            req.setAttribute("orderTotal", order.calcTotal());
        } else {
            req.setAttribute("orderStatus", "No active orders");
        }

        req.getRequestDispatcher("/tracking.jsp").forward(req, res);
    }
}
