<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="content-card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
            <div class="card-title" style="margin:0;"><i class="fa-solid fa-bell"></i> System Audit Logs &amp; Patient Notifications</div>
            <form action="${pageContext.request.contextPath}/notifications" method="POST" style="margin:0;">
                <input type="hidden" name="action" value="dispatch">
                <button type="submit" class="btn btn-primary" style="width:auto;">
                    <i class="fa-solid fa-paper-plane"></i> Trigger Patient Reminders Dispatch
                </button>
            </form>
        </div>

        <div class="table-container">
            <table class="table-glass">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Appt No</th>
                        <th>Recipient Contact</th>
                        <th>Type</th>
                        <th>Message</th>
                        <th>Status</th>
                        <th>Sent At</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${logs}">
                        <tr>
                            <td>${log.id}</td>
                            <td style="font-weight:600; color:var(--primary);">${log.appointmentNumber}</td>
                            <td>${log.recipientContact}</td>
                            <td><span class="badge badge-completed">${log.messageType}</span></td>
                            <td>${log.message}</td>
                            <td><span class="badge ${log.status == 'Sent' ? 'badge-completed' : 'badge-pending'}">${log.status}</span></td>
                            <td>${log.sentAt}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
