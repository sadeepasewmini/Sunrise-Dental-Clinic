package com.sunrisedental.model;

import java.sql.Timestamp;

public class Notification {
    private int id;
    private String appointmentNumber;
    private String recipientContact;
    private String messageType;
    private String message;
    private String status;
    private Timestamp sentAt;

    public Notification() {}

    public Notification(int id, String appointmentNumber, String recipientContact, String messageType, String message, String status, Timestamp sentAt) {
        this.id = id;
        this.appointmentNumber = appointmentNumber;
        this.recipientContact = recipientContact;
        this.messageType = messageType;
        this.message = message;
        this.status = status;
        this.sentAt = sentAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getAppointmentNumber() { return appointmentNumber; }
    public void setAppointmentNumber(String appointmentNumber) { this.appointmentNumber = appointmentNumber; }

    public String getRecipientContact() { return recipientContact; }
    public void setRecipientContact(String recipientContact) { this.recipientContact = recipientContact; }

    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }
}
