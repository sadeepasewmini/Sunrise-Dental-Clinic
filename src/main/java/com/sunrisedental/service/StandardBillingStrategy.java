package com.sunrisedental.service;

/**
 * Standard billing strategy: sums fees and deducts manual discount.
 */
public class StandardBillingStrategy implements BillingStrategy {
    @Override
    public double calculateNetCost(double consultationFee, double treatmentCost, double manualDiscount) {
        double net = (consultationFee + treatmentCost) - manualDiscount;
        return net < 0 ? 0.00 : net;
    }
}
