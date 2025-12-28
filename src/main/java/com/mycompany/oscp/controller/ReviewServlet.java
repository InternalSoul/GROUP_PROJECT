package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import com.mycompany.oscp.model.*;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Get product info if passed
        String productId = req.getParameter("productId");
        String productName = req.getParameter("productName");

        if (productId != null) {
            req.setAttribute("productId", productId);
        }
        if (productName != null) {
            req.setAttribute("productName", productName);
        }

        req.getRequestDispatcher("/review.jsp").forward(req, res);
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
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");
            String productId = req.getParameter("productId");

            Review review = new Review();
            review.setRating(rating);
            review.setComment(comment);

            if (productId != null && !productId.isEmpty()) {
                review.setProductId(Integer.parseInt(productId));
            }

            User user = (User) session.getAttribute("user");
            review.setUserId(user.getId());

            review.submitReview();

            req.setAttribute("msg", "Review submitted successfully! ✅");
            req.setAttribute("rating", rating);
            req.getRequestDispatcher("/reviewSuccess.jsp").forward(req, res);

        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid rating value");
            req.getRequestDispatcher("/review.jsp").forward(req, res);
        }
    }
}
