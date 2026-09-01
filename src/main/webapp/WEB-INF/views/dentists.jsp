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
                                <i class="fa-solid fa-user-doctor" style="color:var(--primary); margin-right:6px;"></i> ${d.name}
                            </td>
                            <td>
                                <span class="badge badge-completed" style="background:rgba(8, 145, 178, 0.15); color:var(--primary); font-weight:600;">
                                    ${d.specialization}
                                </span>
                            </td>
                            <td>${d.contactNumber != null && !d.contactNumber.isEmpty() ? d.contactNumber : 'N/A'}</td>
                            <td style="font-weight:700; color:var(--success);">
                                LKR <fmt:formatNumber value="${d.consultationFee}" pattern="#,##0.00"/>
                            </td>
                            <td style="text-align:center; white-space:nowrap;">
                                <button type="button" class="btn btn-secondary" 
                                        style="padding:6px 14px; font-size:0.8rem; background:var(--primary); border-color:var(--primary); color:#fff; border-radius:8px; margin-right:4px;"
                                        onclick="openEditDentistModal(${d.id}, '${d.name}', '${d.specialization}', '${d.contactNumber}', ${d.consultationFee})">
                                    <i class="fa-solid fa-pen-to-square"></i> Edit
                                </button>

                                <form action="${pageContext.request.contextPath}/dentists" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to remove ${d.name}?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${d.id}">
                                    <button type="submit" class="btn btn-secondary" style="padding:6px 14px; font-size:0.8rem; background:var(--danger); border-color:var(--danger); color:#fff; border-radius:8px;">
                                        <i class="fa-solid fa-trash"></i> Remove
                                    </button>
                                </form>
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
<div id="editDentistModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15, 23, 42, 0.6); backdrop-filter:blur(6px); z-index:9999; justify-content:center; align-items:center;">
    <div style="background:rgba(255,255,255,0.95); backdrop-filter:blur(16px); border-radius:16px; width:90%; max-width:560px; padding:28px; border:1px solid rgba(255,255,255,0.8); box-shadow:0 20px 40px rgba(0,0,0,0.2); animation: popIn 0.3s ease;">
        <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e2e8f0; padding-bottom:14px; margin-bottom:20px;">
            <h3 style="margin:0; font-size:1.2rem; color:var(--primary-dark); font-weight:700;">
                <i class="fa-solid fa-user-pen" style="color:var(--primary);"></i> Edit Dentist Profile
            </h3>
            <button type="button" onclick="closeEditDentistModal()" style="background:none; border:none; font-size:1.4rem; color:var(--text-muted); cursor:pointer;">&times;</button>
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

<script>
function openEditDentistModal(id, name, specialization, contactNumber, consultationFee) {
    document.getElementById('editDentistId').value = id;
    document.getElementById('editDentistName').value = name;
    document.getElementById('editSpecialization').value = specialization;
    document.getElementById('editContactNumber').value = contactNumber || '';
    document.getElementById('editConsultationFee').value = consultationFee;

    const modal = document.getElementById('editDentistModal');
    modal.style.display = 'flex';
}

function closeEditDentistModal() {
    document.getElementById('editDentistModal').style.display = 'none';
}

// Close modal when clicking outside content box
window.addEventListener('click', function(e) {
    const modal = document.getElementById('editDentistModal');
    if (e.target === modal) {
        closeEditDentistModal();
    }
});
</script>

<style>
@keyframes popIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
}
</style>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
