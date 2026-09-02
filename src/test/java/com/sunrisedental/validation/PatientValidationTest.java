package com.sunrisedental.validation;

import org.junit.Test;
import static org.junit.Assert.*;

public class PatientValidationTest {

    @Test
    public void testValidPhoneNumber() {
        String validPhone1 = "0771234567";
        String validPhone2 = "0719876543";

        assertTrue("Valid Sri Lankan phone number should pass regex", isValidPhoneNumber(validPhone1));
        assertTrue("Valid Sri Lankan phone number should pass regex", isValidPhoneNumber(validPhone2));
    }

    @Test
    public void testInvalidPhoneNumber() {
        String invalidShort = "077123";
        String invalidChars = "077ABC1234";
        String invalidPrefix = "0331234567";

        assertFalse("Short phone number should be rejected", isValidPhoneNumber(invalidShort));
        assertFalse("Alphabetic phone number should be rejected", isValidPhoneNumber(invalidChars));
        assertFalse("Non-mobile prefix should be rejected", isValidPhoneNumber(invalidPrefix));
    }

    @Test
    public void testPatientNameSanitization() {
        String rawName = "   Dr. Kamal Perera   ";
        String sanitized = sanitizeName(rawName);

        assertEquals("Name should be trimmed of leading/trailing whitespace", "Dr. Kamal Perera", sanitized);
    }

    private boolean isValidPhoneNumber(String phone) {
        if (phone == null) return false;
        return phone.matches("^07[0-9]{8}$");
    }

    private String sanitizeName(String name) {
        if (name == null) return "";
        return name.trim();
    }
}
