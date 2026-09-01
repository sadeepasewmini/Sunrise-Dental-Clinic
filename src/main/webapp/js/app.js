// Sunrise Dental Clinic - SPA Application Script
let currentUser = null;

// Global Toast Popup Notification System
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
    setTimeout(() => {
        if (toast && toast.parentElement) {
            toast.parentElement.removeChild(toast);
        }
    }, 300);
}

document.addEventListener("DOMContentLoaded", () => {
    checkAuthStatus();
    // Set default date to today in registration form
    const dateInput = document.getElementById("appt-appointmentDate");
    if (dateInput) {
        const today = new Date().toISOString().split('T')[0];
        dateInput.min = today;
        dateInput.value = today;
    }
});


// ==========================================
// 1. AUTHENTICATION SERVICES
// ==========================================
async function checkAuthStatus() {
    try {
        const res = await fetch("api/auth/status");
        const data = await res.json();
        
        if (data.authenticated) {
            currentUser = data.user;
            showDashboard();
        } else {
            showLoginScreen();
        }
    } catch (e) {
        console.error("Authentication check failed", e);
        showLoginScreen();
    }
}

async function handleLogin(event) {
    event.preventDefault();
    const alertBox = document.getElementById("login-alert");
    alertBox.style.display = "none";

    const usernameInput = document.getElementById("login-username").value;
    const passwordInput = document.getElementById("login-password").value;

    try {
        const res = await fetch("api/auth/login", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ username: usernameInput, password: passwordInput })
        });
        
        const data = await res.json();
        
        if (data.success) {
            currentUser = data.user;
            showToast("Welcome back, " + currentUser.fullName + "! Login successful.", "success");
            showDashboard();
        } else {
            showToast(data.message || "Invalid login credentials.", "danger");
        }
    } catch (e) {
        showToast("Error connecting to login server.", "danger");
        console.error(e);
    }
}

async function handleLogout(event) {
    if (event) event.preventDefault();
    try {
        await fetch("api/auth/logout", { method: "POST" });
        currentUser = null;
        showLoginScreen();
    } catch (e) {
        console.error("Logout failed", e);
    }
}

function showLoginScreen() {
    document.getElementById("login-screen").style.display = "flex";
    document.getElementById("app-screen").style.display = "none";
}

function showDashboard() {
    document.getElementById("login-screen").style.display = "none";
    document.getElementById("app-screen").style.display = "flex";
    
    // Set user widgets
    document.getElementById("nav-username").innerText = currentUser.fullName;
    document.getElementById("nav-role").innerText = currentUser.role + " Portal";
    document.getElementById("nav-avatar").innerText = currentUser.fullName.charAt(0);
    
    // Update footer/headers
    document.getElementById("dashboard-date").innerText = new Date().toDateString();

    // Load master lookup lists and dashboard data
    loadDropdownData();
    loadDashboardAnalytics();
    loadNotifications();
    applyRolePermissions();
    
    switchSection("dashboard");
}

function applyRolePermissions() {
    const isStaff = currentUser && currentUser.role.toLowerCase() === "staff";
    
    // 1. Revenue Metric Card (Restricted for Staff)
    const revenueVal = document.getElementById("metric-revenue");
    if (revenueVal) {
        if (isStaff) {
            revenueVal.innerText = "🔒 Admin Only";
            revenueVal.style.fontSize = "1rem";
            revenueVal.style.color = "var(--text-muted)";
        }
    }

    // 2. Revenue by Dentist Chart (Hidden for Staff)
    const dentistChartCard = document.getElementById("report-dentist-revenue")?.closest(".chart-card");
    if (dentistChartCard) {
        dentistChartCard.style.display = isStaff ? "none" : "block";
    }

    // 3. Dispatch Notification Queue Button (Admin Only)
    const dispatchBtn = document.querySelector("button[onclick='triggerNotificationDispatch()']");
    if (dispatchBtn) {
        dispatchBtn.style.display = isStaff ? "none" : "inline-flex";
    }

    // 4. User Management Menu Item (Admin Only)
    const userMenuItem = document.getElementById("menu-item-users");
    if (userMenuItem) {
        userMenuItem.style.display = isStaff ? "none" : "block";
    }
}

// ==========================================
// 2. SIDEBAR SECTION SWITCHER
// ==========================================
const sectionTitles = {
    dashboard: "Dashboard",
    register: "Register New Appointment",
    search: "Search Appointment",
    billing: "Calculate & Bill",
    notifications: "Alerts & Notification Logs",
    users: "User Management (Admin Only)",
    audit: "Audit Trail & System Activity Logs",
    help: "Help & Guide"
};

function switchSection(sectionId) {
    // Toggle active classes on page content
    const sections = document.querySelectorAll(".page-section");
    sections.forEach(sec => sec.classList.remove("active"));
    
    const targetSection = document.getElementById(`section-${sectionId}`);
    if (targetSection) targetSection.classList.add("active");

    // Toggle active classes on sidebar menu items
    const menuItems = document.querySelectorAll(".menu-item");
    menuItems.forEach(item => item.classList.remove("active"));
    const matched = Array.from(menuItems).find(el => el.getAttribute("onclick").includes(sectionId));
    if (matched) matched.classList.add("active");

    // Update topbar title
    const titleEl = document.getElementById("topbar-title");
    if (titleEl) titleEl.innerText = sectionTitles[sectionId] || "Dashboard";

    // Perform specific section reloads
    if (sectionId === "dashboard") {
        loadDashboardAnalytics();
    } else if (sectionId === "notifications") {
        loadNotifications();
    } else if (sectionId === "users") {
        loadUsers();
    } else if (sectionId === "audit") {
        loadAuditLogs();
    }
}

// ==========================================
// 3. MASTER LIST LOADER
// ==========================================
let dentistsList = [];
let treatmentsList = [];
let registeredPatientsList = [];

async function loadDropdownData() {
    try {
        const [dentistsRes, treatmentsRes, patientsRes] = await Promise.all([
            fetch("api/dentists"),
            fetch("api/treatments"),
            fetch("api/patients").catch(() => null)
        ]);
        
        dentistsList = await dentistsRes.json();
        treatmentsList = await treatmentsRes.json();

        if (patientsRes && patientsRes.ok) {
            registeredPatientsList = await patientsRes.json();
            setupPatientAutoFill();
        }

        // Populate dropdowns in Register screen
        const dentistSel = document.getElementById("appt-dentistId");
        if (dentistSel) {
            dentistSel.innerHTML = '<option value="">Select Dentist</option>';
            dentistsList.forEach(d => {
                const fee = d.consultationFee ? d.consultationFee.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}) : "0.00";
                dentistSel.innerHTML += `<option value="${d.id}">${d.name} (${d.specialization}) - LKR ${fee}</option>`;
            });
        }

        const treatmentSel = document.getElementById("appt-treatmentId");
        if (treatmentSel) {
            treatmentSel.innerHTML = '<option value="">Select Treatment</option>';
            treatmentsList.forEach(t => {
                treatmentSel.innerHTML += `<option value="${t.id}">${t.name} - LKR ${t.cost}</option>`;
            });
        }
        
    } catch (e) {
        console.error("Failed to load master lookup lists", e);
    }
}

function setupPatientAutoFill() {
    const datalist = document.getElementById("spaPatientsDatalist");
    if (datalist && registeredPatientsList.length > 0) {
        datalist.innerHTML = registeredPatientsList.map(p => 
            '<option value="' + p.name + '">' + (p.contactNumber || '') + ' | ' + (p.address || '') + '</option>'
        ).join('');
    }

    const nameInput = document.getElementById("appt-patientName");
    const contactInput = document.getElementById("appt-patientContact");
    const addressInput = document.getElementById("appt-patientAddress");
    const allergiesInput = document.getElementById("appt-allergies");
    const conditionsInput = document.getElementById("appt-medicalConditions");
    const badge = document.getElementById("spaAutoFillBadge");

    if (nameInput && !nameInput.dataset.autofillAttached) {
        nameInput.dataset.autofillAttached = "true";

        const checkAndAutoFillSPA = function() {
            const val = nameInput.value.trim().toLowerCase();
            if (!val) {
                if (badge) badge.style.display = "none";
                return;
            }

            const match = registeredPatientsList.find(p => 
                (p.name && p.name.toLowerCase() === val) || 
                (p.contactNumber && p.contactNumber === val)
            );

            if (match) {
                if (contactInput) contactInput.value = match.contactNumber || "";
                if (addressInput) addressInput.value = match.address || "";
                if (allergiesInput && match.allergies && match.allergies !== "None") allergiesInput.value = match.allergies;
                if (conditionsInput && match.medicalConditions && match.medicalConditions !== "None") conditionsInput.value = match.medicalConditions;
                if (badge) badge.style.display = "block";
            } else {
                if (badge) badge.style.display = "none";
            }
        };

        nameInput.addEventListener("input", checkAndAutoFillSPA);
        nameInput.addEventListener("change", checkAndAutoFillSPA);
    }
}

// ==========================================
// 4. APPOINTMENT REGISTRATION
// ==========================================
async function handleRegisterAppointment(event) {
    event.preventDefault();
    const alertBox = document.getElementById("register-alert");
    alertBox.style.display = "none";
    alertBox.className = "alert";

    const patientName = document.getElementById("appt-patientName").value;
    const patientContact = document.getElementById("appt-patientContact").value;
    const patientAddress = document.getElementById("appt-patientAddress").value;
    const dentistId = parseInt(document.getElementById("appt-dentistId").value);
    const treatmentId = parseInt(document.getElementById("appt-treatmentId").value);
    const appointmentDate = document.getElementById("appt-appointmentDate").value;
    const appointmentTime = document.getElementById("appt-appointmentTime").value;
    const toothNumber = document.getElementById("appt-toothNumber")?.value || "General";
    const allergies = document.getElementById("appt-allergies")?.value || "None";
    const medicalConditions = document.getElementById("appt-medicalConditions")?.value || "None";

    const payload = {
        patientName, patientContact, patientAddress,
        dentistId, treatmentId, appointmentDate, appointmentTime,
        toothNumber, allergies, medicalConditions
    };

    try {
        const res = await fetch("api/appointments", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        const data = await res.json();
        
        if (res.ok) {
            showToast(`${data.message} - Appt No: ${data.appointmentNumber}`, "success");
            
            // Reset form
            document.getElementById("register-form").reset();
            selectTooth('General');
            
            // Set default date again
            const today = new Date().toISOString().split('T')[0];
            document.getElementById("appt-appointmentDate").value = today;
        } else {
            showToast(data.message || "Error scheduling appointment.", "danger");
        }
    } catch (e) {
        showToast("Error contacting server.", "danger");
        console.error(e);
    }
}

function selectTooth(toothNum) {
    const hiddenInput = document.getElementById("appt-toothNumber");
    const displayDiv = document.getElementById("selected-tooth-display");
    
    const buttons = document.querySelectorAll(".tooth-btn");
    buttons.forEach(btn => {
        if (btn.innerText === toothNum.toString()) {
            if (btn.classList.contains("selected") && toothNum !== 'General') {
                btn.classList.remove("selected");
                if (hiddenInput) hiddenInput.value = "General";
                if (displayDiv) displayDiv.innerText = "Selected Tooth: General (Whole Mouth / Consultation)";
            } else {
                buttons.forEach(b => b.classList.remove("selected"));
                if (toothNum !== 'General') btn.classList.add("selected");
                if (hiddenInput) hiddenInput.value = toothNum === 'General' ? 'General' : `Tooth #${toothNum}`;
                if (displayDiv) displayDiv.innerText = toothNum === 'General' ? "Selected Tooth: General (Whole Mouth / Consultation)" : `Selected Tooth: Tooth #${toothNum}`;
            }
        }
    });

    if (toothNum === 'General') {
        buttons.forEach(b => b.classList.remove("selected"));
        if (hiddenInput) hiddenInput.value = "General";
        if (displayDiv) displayDiv.innerText = "Selected Tooth: General (Whole Mouth / Consultation)";
    }
}

// ==========================================
// 5. SEARCH & DISPLAY APPOINTMENT
// ==========================================
async function handleSearchAppointment() {
    const alertBox = document.getElementById("search-alert");
    const resultCard = document.getElementById("search-result-card");
    const tableCard = document.getElementById("search-results-table-card");
    const tbody = document.getElementById("search-results-table-body");

    alertBox.style.display = "none";
    resultCard.style.display = "none";
    if (tableCard) tableCard.style.display = "none";

    const searchInput = document.getElementById("search-number").value.trim();
    if (!searchInput) {
        showToast("Please enter an appointment number or patient name.", "info");
        return;
    }

    try {
        const res = await fetch(`api/appointments?query=${encodeURIComponent(searchInput)}`);
        const data = await res.json();

        if (res.ok && Array.isArray(data)) {
            if (data.length === 0) {
                showToast(`No appointments found matching '${searchInput}'.`, "info");
                return;
            }

            if (data.length === 1) {
                // Single result: show details card directly
                displaySingleAppointmentDetails(data[0]);
            } else {
                // Multiple results: render table list
                tbody.innerHTML = '';
                data.forEach(a => {
                    const statusClass = a.status === "Pending" ? "badge-pending" : 
                                       (a.status === "Completed" ? "badge-completed" : "badge-cancelled");
                    const row = document.createElement("tr");
                    row.innerHTML = `
                        <td style="font-weight:600; color:var(--primary);">${a.appointmentNumber}</td>
                        <td style="font-weight:600;">${a.patientName}</td>
                        <td>${a.patientContact}</td>
                        <td>${a.dentistName}</td>
                        <td>${a.appointmentDate} at ${a.appointmentTime}</td>
                        <td><span class="badge ${statusClass}">${a.status}</span></td>
                        <td>
                            <button class="btn btn-primary" style="padding:4px 10px; font-size:0.75rem; width:auto;" onclick='displaySingleAppointmentDetails(${JSON.stringify(a).replace(/'/g, "&#39;")})'>
                                <i class="fa-solid fa-eye"></i> View
                            </button>
                        </td>
                    `;
                    tbody.appendChild(row);
                });
                tableCard.style.display = "block";
            }
        } else if (data && data.appointmentNumber) {
            displaySingleAppointmentDetails(data);
        } else {
            showToast(data.message || "Appointment not found.", "danger");
        }
    } catch (e) {
        showToast("Server error while searching.", "danger");
        console.error(e);
    }
}

function displaySingleAppointmentDetails(appt) {
    const resultCard = document.getElementById("search-result-card");
    document.getElementById("view-appt-num").innerText = appt.appointmentNumber;
    document.getElementById("view-patient-name").innerText = appt.patientName;
    document.getElementById("view-patient-contact").innerText = appt.patientContact;
    document.getElementById("view-patient-address").innerText = appt.patientAddress;
    document.getElementById("view-dentist-name").innerText = appt.dentistName;
    document.getElementById("view-treatment-name").innerText = appt.treatmentName;
    document.getElementById("view-appt-date").innerText = appt.appointmentDate;
    document.getElementById("view-appt-time").innerText = appt.appointmentTime;

    if (document.getElementById("view-tooth-number")) {
        document.getElementById("view-tooth-number").innerText = appt.toothNumber || "General";
    }
    if (document.getElementById("view-patient-allergies")) {
        document.getElementById("view-patient-allergies").innerText = `Allergies: ${appt.allergies || "None"}`;
    }
    if (document.getElementById("view-patient-conditions")) {
        document.getElementById("view-patient-conditions").innerText = `Conditions: ${appt.medicalConditions || "None"}`;
    }
    
    const statusEl = document.getElementById("view-appt-status");
    statusEl.innerText = appt.status.toUpperCase();
    
    statusEl.className = "badge";
    if (appt.status === "Pending") statusEl.classList.add("badge-pending");
    else if (appt.status === "Completed") statusEl.classList.add("badge-completed");
    else if (appt.status === "Cancelled") statusEl.classList.add("badge-cancelled");

    resultCard.style.display = "block";
    resultCard.scrollIntoView({ behavior: "smooth", block: "nearest" });
}

// ==========================================
// 6. CALCULATE AND PRINT BILL
// ==========================================
let currentCalculatedBill = null;

async function handleBillingCalculate() {
    const alertBox = document.getElementById("billing-alert");
    alertBox.style.display = "none";
    alertBox.className = "alert";

    const apptNum = document.getElementById("bill-apptNum").value.trim();
    const strategy = document.getElementById("bill-strategy").value;
    const manualDiscount = parseFloat(document.getElementById("bill-discount").value) || 0;

    if (!apptNum) {
        showToast("Please enter an appointment number to calculate.", "info");
        return;
    }

    try {
        const res = await fetch("api/bills/calculate", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                appointmentNumber: apptNum,
                billingStrategy: strategy,
                manualDiscount: manualDiscount
            })
        });

        const data = await res.json();

        if (res.ok) {
            currentCalculatedBill = data;
            
            // Update breakdown display
            document.getElementById("breakdown-doctor").innerText = `LKR ${data.consultationFee.toFixed(2)}`;
            document.getElementById("breakdown-treatment").innerText = `LKR ${data.treatmentCost.toFixed(2)}`;
            document.getElementById("breakdown-total").innerText = `LKR ${data.totalCost.toFixed(2)}`;
            document.getElementById("breakdown-discount").innerText = `LKR ${data.discountAmount.toFixed(2)}`;
            document.getElementById("breakdown-net").innerText = `LKR ${data.netCost.toFixed(2)}`;

            // Update receipt mockup
            document.getElementById("r-date").innerText = new Date().toISOString().split('T')[0];
            document.getElementById("r-bill-id").innerText = "PENDING SAVE";
            document.getElementById("r-appt-num").innerText = data.appointmentNumber;
            document.getElementById("r-status").innerText = "UNPAID";
            document.getElementById("r-status").className = "";
            document.getElementById("r-status").style.color = "var(--danger)";
            document.getElementById("r-patient").innerText = data.patientName;
            document.getElementById("r-dentist").innerText = data.dentistName;
            document.getElementById("r-treatment").innerText = data.treatmentName;
            document.getElementById("r-doctor-fee").innerText = data.consultationFee.toFixed(2);
            document.getElementById("r-treatment-fee").innerText = data.treatmentCost.toFixed(2);
            document.getElementById("r-discount").innerText = `-${data.discountAmount.toFixed(2)}`;
            document.getElementById("r-net").innerText = `LKR ${data.netCost.toFixed(2)}`;

            // Enable buttons
            document.getElementById("btn-generate-bill").disabled = false;
            document.getElementById("btn-pay-bill").disabled = true; // Disabled until saved/generated

            // If a bill already exists in database, let's load it
            checkExistingInvoice(apptNum);
        } else {
            showToast(data.message || "Error performing calculations.", "danger");
        }
    } catch (e) {
        showToast("Error connecting to billing module.", "danger");
        console.error(e);
    }
}

async function checkExistingInvoice(apptNum) {
    try {
        const res = await fetch(`api/bills?number=${encodeURIComponent(apptNum)}`);
        if (res.ok) {
            const data = await res.json();
            // Invoice exists, update receipt info
            document.getElementById("r-bill-id").innerText = `INV-${data.id.toString().padStart(4, '0')}`;
            document.getElementById("r-status").innerText = data.status.toUpperCase();
            if (data.status === "Paid") {
                document.getElementById("r-status").style.color = "var(--success)";
                document.getElementById("btn-generate-bill").disabled = true;
                document.getElementById("btn-pay-bill").disabled = true;
            } else {
                document.getElementById("r-status").style.color = "var(--danger)";
                document.getElementById("btn-generate-bill").disabled = true;
                document.getElementById("btn-pay-bill").disabled = false;
            }
        }
    } catch (e) {
        // No existing invoice is fine
    }
}

async function handleGenerateBill() {
    const alertBox = document.getElementById("billing-alert");
    alertBox.style.display = "none";
    alertBox.className = "alert";

    if (!currentCalculatedBill) return;

    const apptNum = currentCalculatedBill.appointmentNumber;
    const strategy = document.getElementById("bill-strategy").value;
    const manualDiscount = parseFloat(document.getElementById("bill-discount").value) || 0;

    try {
        const res = await fetch("api/bills/generate", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                appointmentNumber: apptNum,
                billingStrategy: strategy,
                manualDiscount: manualDiscount
            })
        });

        const data = await res.json();

        if (res.ok) {
            showToast(data.message || "Invoice saved successfully.", "success");

            document.getElementById("btn-generate-bill").disabled = true;
            document.getElementById("btn-pay-bill").disabled = false;
            
            // Reload existing invoice information
            checkExistingInvoice(apptNum);
        } else {
            showToast(data.message || "Error saving invoice.", "danger");
        }
    } catch (e) {
        showToast("Connection error during bill creation.", "danger");
        console.error(e);
    }
}

async function handlePayBill() {
    const alertBox = document.getElementById("billing-alert");
    alertBox.style.display = "none";
    alertBox.className = "alert";

    if (!currentCalculatedBill) return;

    const apptNum = currentCalculatedBill.appointmentNumber;

    try {
        const res = await fetch("api/bills/pay", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ appointmentNumber: apptNum })
        });

        const data = await res.json();

        if (res.ok) {
            showToast(data.message || "Payment recorded successfully.", "success");

            document.getElementById("btn-pay-bill").disabled = true;
            checkExistingInvoice(apptNum);
        } else {
            showToast(data.message || "Error processing payment.", "danger");
        }
    } catch (e) {
        showToast("Connection error during payment processing.", "danger");
        console.error(e);
    }
}

// ==========================================
// 7. NOTIFICATIONS SIMULATION QUEUE
// ==========================================
async function loadNotifications() {
    const tbody = document.querySelector("#notifications-table tbody");
    tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--text-muted);">Loading logs...</td></tr>';

    try {
        const res = await fetch("api/notifications");
        const list = await res.json();

        tbody.innerHTML = '';
        if (list.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--text-muted);">No notification logs found.</td></tr>';
            return;
        }

        list.forEach(n => {
            const statusClass = n.status === "Sent" ? "badge-completed" : "badge-pending";
            tbody.innerHTML += `
                <tr>
                    <td>${n.id}</td>
                    <td style="font-weight: 600; color: var(--primary);">${n.appointmentNumber}</td>
                    <td>${n.recipientContact}</td>
                    <td><span class="badge" style="background: rgba(255,255,255,0.05); color:#fff;">${n.messageType}</span></td>
                    <td style="max-width: 300px; font-size: 0.85rem; word-break: break-all;">${n.message}</td>
                    <td style="font-size: 0.85rem; color: var(--text-muted);">${n.sentAt}</td>
                    <td><span class="badge ${statusClass}">${n.status}</span></td>
                </tr>
            `;
        });
    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--danger);">Failed to load notifications.</td></tr>';
        console.error(e);
    }
}

async function triggerNotificationDispatch() {
    const alertBox = document.getElementById("notification-alert");
    alertBox.style.display = "none";
    alertBox.className = "alert";

    try {
        const res = await fetch("api/notifications/send-pending", { method: "POST" });
        const data = await res.json();

        if (res.ok) {
            showToast(data.message, "success");
            loadNotifications();
        } else {
            showToast("Error dispatching queue.", "danger");
        }
    } catch (e) {
        showToast("Connection error.", "danger");
        console.error(e);
    }
}

// ==========================================
// 8. DECISION-MAKING REPORTS & ANALYTICS
// ==========================================
async function loadDashboardAnalytics() {
    try {
        // Load summary metrics
        const summaryRes = await fetch("api/reports/summary");
        if (summaryRes.ok) {
            const summary = await summaryRes.json();
            document.getElementById("metric-appointments").innerText = summary.totalAppointments;
            document.getElementById("metric-invoices").innerText = summary.totalInvoices;
            document.getElementById("metric-revenue").innerText = `LKR ${summary.totalRevenue.toLocaleString(undefined, {minimumFractionDigits: 2})}`;
        }

        // Load Revenue by Dentist
        const revRes = await fetch("api/reports/dentist-revenue");
        if (revRes.ok) {
            const dentistRevenue = await revRes.json();
            drawBarChart("report-dentist-revenue", dentistRevenue, ' LKR', true);
        }

        // Load Treatment Popularity
        const popRes = await fetch("api/reports/treatment-popularity");
        if (popRes.ok) {
            const treatmentPopularity = await popRes.json();
            drawBarChart("report-treatment-popularity", treatmentPopularity, ' bookings', false);
        }

        // Re-apply role permissions (e.g. restrict revenue metrics for staff)
        applyRolePermissions();
    } catch (e) {
        console.error("Error loading analytics data", e);
    }
}

/**
 * Draws a glassmorphic bar chart row-by-row
 */
function drawBarChart(containerId, dataMap, valueSuffix = '', isCurrency = false) {
    const container = document.getElementById(containerId);
    container.innerHTML = '';
    
    const entries = Object.entries(dataMap);
    if (entries.length === 0) {
        container.innerHTML = '<p style="color: var(--text-muted); text-align: center; padding: 20px;">No transaction records found.</p>';
        return;
    }

    const values = entries.map(e => Number(e[1]));
    const maxValue = Math.max(...values, 1);

    entries.forEach(([key, val]) => {
        const percentage = (val / maxValue) * 100;
        const displayVal = isCurrency ? `LKR ${val.toLocaleString(undefined, {minimumFractionDigits: 2})}` : `${val}${valueSuffix}`;
        
        const row = document.createElement("div");
        row.className = "chart-bar-row";
        row.innerHTML = `
            <div class="chart-bar-labels">
                <span>${key}</span>
                <strong>${displayVal}</strong>
            </div>
            <div class="chart-bar-container">
                <div class="chart-bar-fill" style="width: 0%"></div>
            </div>
        `;
        container.appendChild(row);
        
        // Micro-animation for bar expansion
        setTimeout(() => {
            const fill = row.querySelector(".chart-bar-fill");
            if (fill) fill.style.width = `${percentage}%`;
        }, 100);
    });
}

// ==========================================
// 9. USER MANAGEMENT SERVICES (ADMIN ONLY)
// ==========================================
async function loadUsers() {
    const tbody = document.getElementById("users-table-body");
    if (!tbody) return;

    try {
        const res = await fetch("api/users");
        const users = await res.json();

        tbody.innerHTML = '';
        if (users.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: var(--text-muted);">No users found.</td></tr>';
            return;
        }

        users.forEach((u, index) => {
            const roleBadge = u.role === "Admin" ? "badge-sent" : "badge-completed";
            const deleteBtn = u.username === "admin" ? 
                '<span style="font-size:0.75rem; color:var(--text-muted);">Primary Admin</span>' :
                '<button onclick="handleDeleteUser(' + u.id + ', \'' + u.username + '\')" class="btn btn-danger" style="padding:4px 10px; font-size:0.75rem; width:auto;"><i class="fa-solid fa-trash"></i> Delete</button>';

            tbody.innerHTML += 
                '<tr>' +
                    '<td style="font-weight:600; color:var(--text-muted);">' + (index + 1) + '</td>' +
                    '<td style="font-weight:600; color:var(--primary);">' + u.username + '</td>' +
                    '<td>' + u.fullName + '</td>' +
                    '<td style="color:var(--text-muted); font-size:0.85rem;">' + (u.email ? u.email : '—') + '</td>' +
                    '<td><span class="badge ' + roleBadge + '">' + u.role + '</span></td>' +
                    '<td>' + deleteBtn + '</td>' +
                '</tr>';
        });
    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: var(--danger);">Error loading user list.</td></tr>';
        console.error(e);
    }
}

async function handleCreateUser(event) {
    event.preventDefault();
    const alertBox = document.getElementById("user-create-alert");
    alertBox.style.display = "none";
    alertBox.className = "alert";

    const username = document.getElementById("user-username").value.trim();
    const password = document.getElementById("user-password").value;
    const fullName = document.getElementById("user-fullname").value.trim();
    const role = document.getElementById("user-role").value;
    const email = document.getElementById("user-email").value.trim();

    try {
        const res = await fetch("api/users", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ username, password, fullName, role, email })
        });
        const data = await res.json();

        if (res.ok && data.success) {
            showToast(data.message || ("User '" + username + "' created successfully!"), "success");
            document.getElementById("create-user-form").reset();
            loadUsers();
        } else {
            showToast(data.message || "Failed to create user.", "danger");
        }
    } catch (e) {
        showToast("Error connecting to server.", "danger");
        console.error(e);
    }
}

function handleDeleteUser(userId, username) {
    const actionCallback = async function() {
        try {
            const res = await fetch("api/users?id=" + userId, { method: "DELETE" });
            const data = await res.json();

            if (res.ok && data.success) {
                showToast("User '" + username + "' deleted successfully.", "success");
                loadUsers();
            } else {
                showToast(data.message || "Failed to delete user.", "danger");
            }
        } catch (e) {
            showToast("Server connection error.", "danger");
            console.error(e);
        }
    };

    if (typeof openDeleteConfirmModal === 'function') {
        openDeleteConfirmModal(actionCallback, username);
    } else {
        if (confirm("Are you sure you want to delete user '" + username + "'?")) {
            actionCallback();
        }
    }
}

// ==========================================
// 10. AUDIT LOGS & REPORT EXPORTS
// ==========================================
async function loadAuditLogs() {
    const tbody = document.getElementById("audit-logs-table-body");
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Loading audit logs...</td></tr>';

    try {
        const res = await fetch("api/audit-logs");
        if (res.ok) {
            const logs = await res.json();
            tbody.innerHTML = "";
            if (!logs || logs.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:var(--text-muted);">No audit logs recorded yet.</td></tr>';
                return;
            }
            logs.forEach(log => {
                const tr = document.createElement("tr");
                tr.innerHTML = 
                    '<td><strong>#' + log.id + '</strong></td>' +
                    '<td style="font-size:0.85rem; color:var(--text-muted);">' + new Date(log.timestamp).toLocaleString() + '</td>' +
                    '<td><span class="badge" style="background:#e0f2fe; color:#0369a1;">' + log.username + '</span></td>' +
                    '<td><strong style="color:var(--primary); font-size:0.85rem;">' + log.action + '</strong></td>' +
                    '<td style="font-size:0.9rem;">' + log.details + '</td>';
                tbody.appendChild(tr);
            });
        }
    } catch (e) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:var(--danger);">Error loading audit logs.</td></tr>';
        console.error("Audit log error", e);
    }
}

function exportTableToCSV(filename, tableId) {
    const table = document.getElementById(tableId);
    if (!table) return;
    
    let csv = [];
    const rows = table.querySelectorAll("tr");
    
    for (let i = 0; i < rows.length; i++) {
        let row = [], cols = rows[i].querySelectorAll("td, th");
        for (let j = 0; j < cols.length; j++) {
            let text = cols[j].innerText.replace(/"/g, '""').replace(/\n/g, ' ');
            row.push('"' + text + '"');
        }
        csv.push(row.join(","));
    }

    const csvFile = new Blob([csv.join("\n")], { type: "text/csv" });
    const downloadLink = document.createElement("a");
    downloadLink.download = filename;
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = "none";
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
    showToast("Exported " + filename + " successfully!", "success");
}
