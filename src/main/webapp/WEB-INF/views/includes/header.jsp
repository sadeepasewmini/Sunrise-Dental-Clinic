<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sunrise Dental Clinic - Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-brand" style="margin-bottom: 24px;">
            <div style="background: rgba(255,255,255,0.2); width:45px; height:45px; border-radius:12px; display:flex; align-items:center; justify-content:center; backdrop-filter:blur(5px);">
                <i class="fa-solid fa-tooth" style="font-size:1.6rem; color:#fff;"></i>
            </div>
            <div class="brand-text">
                <h2 style="font-size:1.15rem; font-weight:700; color:#fff; margin:0; letter-spacing: -0.3px;">Sunrise Dental</h2>
                <span style="font-size:0.75rem; color:rgba(255,255,255,0.8); font-weight:500;">Clinic Management</span>
            </div>
        </div>

        <div style="width:100%; border-radius:12px; overflow:hidden; margin-bottom:20px; border:1px solid rgba(255,255,255,0.15); box-shadow:0 4px 15px rgba(0,0,0,0.1);">
            <img src="${pageContext.request.contextPath}/images/clinic-banner.svg" alt="Sunrise Dental Clinic" style="width:100%; height:110px; object-fit:cover; display:block;">
        </div>

        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${activeMenu == 'dashboard' ? 'active' : ''}">
                <i class="fa-solid fa-chart-line"></i> Dashboard
            </a>
            
            <!-- Patient Management -->
            <div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:1px; color:rgba(255,255,255,0.5); margin:15px 0 5px 15px; font-weight:600;">Patients</div>
            <a href="${pageContext.request.contextPath}/patients?action=register" class="nav-item ${activeMenu == 'register_patient' ? 'active' : ''}">
                <i class="fa-solid fa-user-plus"></i> Register Patient
            </a>
            <a href="${pageContext.request.contextPath}/patients?action=list" class="nav-item ${activeMenu == 'patients' ? 'active' : ''}">
                <i class="fa-solid fa-users"></i> Patient List
            </a>

            <div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:1px; color:rgba(255,255,255,0.5); margin:15px 0 5px 15px; font-weight:600;">Appointments</div>
            <a href="${pageContext.request.contextPath}/appointments?action=register" class="nav-item ${activeMenu == 'register' ? 'active' : ''}">
                <i class="fa-solid fa-calendar-plus"></i> Register Appt
            </a>
            <a href="${pageContext.request.contextPath}/appointments?action=search" class="nav-item ${activeMenu == 'search' ? 'active' : ''}">
                <i class="fa-solid fa-magnifying-glass"></i> Search Appt
            </a>
            <a href="${pageContext.request.contextPath}/billing" class="nav-item ${activeMenu == 'billing' ? 'active' : ''}">
                <i class="fa-solid fa-file-invoice-dollar"></i> Calculate &amp; Bill
            </a>
            
            <c:if test="${currentUser.role == 'Admin'}">
                <a href="${pageContext.request.contextPath}/notifications" class="nav-item ${activeMenu == 'notifications' ? 'active' : ''}">
                    <i class="fa-solid fa-bell"></i> Alerts &amp; Logs
                </a>
                <a href="${pageContext.request.contextPath}/users" class="nav-item ${activeMenu == 'users' ? 'active' : ''}">
                    <i class="fa-solid fa-users-gear"></i> User Management
                </a>
            </c:if>

            <a href="${pageContext.request.contextPath}/help" class="nav-item ${activeMenu == 'help' ? 'active' : ''}">
                <i class="fa-solid fa-circle-question"></i> Help &amp; Guide
            </a>
        </nav>

        <div style="margin-top:auto; padding-top:20px; border-top:1px solid rgba(255,255,255,0.1);">
            <div style="font-size:0.8rem; color:rgba(255,255,255,0.7); margin-bottom:8px;">
                Logged in as: <strong style="color:#fff;">${currentUser.fullName}</strong> (${currentUser.role})
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary" style="width:100%; text-align:center; padding:8px; font-size:0.85rem;">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </a>
        </div>
    </aside>

    <main class="main-content">
        <header class="topbar">
            <h1 class="page-title">Sunrise Dental Clinic</h1>
            <div style="display:flex; align-items:center; gap:12px;">
                <span class="badge badge-completed">${currentUser.role}</span>
                <span style="font-size:0.9rem; font-weight:600; color:var(--text-main);">${currentUser.username}</span>
            </div>
        </header>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success" style="margin-bottom:16px;">
                <i class="fa-solid fa-circle-check"></i> ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger" style="margin-bottom:16px;">
                <i class="fa-solid fa-triangle-exclamation"></i> ${sessionScope.errorMessage}
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" style="margin-bottom:16px;">
                <i class="fa-solid fa-triangle-exclamation"></i> ${errorMessage}
            </div>
        </c:if>
