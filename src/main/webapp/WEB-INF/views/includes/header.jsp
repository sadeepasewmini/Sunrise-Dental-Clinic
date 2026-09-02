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
                <a href="${pageContext.request.contextPath}/dentists" class="nav-item ${activeMenu == 'dentists' ? 'active' : ''}">
                    <i class="fa-solid fa-user-doctor"></i> Dentists / Doctors
                </a>
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

    <div id="sidebarBackdrop" class="sidebar-backdrop" onclick="toggleMobileMenu(false)"></div>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center; gap:12px;">
                <button type="button" id="mobileNavToggle" class="mobile-nav-toggle" onclick="toggleMobileMenu()" aria-label="Toggle Navigation">
                    <i class="fa-solid fa-bars"></i>
                </button>
                <h1 class="page-title">Sunrise Dental Clinic</h1>
            </div>
            <div style="display:flex; align-items:center; gap:12px;">
                <span class="badge badge-completed">${currentUser.role}</span>
                <span class="user-name-label" style="font-size:0.9rem; font-weight:600; color:var(--text-main);">${currentUser.username}</span>
            </div>
        </header>

        <!-- Floating Toast Notification Container -->
        <div id="toast-container" class="toast-container"></div>

        <!-- Custom Delete Confirmation Modal -->
        <div id="confirmModalOverlay" class="custom-modal-overlay">
            <div class="custom-modal-card">
                <div class="custom-modal-icon">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                <div class="custom-modal-title">Confirm User Deletion</div>
                <div class="custom-modal-body" id="confirmModalBody">
                    Are you sure you want to delete this user account? This action cannot be undone.
                </div>
                <div class="custom-modal-actions">
                    <button type="button" class="custom-modal-btn custom-modal-btn-cancel" onclick="closeConfirmModal()">Cancel</button>
                    <button type="button" id="confirmModalDeleteBtn" class="custom-modal-btn custom-modal-btn-confirm"><i class="fa-solid fa-trash"></i> Yes, Delete User</button>
                </div>
            </div>
        </div>

        <script>
            function toggleMobileMenu(forceState) {
                const sidebar = document.querySelector('.sidebar');
                const backdrop = document.getElementById('sidebarBackdrop');
                if (!sidebar || !backdrop) return;
                
                const isCurrentlyActive = sidebar.classList.contains('active');
                const newState = (typeof forceState === 'boolean') ? forceState : !isCurrentlyActive;
                
                if (newState) {
                    sidebar.classList.add('active');
                    backdrop.classList.add('active');
                    document.body.style.overflow = 'hidden';
                } else {
                    sidebar.classList.remove('active');
                    backdrop.classList.remove('active');
                    document.body.style.overflow = '';
                }
            }

            let activeDeleteAction = null;

            function openDeleteConfirmModal(target, username) {
                if (typeof target === 'function') {
                    activeDeleteAction = target;
                } else if (typeof target === 'string') {
                    activeDeleteAction = function() {
                        const form = document.getElementById(target);
                        if (form) form.submit();
                    };
                } else {
                    activeDeleteAction = null;
                }

                const bodyEl = document.getElementById('confirmModalBody');
                if (bodyEl) {
                    bodyEl.innerHTML = 'Are you sure you want to delete user <strong>' + (username || 'this user') + '</strong>? This action cannot be undone.';
                }
                const overlay = document.getElementById('confirmModalOverlay');
                if (overlay) {
                    overlay.classList.add('active');
                }
            }

            function closeConfirmModal() {
                const overlay = document.getElementById('confirmModalOverlay');
                if (overlay) {
                    overlay.classList.remove('active');
                }
                activeDeleteAction = null;
            }

            document.addEventListener("DOMContentLoaded", function() {
                const confirmBtn = document.getElementById('confirmModalDeleteBtn');
                if (confirmBtn) {
                    confirmBtn.addEventListener('click', function() {
                        if (typeof activeDeleteAction === 'function') {
                            activeDeleteAction();
                        }
                        closeConfirmModal();
                    });
                }
            });
        </script>

        <script>
            function showToast(message, type, duration) {
                if (!type) type = 'success';
                if (!duration) duration = 4500;
                if (!message || typeof message !== 'string' || !message.trim()) return;

                let container = document.getElementById('toast-container');
                if (!container) {
                    container = document.createElement('div');
                    container.id = 'toast-container';
                    container.className = 'toast-container';
                    document.body.appendChild(container);
                }

                const toast = document.createElement('div');
                toast.className = 'toast-popup toast-' + type;

                let iconClass = 'fa-circle-check';
                if (type === 'danger' || type === 'error') iconClass = 'fa-triangle-exclamation';
                else if (type === 'info') iconClass = 'fa-circle-info';

                toast.innerHTML = 
                    '<div class="toast-content">' +
                        '<i class="fa-solid ' + iconClass + ' toast-icon"></i>' +
                        '<span>' + message + '</span>' +
                    '</div>' +
                    '<button class="toast-close" onclick="dismissToast(this.parentElement)" title="Close">&times;</button>';

                container.appendChild(toast);

                if (duration > 0) {
                    setTimeout(function() {
                        dismissToast(toast);
                    }, duration);
                }
            }

            function dismissToast(toast) {
                if (!toast || toast.classList.contains('toast-hiding')) return;
                toast.classList.add('toast-hiding');
                setTimeout(function() {
                    if (toast && toast.parentElement) {
                        toast.parentElement.removeChild(toast);
                    }
                }, 300);
            }
        </script>

        <c:if test="${not empty sessionScope.successMessage}">
            <script>
                window.addEventListener("DOMContentLoaded", function() {
                    showToast("${sessionScope.successMessage}", "success");
                });
            </script>
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <script>
                window.addEventListener("DOMContentLoaded", function() {
                    showToast("${sessionScope.errorMessage}", "danger");
                });
            </script>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <c:if test="${not empty errorMessage}">
            <script>
                window.addEventListener("DOMContentLoaded", function() {
                    showToast("${errorMessage}", "danger");
                });
            </script>
        </c:if>

        <c:if test="${not empty sessionScope.infoMessage}">
            <script>
                window.addEventListener("DOMContentLoaded", function() {
                    showToast("${sessionScope.infoMessage}", "info");
                });
            </script>
            <c:remove var="infoMessage" scope="session" />
        </c:if>


