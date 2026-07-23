package com.sunrisedental.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Bill {
    private int id;
    private String appointmentNumber;
    private double consultationFee;
    private double treatmentCost;
    private double discountAmount;
    private double totalCost;
    private double netCost;
    private Date billingDate;
    private String status;
    private Timestamp createdAt;

    // Transient fields for easy front-end displays
    private String patientName;
    private String dentistName;
    private String treatmentName;

    public Bill() {}

    public Bill(int id, String appointmentNumber, double consultationFee, double treatmentCost, double discountAmount, 
                double totalCost, double netCost, Date billingDate, String status, Timestamp createdAt) {
        this.id = id;
        this.appointmentNumber = appointmentNumber;
        this.consultationFee = consultationFee;
        this.treatmentCost = treatmentCost;
        this.discountAmount = discountAmount;
        this.totalCost = totalCost;
        this.netCost = netCost;
        this.billingDate = billingDate;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getAppointmentNumber() { return appointmentNumber; }
    public void setAppointmentNumber(String appointmentNumber) { this.appointmentNumber = appointmentNumber; }

    public double getConsultationFee() { return consultationFee; }
    public void setConsultationFee(double consultationFee) { this.consultationFee = consultationFee; }

    public double getTreatmentCost() { return treatmentCost; }
    public void setTreatmentCost(double treatmentCost) { this.treatmentCost = treatmentCost; }

    public double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(double discountAmount) { this.discountAmount = discountAmount; }

    public double getTotalCost() { return totalCost; }
    public void setTotalCost(double totalCost) { this.totalCost = totalCost; }

    public double getNetCost() { return netCost; }
    public void setNetCost(double netCost) { this.netCost = netCost; }

    public Date getBillingDate() { return billingDate; }
    public void setBillingDate(Date billingDate) { this.billingDate = billingDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getDentistName() { return dentistName; }
    public void setDentistName(String dentistName) { this.dentistName = dentistName; }

    public String getTreatmentName() { return treatmentName; }
    public void setTreatmentName(String treatmentName) { this.treatmentName = treatmentName; }
}
