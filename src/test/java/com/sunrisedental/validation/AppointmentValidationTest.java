package com.sunrisedental.validation;

import org.junit.Test;
import static org.junit.Assert.*;

public class AppointmentValidationTest {

    @Test
    public void testAppointmentNumberFormat() {
        int nextSeq = 1005;
        String formattedApptNum = String.format("APT-%04d", nextSeq);

        assertEquals("Appointment number format should be APT-1005", "APT-1005", formattedApptNum);
        assertTrue("Appointment number should start with APT-", formattedApptNum.startsWith("APT-"));
    }

    @Test
    public void testDateValidation() {
        String validDate = "2026-09-15";
        String invalidDate = "15-09-2026";

        assertTrue("ISO date format YYYY-MM-DD should be valid", isValidIsoDate(validDate));
        assertFalse("Non-ISO date format should be rejected", isValidIsoDate(invalidDate));
    }

    private boolean isValidIsoDate(String dateStr) {
        if (dateStr == null) return false;
        return dateStr.matches("^\\d{4}-\\d{2}-\\d{2}$");
    }
}
