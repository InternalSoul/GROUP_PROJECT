package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.Review;

public class ReviewServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int rating = Integer.parseInt(req.getParameter("rating"));
        String comment = req.getParameter("comment");

        Review review = new Review();
        review.setRating(rating);
        review.setComment(comment);
        review.submitReview();

        req.setAttribute("msg", "Review submitted successfully ✅");
        RequestDispatcher rd = req.getRequestDispatcher("reviewSuccess.jsp");
        rd.forward(req, res);
    }
}
