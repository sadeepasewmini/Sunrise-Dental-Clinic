package com.sunrisedental.service;

import org.junit.Test;
import static org.junit.Assert.*;

public class BillingStrategyTest {

    @Test
    public void testStandardBillingStrategy() {
        BillingStrategy strategy = BillingStrategyFactory.getStrategy("STANDARD");
        assertTrue("Factory should return StandardBillingStrategy instance", strategy instanceof StandardBillingStrategy);

        // Consultation: 1000, Treatment: 2000, Manual Discount: 500
        // Expected: 1000 + 2000 - 500 = 2500
        double net = strategy.calculateNetCost(1000.00, 2000.00, 500.00);
        assertEquals("Standard billing calculation incorrect", 2500.00, net, 0.001);
    }

    @Test
    public void testLoyaltyBillingStrategy() {
        BillingStrategy strategy = BillingStrategyFactory.getStrategy("LOYALTY");
        assertTrue("Factory should return LoyaltyBillingStrategy instance", strategy instanceof LoyaltyBillingStrategy);

        // Consultation: 1000 (discounted 10% -> 900), Treatment: 2000, Manual Discount: 500
        // Expected: 900 + 2000 - 500 = 2400
        double net = strategy.calculateNetCost(1000.00, 2000.00, 500.00);
        assertEquals("Loyalty billing calculation incorrect", 2400.00, net, 0.001);
    }

    @Test
    public void testSeniorCitizenBillingStrategy() {
        BillingStrategy strategy = BillingStrategyFactory.getStrategy("SENIOR");
        assertTrue("Factory should return SeniorCitizenBillingStrategy instance", strategy instanceof SeniorCitizenBillingStrategy);

        // Consultation: 1000, Treatment: 2000 (discounted 15% -> 1700), Manual Discount: 500
        // Expected: 1000 + 1700 - 500 = 2200
        double net = strategy.calculateNetCost(1000.00, 2000.00, 500.00);
        assertEquals("Senior Citizen billing calculation incorrect", 2200.00, net, 0.001);
    }

    @Test
    public void testNegativeClamping() {
        BillingStrategy strategy = BillingStrategyFactory.getStrategy("STANDARD");
        
        // Discount exceeds total fee, should clamp to 0
        double net = strategy.calculateNetCost(500.00, 500.00, 1200.00);
        assertEquals("Net cost should be clamped to 0.00 if discount exceeds total", 0.00, net, 0.001);
    }

    @Test
    public void testFactoryFallback() {
        // Factory should fallback to Standard strategy for null or unknown inputs
        BillingStrategy strategyNull = BillingStrategyFactory.getStrategy(null);
        BillingStrategy strategyUnknown = BillingStrategyFactory.getStrategy("UNKNOWN_PROMO");

        assertTrue("Fallback strategy should be StandardBillingStrategy", strategyNull instanceof StandardBillingStrategy);
        assertTrue("Fallback strategy should be StandardBillingStrategy", strategyUnknown instanceof StandardBillingStrategy);
    }
}
