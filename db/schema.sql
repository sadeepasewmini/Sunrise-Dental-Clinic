-- Sunrise Dental Clinic Database Schema
-- MySQL Server 8.0/9.0 Compatible

CREATE DATABASE IF NOT EXISTS sunrise_dental_db;
USE sunrise_dental_db;

-- 1. Users Table (Authentication)
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL, -- SHA-256 hash
    role VARCHAR(20) NOT NULL, -- 'Admin', 'Receptionist', 'Dentist'
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.5 Patients Table
DROP TABLE IF EXISTS patients;
CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Dentists Table
DROP TABLE IF EXISTS dentists;
CREATE TABLE dentists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL
);

-- 3. Treatments Table
DROP TABLE IF EXISTS treatments;
CREATE TABLE treatments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
);

-- 4. Appointments Table
DROP TABLE IF EXISTS appointments;
CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_number VARCHAR(20) UNIQUE NOT NULL,
    patient_name VARCHAR(100) NOT NULL,
    patient_address VARCHAR(200) NOT NULL,
    patient_contact VARCHAR(15) NOT NULL,
    dentist_id INT NOT NULL,
    treatment_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending', -- 'Pending', 'Completed', 'Cancelled'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dentist_id) REFERENCES dentists(id),
    FOREIGN KEY (treatment_id) REFERENCES treatments(id)
);

-- 5. Bills Table
DROP TABLE IF EXISTS bills;
CREATE TABLE bills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_number VARCHAR(20) UNIQUE NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL,
    treatment_cost DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_cost DECIMAL(10, 2) NOT NULL,
    net_cost DECIMAL(10, 2) NOT NULL,
    billing_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Unpaid', -- 'Unpaid', 'Paid'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_number) REFERENCES appointments(appointment_number) ON DELETE CASCADE
);

-- 6. Notifications Table (SMS & Email alerts simulation log)
DROP TABLE IF EXISTS notifications;
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_number VARCHAR(20) NOT NULL,
    recipient_contact VARCHAR(100) NOT NULL,
    message_type VARCHAR(10) NOT NULL, -- 'SMS', 'Email'
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending', -- 'Pending', 'Sent', 'Failed'
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_number) REFERENCES appointments(appointment_number) ON DELETE CASCADE
);

-- =========================================================================
-- ADVANCED DATABASE FEATURES (TRIGGERS, FUNCTIONS, STORED PROCEDURES)
-- =========================================================================

-- A. FUNCTION: Calculate total cost including discounts
DROP FUNCTION IF EXISTS CalculateTotalBill;
DELIMITER //
CREATE FUNCTION CalculateTotalBill(consultation_fee DECIMAL(10,2), treatment_cost DECIMAL(10,2), discount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SET total = consultation_fee + treatment_cost - discount;
    IF total < 0 THEN
        SET total = 0.00;
    END IF;
    RETURN total;
END //
DELIMITER ;

-- B. TRIGGER: Check for Double Booking of Dentist
DROP TRIGGER IF EXISTS BeforeAppointmentInsert;
DELIMITER //
CREATE TRIGGER BeforeAppointmentInsert
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    DECLARE booking_count INT;
    
    -- Count appointments for the same dentist at the same date and time
    SELECT COUNT(*) INTO booking_count
    FROM appointments
    WHERE dentist_id = NEW.dentist_id
      AND appointment_date = NEW.appointment_date
      AND appointment_time = NEW.appointment_time
      AND status != 'Cancelled';
      
    IF booking_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Double booking error: The dentist is already booked at this date and time.';
    END IF;
END //
DELIMITER ;

-- C. STORED PROCEDURE: Generate a Bill automatically from Appointment Details
DROP PROCEDURE IF EXISTS GenerateBillForAppointment;
DELIMITER //
CREATE PROCEDURE GenerateBillForAppointment(
    IN appt_num VARCHAR(20),
    IN disc_amt DECIMAL(10,2),
    OUT new_bill_id INT
)
BEGIN
    DECLARE d_fee DECIMAL(10,2);
    DECLARE t_cost DECIMAL(10,2);
    DECLARE d_id INT;
    DECLARE t_id INT;
    DECLARE total DECIMAL(10,2);
    DECLARE net DECIMAL(10,2);
    
    -- Fetch dentist and treatment IDs
    SELECT dentist_id, treatment_id INTO d_id, t_id 
    FROM appointments WHERE appointment_number = appt_num;
    
    -- Fetch fee and cost
    SELECT consultation_fee INTO d_fee FROM dentists WHERE id = d_id;
    SELECT cost INTO t_cost FROM treatments WHERE id = t_id;
    
    -- Calculate using SQL addition and function
    SET total = d_fee + t_cost;
    SET net = CalculateTotalBill(d_fee, t_cost, disc_amt);
    
    -- Insert the bill
    INSERT INTO bills (appointment_number, consultation_fee, treatment_cost, discount_amount, total_cost, net_cost, billing_date, status)
    VALUES (appt_num, d_fee, t_cost, disc_amt, total, net, CURDATE(), 'Unpaid');
    
    SET new_bill_id = LAST_INSERT_ID();
    
    -- Update appointment status to Completed when billed
    UPDATE appointments SET status = 'Completed' WHERE appointment_number = appt_num;
END //
DELIMITER ;

-- D. TRIGGER: Automatically create notification logging when a new appointment is inserted
DROP TRIGGER IF EXISTS AfterAppointmentInsert;
DELIMITER //
CREATE TRIGGER AfterAppointmentInsert
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
    DECLARE dentist_name VARCHAR(100);
    DECLARE treatment_name VARCHAR(100);
    
    SELECT name INTO dentist_name FROM dentists WHERE id = NEW.dentist_id;
    SELECT name INTO treatment_name FROM treatments WHERE id = NEW.treatment_id;

    -- Create SMS alert log
    INSERT INTO notifications (appointment_number, recipient_contact, message_type, message, status)
    VALUES (
        NEW.appointment_number,
        NEW.patient_contact,
        'SMS',
        CONCAT('Dear ', NEW.patient_name, ', your appointment (', NEW.appointment_number, ') with ', dentist_name, ' for ', treatment_name, ' on ', NEW.appointment_date, ' at ', NEW.appointment_time, ' is confirmed. Sunrise Dental Clinic.'),
        'Pending'
    );
END //
DELIMITER ;


-- =========================================================================
-- SEED DATA (INITIAL DATA INSERTION)
-- =========================================================================

-- Seed Users (Passwords hashed with SHA-256):
-- admin / admin123 : 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
-- staff / staff123 : 10176e7b7b24d317acfcf8d2064cfd2f24e154f7b5a96603077d5ef813d6a6b6
INSERT INTO users (username, password_hash, role, full_name, email) VALUES
('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Admin', 'Clinic Administrator', 'admin@sunrisedental.lk'),
('staff', '10176e7b7b24d317acfcf8d2064cfd2f24e154f7b5a96603077d5ef813d6a6b6', 'Staff', 'Clinic Staff Member', 'staff@sunrisedental.lk');

-- Seed Dentists
INSERT INTO dentists (name, specialization, contact_number, consultation_fee) VALUES
('Dr. Sunil Perera', 'Orthodontist', '0771234567', 1500.00),
('Dr. Amanda Silva', 'Pediatric Dentist', '0777654321', 1200.00),
('Dr. Rohan de Silva', 'General Practitioner', '0719876543', 1000.00);

-- Seed Treatments
INSERT INTO treatments (name, cost) VALUES
('Teeth Cleaning', 2000.00),
('Dental Filling', 3000.00),
('Tooth Extraction', 4000.00),
('Root Canal Treatment', 15000.00),
('Dental Braces Installation', 80000.00),
('Teeth Whitening', 12000.00);
