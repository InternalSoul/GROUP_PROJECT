package model;

public class Seller extends User {
    private String shopName;

    public Seller(String role, String username, String email, String password, String address, String shopName) {
        super(role, username, email, password, address);
        this.shopName = shopName;
    }

    public Seller() {
        super("seller", "", "", "", "");
        this.shopName = "";
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public void updateShop() {
        System.out.println("Shop updated");
    }

    public void addProduct(Product product) {
        System.out.println("Product added");
    }

    public void updateProduct(Product product) {
        System.out.println("Product updated");
    }

    public void changeOrderStatus(Order order, String status) {
        order.setStatus(status);
    }
}
