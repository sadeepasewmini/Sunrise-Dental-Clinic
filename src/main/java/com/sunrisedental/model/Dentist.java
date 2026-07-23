package com.sunrisedental.model;

public class Dentist {
    private int id;
    private String name;
    private String specialization;
    private String contactNumber;
    private double consultationFee;

    public Dentist() {}

    public Dentist(int id, String name, String specialization, String contactNumber, double consultationFee) {
        this.id = id;
        this.name = name;
        this.specialization = specialization;
        this.contactNumber = contactNumber;
        this.consultationFee = consultationFee;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public double getConsultationFee() { return consultationFee; }
    public void setConsultationFee(double consultationFee) { this.consultationFee = consultationFee; }
}
