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
        System.out.println("Shop '" + shopName + "' updated by seller: " + getUsername());
    }

    public void addProduct(Product product) {
        System.out.println("Product '" + product.getName() + "' added by seller: " + getUsername());
    }

    public void updateProduct(Product product) {
        System.out.println("Product '" + product.getName() + "' updated by seller: " + getUsername());
    }

    public void deleteProduct(Product product) {
        System.out.println("Product '" + product.getName() + "' deleted by seller: " + getUsername());
    }

    public void changeOrderStatus(Order order, String status) {
        order.setStatus(status);
        System.out.println("Order " + order.getId() + " status changed to: " + status + " by seller: " + getUsername());
    }
}
