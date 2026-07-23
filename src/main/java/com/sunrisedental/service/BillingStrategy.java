package com.sunrisedental.service;

/**
 * Strategy interface for calculating total bill net cost.
 * Design Pattern: Strategy
 */
public interface BillingStrategy {
    double calculateNetCost(double consultationFee, double treatmentCost, double manualDiscount);
}
