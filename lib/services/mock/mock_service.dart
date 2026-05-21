// ============================================================================
// lib/services/mock/mock_service.dart
// Mock service layer. Replace each method body with a real API call later.
// All methods return Future<T> with simulated delay to mimic real network.
// ============================================================================

import 'package:ube/models/app_models.dart';
import 'mock_data.dart';

class MockService {
  static const _delay = Duration(milliseconds: 700);

  // ─── Residents ─────────────────────────────────────────────────────────────

  static Future<List<ResidentModel>> getResidents() async {
    await Future.delayed(_delay);
    return List.from(mockResidents);
  }

  static Future<ResidentModel?> getResidentById(String id) async {
    await Future.delayed(_delay);
    try {
      return mockResidents.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Households ────────────────────────────────────────────────────────────

  static Future<List<HouseholdModel>> getHouseholds() async {
    await Future.delayed(_delay);
    return List.from(mockHouseholds);
  }

  static Future<bool> createHousehold(HouseholdModel household) async {
    await Future.delayed(_delay);
    // In real app: POST to /households
    return true;
  }

  // ─── Document Requests ─────────────────────────────────────────────────────

  static Future<List<DocumentRequestModel>> getDocumentRequests() async {
    await Future.delayed(_delay);
    return List.from(mockDocumentRequests);
  }

  static Future<bool> updateDocumentStatus(
    String id,
    RequestStatus status,
  ) async {
    await Future.delayed(_delay);
    // In real app: PATCH /document-requests/:id
    return true;
  }

  static Future<bool> createDocumentRequest(
    DocumentRequestModel request,
  ) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Appointments ──────────────────────────────────────────────────────────

  static Future<List<AppointmentModel>> getAppointments() async {
    await Future.delayed(_delay);
    return List.from(mockAppointments);
  }

  static Future<bool> updateAppointmentStatus(
    String id,
    RequestStatus status,
  ) async {
    await Future.delayed(_delay);
    return true;
  }

  static Future<bool> createAppointment(AppointmentModel appointment) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Incident Reports ──────────────────────────────────────────────────────

  static Future<List<IncidentReportModel>> getIncidentReports() async {
    await Future.delayed(_delay);
    return List.from(mockIncidentReports);
  }

  static Future<bool> createIncidentReport(IncidentReportModel report) async {
    await Future.delayed(_delay);
    return true;
  }

  static Future<bool> updateIncidentStatus(
    String id,
    RequestStatus status,
    String? resolution,
  ) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Emergencies ───────────────────────────────────────────────────────────

  static Future<List<EmergencyModel>> getEmergencies() async {
    await Future.delayed(_delay);
    return List.from(mockEmergencies);
  }

  static Future<bool> updateEmergencyStep(String id, int step) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Staff ─────────────────────────────────────────────────────────────────

  static Future<List<StaffModel>> getStaff() async {
    await Future.delayed(_delay);
    return List.from(mockStaff);
  }

  static Future<bool> createStaff(StaffModel staff) async {
    await Future.delayed(_delay);
    return true;
  }

  static Future<bool> updateStaffStatus(String id, bool isActive) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Attendance ────────────────────────────────────────────────────────────

  static Future<List<AttendanceModel>> getAttendance({String? date}) async {
    await Future.delayed(_delay);
    if (date != null) {
      return mockAttendance.where((a) => a.date == date).toList();
    }
    return List.from(mockAttendance);
  }

  static Future<bool> logAttendance(AttendanceModel attendance) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Tasks ─────────────────────────────────────────────────────────────────

  static Future<List<TaskModel>> getTasks() async {
    await Future.delayed(_delay);
    return List.from(mockTasks);
  }

  static Future<bool> createTask(TaskModel task) async {
    await Future.delayed(_delay);
    return true;
  }

  static Future<bool> updateTaskStatus(String id, RequestStatus status) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Patrol Routes ─────────────────────────────────────────────────────────

  static Future<List<PatrolRouteModel>> getPatrolRoutes() async {
    await Future.delayed(_delay);
    return List.from(mockPatrolRoutes);
  }

  static Future<bool> createPatrolRoute(PatrolRouteModel route) async {
    await Future.delayed(_delay);
    return true;
  }

  static Future<bool> updatePatrolCheckpoint(
    String routeId,
    int checkpointIndex,
  ) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Queue ─────────────────────────────────────────────────────────────────

  static Future<List<QueueTicketModel>> getQueueTickets() async {
    await Future.delayed(_delay);
    return List.from(mockQueueTickets);
  }

  static Future<bool> updateQueueStatus(
    String id,
    QueueStatus status,
  ) async {
    await Future.delayed(_delay);
    return true;
  }

  static Future<bool> addToQueue(QueueTicketModel ticket) async {
    await Future.delayed(_delay);
    return true;
  }

  // ─── Satisfaction Reports ──────────────────────────────────────────────────

  static Future<List<SatisfactionReportModel>> getSatisfactionReports() async {
    await Future.delayed(_delay);
    return List.from(mockSatisfactionReports);
  }

  static Future<bool> submitSatisfactionReport(
    SatisfactionReportModel report,
  ) async {
    await Future.delayed(_delay);
    return true;
  }
}
