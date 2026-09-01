<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <!-- Form to Add New Dentist -->
    <div class="content-card">
        <div class="card-title">
            <i class="fa-solid fa-user-doctor"></i> Add New Dentist / Doctor
        </div>
        
        <form action="${pageContext.request.contextPath}/dentists" method="POST" id="addDentistForm">
            <input type="hidden" name="action" value="create">
            
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="dentistName">Full Name / Doctor Title <span style="color:var(--danger);">*</span></label>
                    <input type="text" id="dentistName" name="name" class="form-input" placeholder="e.g. Dr. Sunil Perera" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="specialization">Specialization <span style="color:var(--danger);">*</span></label>
                    <select id="specialization" name="specialization" class="form-select" required>
                        <option value="" disabled selected>-- Select Specialization --</option>
                        <option value="General Practitioner">General Practitioner / General Dentist</option>
                        <option value="Orthodontist">Orthodontist (Braces &amp; Alignment)</option>
                        <option value="Endodontist">Endodontist (Root Canal Specialist)</option>
                        <option value="Pediatric Dentist">Pediatric Dentist (Child Specialist)</option>
                        <option value="Periodontist">Periodontist (Gum Specialist)</option>
                        <option value="Prosthodontist">Prosthodontist (Dentures &amp; Crowns)</option>
                        <option value="Oral &amp; Maxillofacial Surgeon">Oral &amp; Maxillofacial Surgeon</option>
                        <option value="Cosmetic Dentist">Cosmetic Dentist (Teeth Whitening &amp; Veneers)</option>
                    </select>
                </div>
            </div>

            <div class="grid-2" style="margin-top:12px;">
                <div class="form-group">
                    <label class="form-label" for="contactNumber">Contact Phone Number</label>
                    <input type="text" id="contactNumber" name="contactNumber" class="form-input" placeholder="e.g. 0771234567">
                </div>

                <div class="form-group">
                    <label class="form-label" for="consultationFee">Consultation Fee (LKR) <span style="color:var(--danger);">*</span></label>
                    <input type="number" id="consultationFee" name="consultationFee" class="form-input" value="1000.00" step="50" min="0" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top:20px; width:auto; padding:12px 28px;">
                <i class="fa-solid fa-plus"></i> Add Dentist Profile
            </button>
        </form>
    </div>

    <!-- Dentist List Table -->
    <div class="content-card" style="margin-top: 24px;">
        <div class="card-title">
            <i class="fa-solid fa-list-ul"></i> Registered Dentists (${dentists.size()})
        </div>

        <div class="table-container">
            <table class="table-glass">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Dentist Name</th>
                        <th>Specialization</th>
                        <th>Contact Number</th>
                        <th>Consultation Fee</th>
                        <th style="text-align:center;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="d" items="${dentists}">
                        <tr>
                            <td style="font-weight:600; color:var(--text-muted);">#${d.id}</td>
                            <td style="font-weight:700; color:var(--primary-dark);">
                                <i class="fa-solid fa-user-doctor" style="color:var(--primary); margin-right:6px;"></i> <c:out value="${d.name}" />
                            </td>
                            <td>
                                <span class="badge badge-completed" style="background:rgba(8, 145, 178, 0.15); color:var(--primary); font-weight:600;">
                                    <c:out value="${d.specialization}" />
                                </span>
                            </td>
                            <td>${d.contactNumber != null && !d.contactNumber.isEmpty() ? d.contactNumber : 'N/A'}</td>
                            <td style="font-weight:700; color:var(--success);">
                                LKR <fmt:formatNumber value="${d.consultationFee}" pattern="#,##0.00"/>
                            </td>
                            <td style="text-align:center; white-space:nowrap;">
                                <button type="button" class="btn btn-secondary" 
                                        style="padding:6px 14px; font-size:0.8rem; background:var(--primary); border-color:var(--primary); color:#fff; border-radius:8px; margin-right:4px;"
                                        data-id="${d.id}"
                                        data-name="<c:out value='${d.name}'/>"
                                        data-specialization="<c:out value='${d.specialization}'/>"
                                        data-contact="<c:out value='${d.contactNumber}'/>"
                                        data-fee="${d.consultationFee}"
                                        onclick="openEditDentistModalFromBtn(this)">
                                    <i class="fa-solid fa-pen-to-square"></i> Edit
                                </button>

                                <button type="button" class="btn btn-secondary" 
                                        style="padding:6px 14px; font-size:0.8rem; background:var(--danger); border-color:var(--danger); color:#fff; border-radius:8px;"
                                        data-id="${d.id}"
                                        data-name="<c:out value='${d.name}'/>"
                                        onclick="confirmDeleteDentistFromBtn(this)">
                                    <i class="fa-solid fa-trash"></i> Remove
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty dentists}">
                        <tr>
                            <td colspan="6" style="text-align:center; padding:24px; color:var(--text-muted);">
                                No dentists registered yet.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</section>

<!-- Glassmorphic Modal for Editing Dentist -->
<div id="editDentistModal" class="custom-modal-overlay">
    <div class="custom-modal-card" style="max-width: 560px; text-align: left;">
        <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e2e8f0; padding-bottom:14px; margin-bottom:20px;">
            <h3 style="margin:0; font-size:1.2rem; color:var(--primary-dark); font-weight:700;">
                <i class="fa-solid fa-user-pen" style="color:var(--primary);"></i> Edit Dentist Profile
            </h3>
            <button type="button" onclick="closeEditDentistModal()" style="background:none; border:none; font-size:1.5rem; color:var(--text-muted); cursor:pointer; line-height:1;">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/dentists" method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" id="editDentistId" name="id">

            <div class="form-group" style="margin-bottom:14px;">
                <label class="form-label" for="editDentistName">Full Name / Doctor Title <span style="color:var(--danger);">*</span></label>
                <input type="text" id="editDentistName" name="name" class="form-input" required>
            </div>

            <div class="form-group" style="margin-bottom:14px;">
                <label class="form-label" for="editSpecialization">Specialization <span style="color:var(--danger);">*</span></label>
                <select id="editSpecialization" name="specialization" class="form-select" required>
                    <option value="General Practitioner">General Practitioner / General Dentist</option>
                    <option value="Orthodontist">Orthodontist (Braces &amp; Alignment)</option>
                    <option value="Endodontist">Endodontist (Root Canal Specialist)</option>
                    <option value="Pediatric Dentist">Pediatric Dentist (Child Specialist)</option>
                    <option value="Periodontist">Periodontist (Gum Specialist)</option>
                    <option value="Prosthodontist">Prosthodontist (Dentures &amp; Crowns)</option>
                    <option value="Oral &amp; Maxillofacial Surgeon">Oral &amp; Maxillofacial Surgeon</option>
                    <option value="Cosmetic Dentist">Cosmetic Dentist (Teeth Whitening &amp; Veneers)</option>
                </select>
            </div>

            <div class="grid-2" style="margin-bottom:14px;">
                <div class="form-group">
                    <label class="form-label" for="editContactNumber">Contact Phone Number</label>
                    <input type="text" id="editContactNumber" name="contactNumber" class="form-input">
                </div>

                <div class="form-group">
                    <label class="form-label" for="editConsultationFee">Consultation Fee (LKR) <span style="color:var(--danger);">*</span></label>
                    <input type="number" id="editConsultationFee" name="consultationFee" class="form-input" step="50" min="0" required>
                </div>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:24px; border-top:1px solid #e2e8f0; padding-top:16px;">
                <button type="button" class="btn btn-secondary" onclick="closeEditDentistModal()" style="padding:10px 20px; border-radius:8px;">Cancel</button>
                <button type="submit" class="btn btn-primary" style="padding:10px 24px; border-radius:8px;">
                    <i class="fa-solid fa-floppy-disk"></i> Save Changes
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Glassmorphic Modal for Delete Confirmation -->
<div id="deleteDentistModal" class="custom-modal-overlay">
    <div class="custom-modal-card" style="max-width: 440px; text-align: center;">
        <div class="custom-modal-icon">
            <i class="fa-solid fa-triangle-exclamation"></i>
        </div>

        <div class="custom-modal-title">Confirm Removal</div>
        
        <p style="color:var(--text-muted); font-size:0.95rem; line-height:1.5; margin:0 0 24px;">
            Are you sure you want to remove <strong id="deleteDentistName" style="color:var(--primary-dark);"></strong>? This action cannot be undone.
        </p>

        <form action="${pageContext.request.contextPath}/dentists" method="POST" id="deleteDentistForm">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" id="deleteDentistId" name="id">

            <div style="display:flex; justify-content:center; gap:12px;">
                <button type="button" class="btn btn-secondary" onclick="closeDeleteDentistModal()" style="padding:10px 22px; border-radius:10px;">
                    Cancel
                </button>
                <button type="submit" class="btn btn-secondary" style="padding:10px 22px; background:var(--danger); border-color:var(--danger); color:#fff; border-radius:10px; font-weight:600;">
                    <i class="fa-solid fa-trash"></i> Yes, Remove
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openEditDentistModalFromBtn(btn) {
    var id = btn.getAttribute('data-id');
    var name = btn.getAttribute('data-name');
    var spec = btn.getAttribute('data-specialization');
    var contact = btn.getAttribute('data-contact');
    var fee = btn.getAttribute('data-fee');

    document.getElementById('editDentistId').value = id;
    document.getElementById('editDentistName').value = name;
    document.getElementById('editSpecialization').value = spec;
    document.getElementById('editContactNumber').value = contact || '';
    document.getElementById('editConsultationFee').value = fee;

    var modal = document.getElementById('editDentistModal');
    if (modal) {
        modal.classList.add('active');
    }
}

function closeEditDentistModal() {
    var modal = document.getElementById('editDentistModal');
    if (modal) {
        modal.classList.remove('active');
    }
}

function confirmDeleteDentistFromBtn(btn) {
    var id = btn.getAttribute('data-id');
    var name = btn.getAttribute('data-name');

    document.getElementById('deleteDentistId').value = id;
    document.getElementById('deleteDentistName').textContent = name;

    var modal = document.getElementById('deleteDentistModal');
    if (modal) {
        modal.classList.add('active');
    }
}

function closeDeleteDentistModal() {
    var modal = document.getElementById('deleteDentistModal');
    if (modal) {
        modal.classList.remove('active');
    }
}

// Close modals on clicking backdrop
window.addEventListener('click', function(e) {
    if (e.target.classList.contains('custom-modal-overlay')) {
        closeEditDentistModal();
        closeDeleteDentistModal();
    }
});
</script>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
