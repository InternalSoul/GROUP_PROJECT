package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import com.mycompany.oscp.model.*;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Check if user is logged in
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");

            Review review = new Review();
            review.setRating(rating);
            review.setComment(comment);
            review.submitReview();

            req.setAttribute("msg", "Review submitted successfully ✅");
            req.getRequestDispatcher("/reviewSuccess.jsp").forward(req, res);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid rating");
            req.getRequestDispatcher("/review.jsp").forward(req, res);
        }
    }
}
