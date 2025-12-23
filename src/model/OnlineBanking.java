package model;

public class OnlineBanking extends Payment {
    private String bankName;
    private String number;

    public OnlineBanking() {
        super();
        this.bankName = "";
        this.number = "";
    }

    public OnlineBanking(String paymentMethod, double amount, String status, String bankName, String number) {
        super(paymentMethod, amount, status);
        this.bankName = bankName;
        this.number = number;
    }

    public String getBankName() {
        return bankName;
    }

    public String getNumber() {
        return number;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    @Override
    public void processPayment() {
        System.out.println("Processing online payment");
    }

    public void authorize() {
        System.out.println("Payment authorized");
    }
}
