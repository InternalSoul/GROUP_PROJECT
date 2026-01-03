package model;

public class Review {
    private int rating;
    private String comment;

    public Review() {
        this.rating = 0;
        this.comment = "";
    }

    public Review(int rating, String comment) {
        this.rating = rating;
        this.comment = comment;
    }

    public int getRating() {
        return rating;
    }

    public String getComment() {
        return comment;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void submitReview() {
        System.out.println("Review submitted");
    }
}
