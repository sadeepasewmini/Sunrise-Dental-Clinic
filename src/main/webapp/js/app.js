// Sunrise Dental Clinic - SPA Application Script
let currentUser = null;

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
            showDashboard();
        } else {
            alertBox.innerText = data.message || "Invalid login credentials.";
            alertBox.style.display = "block";
        }
    } catch (e) {
        alertBox.innerText = "Error connecting to login server.";
        alertBox.style.display = "block";
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
    document.getElementById("nav-role").innerText = currentUser.role;
    document.getElementById("nav-avatar").innerText = currentUser.fullName.charAt(0);
    
    // Update footer/headers
    document.getElementById("dashboard-date").innerText = new Date().toDateString();

    // Load master lookup lists and dashboard data
    loadDropdownData();
    loadDashboardAnalytics();
    loadNotifications();
    
    switchSection("dashboard");
}

// ==========================================
// 2. SIDEBAR SECTION SWITCHER
// ==========================================
function switchSection(sectionId) {
    // Toggle active classes on page content
    const sections = document.querySelectorAll(".page-section");
    sections.forEach(sec => sec.classList.remove("active"));
    
    const targetSection = document.getElementById(`section-${sectionId}`);
    if (targetSection) {
        targetSection.classList.add("active");
    }

    // Toggle active classes on sidebar menu items
    const menuItems = document.querySelectorAll(".menu-item");
    menuItems.forEach(item => item.classList.remove("active"));
    
    // Find matching click target
    const items = Array.from(menuItems);
    const matched = items.find(el => el.getAttribute("onclick").includes(sectionId));
    if (matched) matched.classList.add("active");

    // Perform specific section reloads
    if (sectionId === "dashboard") {
        loadDashboardAnalytics();
    } else if (sectionId === "notifications") {
        loadNotifications();
    }
}

// ==========================================
// 3. MASTER LIST LOADER
// ==========================================
let dentistsList = [];
let treatmentsList = [];

async function loadDropdownData() {
    try {
        const [dentistsRes, treatmentsRes] = await Promise.all([
            fetch("api/dentists"),
            fetch("api/treatments")
        ]);
        
        dentistsList = await dentistsRes.json();
        treatmentsList = await treatmentsRes.json();

        // Populate dropdowns in Register screen
        const dentistSel = document.getElementById("appt-dentistId");
        dentistSel.innerHTML = '<option value="">Select Dentist</option>';
        dentistsList.forEach(d => {
            dentistSel.innerHTML += `<option value="${d.id}">${d.name} (${d.specialization}) - LKR ${d.consultationFee}</option>`;
        });

        const treatmentSel = document.getElementById("appt-treatmentId");
        treatmentSel.innerHTML = '<option value="">Select Treatment</option>';
        treatmentsList.forEach(t => {
            treatmentSel.innerHTML += `<option value="${t.id}">${t.name} - LKR ${t.cost}</option>`;
        });
        
    } catch (e) {
        console.error("Failed to load master lookup lists", e);
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

    const payload = {
        patientName, patientContact, patientAddress,
        dentistId, treatmentId, appointmentDate, appointmentTime
    };

    try {
        const res = await fetch("api/appointments", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        const data = await res.json();
        
        if (res.ok) {
            alertBox.innerHTML = `<strong>Success!</strong> ${data.message} <br><strong>Appointment Number: ${data.appointmentNumber}</strong>`;
            alertBox.classList.add("alert-success");
            alertBox.style.display = "block";
            
            // Reset form
            document.getElementById("register-form").reset();
            
            // Set default date again
            const today = new Date().toISOString().split('T')[0];
            document.getElementById("appt-appointmentDate").value = today;
        } else {
            alertBox.innerText = data.message || "Error scheduling appointment.";
            alertBox.classList.add("alert-danger");
            alertBox.style.display = "block";
        }
    } catch (e) {
        alertBox.innerText = "Error contacting server.";
        alertBox.classList.add("alert-danger");
        alertBox.style.display = "block";
        console.error(e);
    }
}

// ==========================================
// 5. SEARCH & DISPLAY APPOINTMENT
// ==========================================
async function handleSearchAppointment() {
    const alertBox = document.getElementById("search-alert");
    const resultCard = document.getElementById("search-result-card");
    alertBox.style.display = "none";
    resultCard.style.display = "none";

    const searchInput = document.getElementById("search-number").value.trim();
    if (!searchInput) {
        alertBox.innerText = "Please enter an appointment number.";
        alertBox.style.display = "block";
        return;
    }

    try {
        const res = await fetch(`api/appointments?number=${encodeURIComponent(searchInput)}`);
        const data = await res.json();

        if (res.ok) {
            document.getElementById("view-appt-num").innerText = data.appointmentNumber;
            document.getElementById("view-patient-name").innerText = data.patientName;
            document.getElementById("view-patient-contact").innerText = data.patientContact;
            document.getElementById("view-patient-address").innerText = data.patientAddress;
            document.getElementById("view-dentist-name").innerText = data.dentistName;
            document.getElementById("view-treatment-name").innerText = data.treatmentName;
            document.getElementById("view-appt-date").innerText = data.appointmentDate;
            document.getElementById("view-appt-time").innerText = data.appointmentTime;
            
            const statusEl = document.getElementById("view-appt-status");
            statusEl.innerText = data.status.toUpperCase();
            
            // Clear status classes
            statusEl.className = "badge";
            if (data.status === "Pending") statusEl.classList.add("badge-pending");
            else if (data.status === "Completed") statusEl.classList.add("badge-completed");
            else if (data.status === "Cancelled") statusEl.classList.add("badge-cancelled");

            resultCard.style.display = "block";
        } else {
            alertBox.innerText = data.message || "Appointment not found.";
            alertBox.style.display = "block";
        }
    } catch (e) {
        alertBox.innerText = "Server error while searching.";
        alertBox.style.display = "block";
        console.error(e);
    }
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
        alertBox.innerText = "Please enter an appointment number to calculate.";
        alertBox.classList.add("alert-danger");
        alertBox.style.display = "block";
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
            alertBox.innerText = data.message || "Error performing calculations.";
            alertBox.classList.add("alert-danger");
            alertBox.style.display = "block";
        }
    } catch (e) {
        alertBox.innerText = "Error connecting to billing module.";
        alertBox.classList.add("alert-danger");
        alertBox.style.display = "block";
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
            alertBox.innerText = data.message || "Invoice saved successfully.";
            alertBox.classList.add("alert-success");
            alertBox.style.display = "block";

            document.getElementById("btn-generate-bill").disabled = true;
            document.getElementById("btn-pay-bill").disabled = false;
            
            // Reload existing invoice information
            checkExistingInvoice(apptNum);
        } else {
            alertBox.innerText = data.message || "Error saving invoice.";
            alertBox.classList.add("alert-danger");
            alertBox.style.display = "block";
        }
    } catch (e) {
        alertBox.innerText = "Connection error during bill creation.";
        alertBox.classList.add("alert-danger");
        alertBox.style.display = "block";
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
            alertBox.innerText = data.message || "Payment recorded successfully.";
            alertBox.classList.add("alert-success");
            alertBox.style.display = "block";

            document.getElementById("btn-pay-bill").disabled = true;
            checkExistingInvoice(apptNum);
        } else {
            alertBox.innerText = data.message || "Error processing payment.";
            alertBox.classList.add("alert-danger");
            alertBox.style.display = "block";
        }
    } catch (e) {
        alertBox.innerText = "Connection error during payment processing.";
        alertBox.classList.add("alert-danger");
        alertBox.style.display = "block";
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
            alertBox.innerText = data.message;
            alertBox.classList.add("alert-success");
            alertBox.style.display = "block";
            loadNotifications();
        } else {
            alertBox.innerText = "Error dispatching queue.";
            alertBox.classList.add("alert-danger");
            alertBox.style.display = "block";
        }
    } catch (e) {
        alertBox.innerText = "Connection error.";
        alertBox.classList.add("alert-danger");
        alertBox.style.display = "block";
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
