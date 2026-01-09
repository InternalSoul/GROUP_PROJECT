package model;

public class Cash extends Payment {
    private int cashTendered;

    public Cash() {
        super("Cash", 0.0, "Pending");
        this.cashTendered = 0;
    }

    public Cash(double amount, int cashTendered) {
        super("Cash", amount, "Pending");
        this.cashTendered = cashTendered;
    }

    public int getCashTendered() {
        return cashTendered;
    }

    public void setCashTendered(int cashTendered) {
        this.cashTendered = cashTendered;
    }

    @Override
    public void processPayment() {
        System.out.println("Processing cash payment");
    }
}
