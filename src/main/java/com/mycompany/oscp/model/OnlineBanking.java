package com.mycompany.oscp.model;

public class OnlineBanking extends Payment {
    private String bankName;
    private String accountNumber;

    public OnlineBanking() {
        super("Online Banking", 0.0, "Pending");
        this.bankName = "";
        this.accountNumber = "";
    }

    public OnlineBanking(double amount, String bankName, String accountNumber) {
        super("Online Banking", amount, "Pending");
        this.bankName = bankName;
        this.accountNumber = accountNumber;
    }

    public String getBankName() {
        return bankName;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    @Override
    public void processPayment() {
        setStatus("Completed");
        System.out.println("Processing online banking payment of RM " + getAmount());
    }

    public void authorize() {
        System.out.println("Payment authorized for bank: " + bankName);
    }
}
