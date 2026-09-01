<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sunrise Dental Clinic Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #bae6fd 100%);
            font-family: 'Outfit', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            color: #0f172a;
        }

        .login-wrapper {
            width: 100%;
            max-width: 1020px;
            min-height: 580px;
            margin: 24px;
            background: #ffffff;
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(8, 145, 178, 0.25);
            display: flex;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.8);
        }

        /* Left Hero Panel */
        .login-hero {
            flex: 1.1;
            background: linear-gradient(135deg, #0c4a6e 0%, #0284c7 60%, #0369a1 100%);
            padding: 48px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            color: #ffffff;
            overflow: hidden;
        }

        .login-hero::before {
            content: '';
            position: absolute;
            top: -100px;
            right: -100px;
            width: 300px;
            height: 300px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            pointer-events: none;
        }

        .login-hero::after {
            content: '';
            position: absolute;
            bottom: -80px;
            left: -80px;
            width: 250px;
            height: 250px;
            background: rgba(8, 145, 178, 0.3);
            border-radius: 50%;
            pointer-events: none;
        }

        .hero-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 2;
        }

        .hero-brand-icon {
            width: 44px;
            height: 44px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(8px);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .hero-brand-title {
            font-size: 1.35rem;
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        .hero-center {
            text-align: center;
            z-index: 2;
            margin: 24px 0;
        }

        .doctor-avatar-wrapper {
            position: relative;
            width: 160px;
            height: 160px;
            margin: 0 auto 24px;
        }

        .doctor-avatar-img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid rgba(255, 255, 255, 0.9);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.3);
            transition: transform 0.4s ease;
        }

        .doctor-avatar-wrapper:hover .doctor-avatar-img {
            transform: scale(1.04);
        }

        .avatar-badge {
            position: absolute;
            bottom: 6px;
            right: 6px;
            background: #10b981;
            color: #ffffff;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            border: 3px solid #0284c7;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }

        .hero-heading {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 8px;
            line-height: 1.3;
        }

        .hero-subtitle {
            font-size: 0.95rem;
            color: rgba(255, 255, 255, 0.85);
            line-height: 1.5;
            max-width: 340px;
            margin: 0 auto;
        }

        .hero-features {
            display: flex;
            gap: 12px;
            justify-content: center;
            z-index: 2;
            flex-wrap: wrap;
        }

        .feature-pill {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            padding: 8px 14px;
            border-radius: 20px;
            font-size: 0.82rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        /* Right Form Panel */
        .login-form-container {
            flex: 1;
            padding: 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            background: #ffffff;
        }

        .form-header {
            margin-bottom: 32px;
        }

        .form-header h2 {
            font-size: 1.75rem;
            font-weight: 700;
            color: #0c4a6e;
            margin: 0 0 6px 0;
        }

        .form-header p {
            font-size: 0.92rem;
            color: #64748b;
            margin: 0;
        }

        .form-group-custom {
            margin-bottom: 20px;
            position: relative;
        }

        .form-label-custom {
            display: block;
            font-size: 0.88rem;
            font-weight: 600;
            color: #334155;
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            color: #0891b2;
            font-size: 1.05rem;
            pointer-events: none;
        }

        .form-input-custom {
            width: 100%;
            padding: 12px 16px 12px 42px;
            font-size: 0.95rem;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            outline: none;
            transition: all 0.2s ease;
            background: #f8fafc;
            color: #0f172a;
            font-family: inherit;
        }

        .form-input-custom:focus {
            border-color: #0891b2;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(8, 145, 178, 0.12);
        }

        .password-toggle {
            position: absolute;
            right: 14px;
            color: #94a3b8;
            cursor: pointer;
            font-size: 1rem;
            transition: color 0.2s ease;
        }

        .password-toggle:hover {
            color: #0891b2;
        }

        .quick-demo-section {
            margin-top: 16px;
            margin-bottom: 24px;
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 12px;
            padding: 12px 16px;
        }

        .quick-demo-title {
            font-size: 0.8rem;
            font-weight: 600;
            color: #0369a1;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .demo-chips {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .demo-chip {
            background: #ffffff;
            border: 1px solid #7dd3fc;
            color: #0284c7;
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .demo-chip:hover {
            background: #0284c7;
            color: #ffffff;
            border-color: #0284c7;
            transform: translateY(-1px);
        }

        .btn-login-custom {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #0891b2 0%, #0284c7 100%);
            color: #ffffff;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 8px 20px rgba(8, 145, 178, 0.3);
            transition: all 0.25 ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-family: inherit;
        }

        .btn-login-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px rgba(8, 145, 178, 0.4);
            background: linear-gradient(135deg, #0e7490 0%, #0369a1 100%);
        }

        .btn-login-custom:active {
            transform: translateY(0);
        }

        .login-footer-info {
            margin-top: 24px;
            text-align: center;
            font-size: 0.8rem;
            color: #94a3b8;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }

        @media (max-width: 868px) {
            .login-wrapper {
                flex-direction: column;
                margin: 16px;
            }
            .login-hero {
                padding: 32px;
            }
            .login-form-container {
                padding: 32px 24px;
            }
        }
    </style>
</head>
<body>

    <div class="login-wrapper">
        <!-- Left Hero Banner -->
        <div class="login-hero">
            <div class="hero-brand">
                <div class="hero-brand-icon">
                    <i class="fa-solid fa-tooth"></i>
                </div>
                <div class="hero-brand-title">Sunrise Dental</div>
            </div>

            <div class="hero-center">
                <div class="doctor-avatar-wrapper">
                    <img src="${pageContext.request.contextPath}/images/login-doctor.png" alt="Sunrise Dental Doctor" class="doctor-avatar-img">
                    <div class="avatar-badge">
                        <i class="fa-solid fa-check"></i>
                    </div>
                </div>
                <div class="hero-heading">Care You Can Trust, Every Smile Matters</div>
                <div class="hero-subtitle">Comprehensive dental appointment scheduling, treatment logging, and instant automated billing system.</div>
            </div>

            <div class="hero-features">
                <div class="feature-pill"><i class="fa-solid fa-calendar-check" style="color:#38bdf8;"></i> Fast Booking</div>
                <div class="feature-pill"><i class="fa-solid fa-shield-halved" style="color:#4ade80;"></i> Secure Portal</div>
                <div class="feature-pill"><i class="fa-solid fa-receipt" style="color:#fbbf24;"></i> Auto Billing</div>
            </div>
        </div>

        <!-- Right Form Panel -->
        <div class="login-form-container">
            <div class="form-header">
                <h2>Staff Login</h2>
                <p>Enter your clinic staff credentials to access the management portal.</p>
            </div>

            <!-- Floating Toast Container -->
            <div id="toast-container" class="toast-container"></div>
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

            <c:if test="${param.logout == 'true'}">
                <script>
                    document.addEventListener("DOMContentLoaded", function() {
                        showToast("You have logged out successfully.", "success");
                    });
                </script>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <script>
                    document.addEventListener("DOMContentLoaded", function() {
                        showToast("${errorMessage}", "danger");
                    });
                </script>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">
                <div class="form-group-custom">
                    <label class="form-label-custom" for="usernameInput">Username</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-user input-icon"></i>
                        <input type="text" id="usernameInput" name="username" class="form-input-custom" value="${enteredUsername}" placeholder="Enter username" required autofocus>
                    </div>
                </div>

                <div class="form-group-custom">
                    <label class="form-label-custom" for="passwordInput">Password</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-lock input-icon"></i>
                        <input type="password" id="passwordInput" name="password" class="form-input-custom" placeholder="Enter password" required>
                        <i class="fa-solid fa-eye password-toggle" id="togglePassword" title="Show/Hide Password" onclick="togglePasswordVisibility()"></i>
                    </div>
                </div>

                <button type="submit" class="btn-login-custom" style="margin-top: 24px;">
                    <i class="fa-solid fa-right-to-bracket"></i> Sign In to Portal
                </button>
            </form>

            <div class="login-footer-info">
                <i class="fa-solid fa-lock" style="color:#10b981;"></i> 256-Bit SSL Encrypted &bull; Sunrise Dental Clinic &copy; 2026
            </div>
        </div>
    </div>

    <script>
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById('passwordInput');
            const toggleIcon = document.getElementById('togglePassword');
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                toggleIcon.classList.remove('fa-eye');
                toggleIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                toggleIcon.classList.remove('fa-eye-slash');
                toggleIcon.classList.add('fa-eye');
            }
        }
    </script>
</body>
</html>
