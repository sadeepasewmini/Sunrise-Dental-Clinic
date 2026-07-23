package com.sunrisedental.util;

import org.junit.Test;
import static org.junit.Assert.*;

public class HashUtilTest {

    @Test
    public void testSha256Hashing() {
        // Test hashing a standard string and comparing with expected hex output
        // admin123 hash: 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
        String input = "admin123";
        String expectedHash = "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9";
        
        String actualHash = HashUtil.sha256(input);
        
        assertNotNull("Hash should not be null", actualHash);
        assertEquals("SHA-256 hash does not match expected signature", expectedHash, actualHash);
    }

    @Test
    public void testHashConsistency() {
        // Verify same input yields same output (determinism)
        String input = "sunrise_dental_clinic";
        String hash1 = HashUtil.sha256(input);
        String hash2 = HashUtil.sha256(input);
        
        assertEquals("Hash output is not deterministic", hash1, hash2);
    }

    @Test
    public void testNullInput() {
        // Verify null returns null gracefully
        assertNull("Hashing null should return null", HashUtil.sha256(null));
    }
}
