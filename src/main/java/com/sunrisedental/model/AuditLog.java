package com.sunrisedental.model;

import java.sql.Timestamp;

public class AuditLog {
    private int id;
    private String username;
    private String action;
    private String details;
    private Timestamp createdAt;

    public AuditLog() {}

    public AuditLog(int id, String username, String action, String details, Timestamp createdAt) {
        this.id = id;
        this.username = username;
        this.action = action;
        this.details = details;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
