package com.sunrisedental.service;

/**
 * Loyalty billing strategy: applies 10% discount on consultation fee, then deducts manual discount.
 */
public class LoyaltyBillingStrategy implements BillingStrategy {
    @Override
    public double calculateNetCost(double consultationFee, double treatmentCost, double manualDiscount) {
        double discountedConsultation = consultationFee * 0.90;
        double net = (discountedConsultation + treatmentCost) - manualDiscount;
        return net < 0 ? 0.00 : net;
    }
}
