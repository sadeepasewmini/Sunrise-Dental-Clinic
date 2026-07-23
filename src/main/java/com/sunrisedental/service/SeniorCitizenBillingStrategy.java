package com.sunrisedental.service;

/**
 * Senior Citizen billing strategy: applies 15% discount on treatment cost, then deducts manual discount.
 */
public class SeniorCitizenBillingStrategy implements BillingStrategy {
    @Override
    public double calculateNetCost(double consultationFee, double treatmentCost, double manualDiscount) {
        double discountedTreatment = treatmentCost * 0.85;
        double net = (consultationFee + discountedTreatment) - manualDiscount;
        return net < 0 ? 0.00 : net;
    }
}
