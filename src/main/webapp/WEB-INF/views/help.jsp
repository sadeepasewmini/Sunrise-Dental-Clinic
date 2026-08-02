<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<style>
    .help-header {
        text-align: center;
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 1px solid rgba(0,0,0,0.05);
    }
    .help-header h2 {
        color: var(--primary-dark, #2c3e50);
        font-weight: 700;
        margin-bottom: 10px;
        font-size: 1.8rem;
    }
    .help-header p {
        color: #7f8c8d;
        font-size: 1.05rem;
    }
    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        gap: 24px;
    }
    .kpi-card {
        background: #fff;
        border-radius: 16px;
        padding: 24px;
        border: 1px solid rgba(0,0,0,0.06);
        box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        display: flex;
        flex-direction: column;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }
    .kpi-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0; height: 4px;
        background: var(--primary, #3498db);
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    .kpi-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.08);
    }
    .kpi-card:hover::before {
        opacity: 1;
    }
    .kpi-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 16px;
    }
    .kpi-title {
        font-size: 0.85rem;
        text-transform: uppercase;
        font-weight: 700;
        color: #95a5a6;
        letter-spacing: 0.5px;
    }
    .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.4rem;
    }
    .kpi-value {
        font-size: 1.4rem;
        font-weight: 800;
        color: var(--text-main, #2c3e50);
        margin-bottom: 12px;
        line-height: 1.2;
    }
    .kpi-desc {
        font-size: 0.9rem;
        color: #7f8c8d;
        line-height: 1.6;
        flex-grow: 1;
    }
    .kpi-footer {
        margin-top: 20px;
        padding-top: 16px;
        border-top: 1px dashed rgba(0,0,0,0.1);
        font-size: 0.85rem;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .kpi-badge {
        display: inline-block;
        background: #f1f2f6;
        padding: 4px 10px;
        border-radius: 8px;
        font-size: 0.75rem;
        font-weight: 600;
        color: #2c3e50;
    }
</style>

<section class="page-section">
    <div class="content-card" style="background: transparent; box-shadow: none; border: none; padding: 0;">
        
        <div class="content-card" style="margin-bottom: 24px;">
            <div class="help-header">
                <h2><i class="fa-solid fa-chart-pie" style="color: var(--primary);"></i> Operational Guide overview</h2>
                <p>System workflow broken down into key performance steps.</p>
            </div>

            <div class="kpi-grid">
                
                <!-- Patient KPI Card -->
                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Step 01</span>
                        <div class="kpi-icon" style="background: rgba(46, 204, 113, 0.1); color: #2ecc71;">
                            <i class="fa-solid fa-users"></i>
                        </div>
                    </div>
                    <div class="kpi-value">Patient<br>Registration</div>
                    <div class="kpi-desc">
                        Register new incoming patients into the system. View and manage their contact profiles securely.
                    </div>
                    <div class="kpi-footer" style="color: #2ecc71;">
                        <i class="fa-solid fa-arrow-right"></i> Menu: Patients
                    </div>
                </div>

                <!-- Appointment KPI Card -->
                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Step 02</span>
                        <div class="kpi-icon" style="background: rgba(52, 152, 219, 0.1); color: #3498db;">
                            <i class="fa-solid fa-calendar-check"></i>
                        </div>
                    </div>
                    <div class="kpi-value">Schedule<br>Appointments</div>
                    <div class="kpi-desc">
                        Book treatments with assigned dentists. Track schedules using <span class="kpi-badge">APT-XXXX</span> tracking IDs.
                    </div>
                    <div class="kpi-footer" style="color: #3498db;">
                        <i class="fa-solid fa-arrow-right"></i> Menu: Appointments
                    </div>
                </div>

                <!-- Billing KPI Card -->
                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Step 03</span>
                        <div class="kpi-icon" style="background: rgba(155, 89, 182, 0.1); color: #9b59b6;">
                            <i class="fa-solid fa-file-invoice-dollar"></i>
                        </div>
                    </div>
                    <div class="kpi-value">Calculate<br>&amp; Bill</div>
                    <div class="kpi-desc">
                        Apply dynamic discount strategies and generate official invoices for completed treatments.
                    </div>
                    <div class="kpi-footer" style="color: #9b59b6;">
                        <i class="fa-solid fa-arrow-right"></i> Menu: Calculate & Bill
                    </div>
                </div>

                <!-- Admin KPI Card -->
                <c:if test="${currentUser.role == 'Admin'}">
                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Admin</span>
                        <div class="kpi-icon" style="background: rgba(231, 76, 60, 0.1); color: #e74c3c;">
                            <i class="fa-solid fa-shield-halved"></i>
                        </div>
                    </div>
                    <div class="kpi-value">System<br>Security</div>
                    <div class="kpi-desc">
                        Manage staff accounts, enforce SHA-256 encryption, and monitor simulated notification logs.
                    </div>
                    <div class="kpi-footer" style="color: #e74c3c;">
                        <i class="fa-solid fa-arrow-right"></i> Menu: User Management
                    </div>
                </div>
                </c:if>

            </div>
        </div>

    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
