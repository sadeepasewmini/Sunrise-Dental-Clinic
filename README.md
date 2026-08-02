# 🏥 Sunrise Dental Clinic Web Application

[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-blue.svg)](https://jakarta.ee/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![Maven](https://img.shields.io/badge/Maven-3.x-red.svg)](https://maven.apache.org/)

**Sunrise Dental Clinic** is a full-featured Java enterprise web application designed to streamline clinic management, patient appointments, dental treatments, billing & invoicing, and administrative reporting.

---

## 📌 Project Overview

Sunrise Dental Clinic provides a secure, role-based platform for managing day-to-day dental clinic operations. Built following the **MVC Architecture** with **Jakarta EE (Servlets & JSP)** and **MySQL**, it provides seamless navigation and real-time interaction for clinic staff, dentists, and patients.

---

## ✨ Features

- 🔐 **Authentication & Authorization** — Secure login & role-based access control (Admin, Dentist, Patient, Staff).
- 📅 **Appointment Management** — Schedule, reschedule, update, and cancel appointments with status tracking.
- 👤 **Patient Portal & Profiles** — Manage patient demographics, medical histories, and active treatments.
- 🩺 **Treatment Records** — Track dental procedures, diagnoses, costs, and clinical notes.
- 💳 **Billing & Invoices** — Real-time invoice generation, payment status updates, and financial summaries.
- 📊 **Dashboard & Analytics** — Interactive dashboards showing active appointments, revenue metrics, and patient statistics.
- 🔔 **Notifications & Help Desk** — Automated alerts and user support messaging.

---

## 🛠️ Technology Stack

- **Backend:** Java 21, Jakarta Servlet API 6.0, Jakarta JSP & JSTL 3.0
- **Database:** MySQL 8.0+ (JDBC Connector 8.0.33)
- **JSON & Utilities:** Google Gson 2.10.1
- **Testing:** JUnit 4.13, Mockito 5.11
- **Build Tool:** Apache Maven
- **Server:** Apache Tomcat 10+

---

## 📁 Project Structure

```text
SunriseDentalClinic/
├── src/
│   ├── main/
│   │   ├── java/com/sunrisedental/
│   │   │   ├── config/      # DB Connection & Configuration
│   │   │   ├── dao/         # Data Access Objects (CRUD)
│   │   │   ├── filter/      # Authentication & Encoding Filters
│   │   │   ├── model/       # Data Models / JavaBeans
│   │   │   ├── service/     # Business Logic Layer
│   │   │   ├── servlet/     # Controller Servlets
│   │   │   └── util/        # Helper Functions & Validation
│   │   └── webapp/          # JSPs, CSS, JS, Assets & web.xml
│   └── test/                # JUnit & Mockito Unit Tests
├── db/                      # Database Schemas & Seed Scripts
└── pom.xml                  # Maven Dependency Configuration
```

---

## 🚀 Installation & Setup Guide

### Prerequisites
- **JDK 21** or later
- **Apache Maven 3.8+**
- **Apache Tomcat 10.1+**
- **MySQL Server 8.0+**

### 1. Database Setup
1. Open your MySQL client (e.g., MySQL Workbench or Command Line).
2. Execute the database script located in `db/schema.sql`:
   ```sql
   SOURCE db/schema.sql;
   ```

### 2. Build the Application
Clone the repository and compile using Maven:
```bash
git clone https://github.com/sadeepasewmini/Sunrise-Dental-Clinic.git
cd Sunrise-Dental-Clinic
mvn clean package
```

### 3. Deploy
Deploy the generated `SunriseDentalClinic.war` file from the `target/` directory to your Tomcat `webapps/` directory and start the server.

---

## 📝 License

This project is created for educational and professional demonstration purposes.
