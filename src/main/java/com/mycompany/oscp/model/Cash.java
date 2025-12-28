package com.mycompany.oscp.model;

public class Cash extends Payment {
    private double cashTendered;

    public Cash() {
        super("Cash", 0.0, "Pending");
        this.cashTendered = 0;
    }

    public Cash(double amount, double cashTendered) {
        super("Cash", amount, "Pending");
        this.cashTendered = cashTendered;
    }

    public double getCashTendered() {
        return cashTendered;
    }

    public void setCashTendered(double cashTendered) {
        this.cashTendered = cashTendered;
    }

    @Override
    public void processPayment() {
        setStatus("Completed");
        System.out.println("Processing cash payment of RM " + getAmount());
    }
}
