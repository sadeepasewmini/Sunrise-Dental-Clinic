package com.sunrisedental.servlet;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Bill;
import com.sunrisedental.model.Dentist;
import com.sunrisedental.model.Treatment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/billing")
public class BillingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final BillDAO billDAO = new BillDAO();
    private final TreatmentDAO treatmentDAO = new TreatmentDAO();
    private final DentistDAO dentistDAO = new DentistDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("print".equalsIgnoreCase(action)) {
            handlePrintReceipt(request, response);
            return;
        }

        request.setAttribute("activeMenu", "billing");
        request.getRequestDispatcher("/WEB-INF/views/billing.jsp").forward(request, response);
    }

    private void handlePrintReceipt(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apptNumber = request.getParameter("number");
        if (apptNumber != null && !apptNumber.trim().isEmpty()) {
            Appointment appt = appointmentDAO.getAppointmentByNumber(apptNumber.trim());
            Bill bill = billDAO.getBillByAppointmentNumber(apptNumber.trim());
            if (appt != null) {
                request.setAttribute("appointment", appt);
                request.setAttribute("bill", bill);
                request.getRequestDispatcher("/WEB-INF/views/invoice-print.jsp").forward(request, response);
                return;
            }
        }
        response.sendRedirect(request.getContextPath() + "/billing");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("calculate".equalsIgnoreCase(action)) {
            handleCalculate(request, response);
        } else if ("save".equalsIgnoreCase(action)) {
            handleSaveBill(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/billing");
        }
    }

    private void handleCalculate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apptNumber = request.getParameter("appointmentNumber");
        String strategyType = request.getParameter("billingStrategy");
        double manualDiscount = 0.0;
        try {
            if (request.getParameter("manualDiscount") != null) {
                manualDiscount = Double.parseDouble(request.getParameter("manualDiscount"));
            }
        } catch (Exception ignored) {}

        Appointment appt = appointmentDAO.getAppointmentByNumber(apptNumber != null ? apptNumber.trim() : "");
        if (appt == null) {
            request.setAttribute("errorMessage", "Appointment not found for number: " + apptNumber);
            request.setAttribute("activeMenu", "billing");
            request.getRequestDispatcher("/WEB-INF/views/billing.jsp").forward(request, response);
            return;
        }

        Treatment treatment = treatmentDAO.getTreatmentById(appt.getTreatmentId());
        Dentist dentist = dentistDAO.getDentistById(appt.getDentistId());
        
        double treatmentCost = (treatment != null) ? treatment.getCost() : 3000.0;
        double consultationFee = (dentist != null) ? dentist.getConsultationFee() : 1000.0;
        double baseFee = treatmentCost + consultationFee;

        double strategyDiscountRate = 0.0;
        if ("insurance".equalsIgnoreCase(strategyType)) {
            strategyDiscountRate = 0.50; // 50% insurance discount
        } else if ("discount".equalsIgnoreCase(strategyType)) {
            strategyDiscountRate = 0.10; // 10% promotional discount
        }

        double totalDiscount = (baseFee * strategyDiscountRate) + manualDiscount;
        double netCost = Math.max(0.0, baseFee - totalDiscount);

        Bill bill = new Bill();
        bill.setAppointmentNumber(appt.getAppointmentNumber());
        bill.setConsultationFee(consultationFee);
        bill.setTreatmentCost(treatmentCost);
        bill.setDiscountAmount(totalDiscount);
        bill.setTotalCost(baseFee);
        bill.setNetCost(netCost);
        bill.setStatus("Pending");

        request.setAttribute("appointment", appt);
        request.setAttribute("bill", bill);
        request.setAttribute("selectedStrategy", strategyType);
        request.setAttribute("manualDiscount", manualDiscount);
        request.setAttribute("activeMenu", "billing");

        request.getRequestDispatcher("/WEB-INF/views/billing.jsp").forward(request, response);
    }

    private void handleSaveBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String apptNumber = request.getParameter("appointmentNumber");
            double discountAmount = Double.parseDouble(request.getParameter("discountAmount"));
            String paymentStatus = request.getParameter("paymentStatus");

            int billId = billDAO.generateBill(apptNumber, discountAmount);
            if (billId > 0) {
                if ("Paid".equalsIgnoreCase(paymentStatus)) {
                    billDAO.markAsPaid(apptNumber);
                    appointmentDAO.updateStatus(apptNumber, "Completed");
                    request.getSession().setAttribute("successMessage", "Bill generated & marked as PAID successfully!");
                } else {
                    request.getSession().setAttribute("successMessage", "Bill generated as UNPAID (Pending) successfully!");
                }
                response.sendRedirect(request.getContextPath() + "/billing?action=print&number=" + apptNumber);
                return;
            } else {
                request.setAttribute("errorMessage", "Failed to generate bill.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error generating bill: " + e.getMessage());
        }
        request.setAttribute("activeMenu", "billing");
        request.getRequestDispatcher("/WEB-INF/views/billing.jsp").forward(request, response);
    }
}
