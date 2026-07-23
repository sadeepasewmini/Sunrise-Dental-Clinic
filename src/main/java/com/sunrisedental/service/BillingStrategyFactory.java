package com.sunrisedental.service;

/**
 * Factory class to get appropriate billing strategy.
 * Design Pattern: Factory
 */
public class BillingStrategyFactory {
    
    public static BillingStrategy getStrategy(String strategyType) {
        if (strategyType == null) {
            return new StandardBillingStrategy();
        }
        
        switch (strategyType.toUpperCase()) {
            case "LOYALTY":
                return new LoyaltyBillingStrategy();
            case "SENIOR":
                return new SeniorCitizenBillingStrategy();
            case "STANDARD":
            default:
                return new StandardBillingStrategy();
        }
    }
}
