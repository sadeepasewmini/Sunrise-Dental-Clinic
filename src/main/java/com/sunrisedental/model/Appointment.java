package com.sunrisedental.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class Appointment {
    private int id;
    private String appointmentNumber;
    private String patientName;
    private String patientAddress;
    private String patientContact;
    private int dentistId;
    private int treatmentId;
    private Date appointmentDate;
    private Time appointmentTime;
    private String status;
    private Timestamp createdAt;

    // Transient fields for easy front-end display
    private String dentistName;
    private String treatmentName;

    public Appointment() {}

    public Appointment(int id, String appointmentNumber, String patientName, String patientAddress, String patientContact, 
                       int dentistId, int treatmentId, Date appointmentDate, Time appointmentTime, String status, Timestamp createdAt) {
        this.id = id;
        this.appointmentNumber = appointmentNumber;
        this.patientName = patientName;
        this.patientAddress = patientAddress;
        this.patientContact = patientContact;
        this.dentistId = dentistId;
        this.treatmentId = treatmentId;
        this.appointmentDate = appointmentDate;
        this.appointmentTime = appointmentTime;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getAppointmentNumber() { return appointmentNumber; }
    public void setAppointmentNumber(String appointmentNumber) { this.appointmentNumber = appointmentNumber; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getPatientAddress() { return patientAddress; }
    public void setPatientAddress(String patientAddress) { this.patientAddress = patientAddress; }

    public String getPatientContact() { return patientContact; }
    public void setPatientContact(String patientContact) { this.patientContact = patientContact; }

    public int getDentistId() { return dentistId; }
    public void setDentistId(int dentistId) { this.dentistId = dentistId; }

    public int getTreatmentId() { return treatmentId; }
    public void setTreatmentId(int treatmentId) { this.treatmentId = treatmentId; }

    public Date getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(Date appointmentDate) { this.appointmentDate = appointmentDate; }

    public Time getAppointmentTime() { return appointmentTime; }
    public void setAppointmentTime(Time appointmentTime) { this.appointmentTime = appointmentTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getDentistName() { return dentistName; }
    public void setDentistName(String dentistName) { this.dentistName = dentistName; }

    public String getTreatmentName() { return treatmentName; }
    public void setTreatmentName(String treatmentName) { this.treatmentName = treatmentName; }
}
