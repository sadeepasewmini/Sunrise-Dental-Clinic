<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="content-card" style="max-width:700px; margin:0 auto;">
        <div class="card-title"><i class="fa-solid fa-calendar-plus"></i> Register New Appointment</div>
        <form action="${pageContext.request.contextPath}/appointments" method="POST">
            <input type="hidden" name="action" value="create">

            <div class="form-group" style="position:relative;">
                <label class="form-label">Patient Name (Type to search registered patients)</label>
                <input type="text" id="patientNameInput" name="patientName" class="form-input" placeholder="Start typing patient full name..." list="registeredPatientsDatalist" autocomplete="off" required>
                <datalist id="registeredPatientsDatalist"></datalist>
                <div id="autoFillBadge" style="display:none; font-size:0.82rem; color:#059669; background:#d1fae5; border:1px solid #a7f3d0; padding:6px 12px; border-radius:8px; margin-top:8px; font-weight:600;">
                    <i class="fa-solid fa-circle-check"></i> Patient profile matched! Details auto-filled from database.
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Contact Number</label>
                    <input type="text" id="patientContactInput" name="patientContact" class="form-input" placeholder="e.g. 0771234567" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <input type="text" id="patientAddressInput" name="patientAddress" class="form-input" placeholder="Enter address" required>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Select Dentist</label>
                    <select name="dentistId" class="form-select" required>
                        <option value="">-- Choose Dentist --</option>
                        <c:forEach var="d" items="${dentists}">
                            <option value="${d.id}">${d.name} (${d.specialization}) - LKR <fmt:formatNumber value="${d.consultationFee}" pattern="#,##0.00"/></option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Select Treatment</label>
                    <select name="treatmentId" class="form-select" required>
                        <option value="">-- Choose Treatment --</option>
                        <c:forEach var="t" items="${treatments}">
                            <option value="${t.id}">${t.name} - LKR <fmt:formatNumber value="${t.cost}" pattern="#,##0.00"/></option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Appointment Date</label>
                    <input type="date" name="appointmentDate" class="form-input" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Appointment Time</label>
                    <input type="time" name="appointmentTime" class="form-input" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top:20px;">
                <i class="fa-solid fa-check"></i> Register Appointment
            </button>
        </form>
    </div>
</section>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        let registeredPatients = [];

        // Load existing registered patients from API
        fetch('${pageContext.request.contextPath}/api/patients')
            .then(function(res) { return res.json(); })
            .then(function(data) {
                registeredPatients = data || [];
                const datalist = document.getElementById('registeredPatientsDatalist');
                if (datalist && registeredPatients.length > 0) {
                    datalist.innerHTML = registeredPatients.map(function(p) {
                        return '<option value="' + p.name + '">' + p.contactNumber + ' | ' + p.address + '</option>';
                    }).join('');
                }
            })
            .catch(function(err) { console.error("Error loading patient datalist:", err); });

        const nameInput = document.getElementById('patientNameInput');
        const contactInput = document.getElementById('patientContactInput');
        const addressInput = document.getElementById('patientAddressInput');
        const badge = document.getElementById('autoFillBadge');

        function checkAndAutoFill() {
            if (!nameInput) return;
            const val = nameInput.value.trim().toLowerCase();
            if (!val) {
                if (badge) badge.style.display = 'none';
                return;
            }

            const match = registeredPatients.find(function(p) {
                return (p.name && p.name.toLowerCase() === val) || 
                       (p.contactNumber && p.contactNumber === val);
            });

            if (match) {
                if (contactInput) contactInput.value = match.contactNumber || '';
                if (addressInput) addressInput.value = match.address || '';
                if (badge) badge.style.display = 'block';
            } else {
                if (badge) badge.style.display = 'none';
            }
        }

        if (nameInput) {
            nameInput.addEventListener('input', checkAndAutoFill);
            nameInput.addEventListener('change', checkAndAutoFill);
        }
    });
</script>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
