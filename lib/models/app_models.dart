// ============================================================================
// lib/models/app_models.dart
// Shared model classes for the Barangay Management System.
// Designed for easy Supabase/REST API replacement later.
// ============================================================================

import 'package:flutter/material.dart';

// ─── Enums ──────────────────────────────────────────────────────────────────

enum RequestStatus { pending, approved, rejected, completed, cancelled }

enum EmergencyLevel { low, medium, high, critical }

enum IncidentSeverity { minor, moderate, severe }

enum QueueStatus { waiting, serving, completed, noShow }

enum AttendanceStatus { present, absent, late, onLeave }

// ─── Resident / Household Models ────────────────────────────────────────────

class ResidentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String middleName;
  final String dateOfBirth;
  final String gender;
  final String contactNo;
  final String email;
  final String address;
  final String purok;
  final String householdId;
  final bool isActive;
  final String dateRegistered;
  final String role; // 'Head' or 'Member'

  const ResidentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNo,
    required this.email,
    required this.address,
    required this.purok,
    required this.householdId,
    required this.isActive,
    required this.dateRegistered,
    required this.role,
  });

  String get fullName => '$firstName $middleName $lastName'.trim();
}

class HouseholdModel {
  final String id;
  final String unitNo;
  final String streetAddress;
  final String purok;
  final List<ResidentModel> members;
  final String dateCreated;

  const HouseholdModel({
    required this.id,
    required this.unitNo,
    required this.streetAddress,
    required this.purok,
    required this.members,
    required this.dateCreated,
  });

  ResidentModel? get head =>
      members.where((m) => m.role == 'Head').firstOrNull;
  int get memberCount => members.length;
}

// ─── Document Request Model ──────────────────────────────────────────────────

class DocumentRequestModel {
  final String id;
  final String residentId;
  final String residentName;
  final String documentType;
  final String purpose;
  final String dateRequested;
  final String? dateCompleted;
  final RequestStatus status;
  final double fee;
  final String? trackingNumber;
  final String? notes;

  const DocumentRequestModel({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.documentType,
    required this.purpose,
    required this.dateRequested,
    this.dateCompleted,
    required this.status,
    required this.fee,
    this.trackingNumber,
    this.notes,
  });
}

// ─── Appointment Model ───────────────────────────────────────────────────────

class AppointmentModel {
  final String id;
  final String residentId;
  final String residentName;
  final String title;
  final String type;
  final String date;
  final String time;
  final RequestStatus status;
  final String notes;
  final String? assignedStaff;

  const AppointmentModel({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.title,
    required this.type,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
    this.assignedStaff,
  });
}

// ─── Incident Report Model ───────────────────────────────────────────────────

class IncidentReportModel {
  final String id;
  final String reportedBy;
  final String residentId;
  final String title;
  final String description;
  final String location;
  final String dateReported;
  final String timeReported;
  final IncidentSeverity severity;
  final RequestStatus status;
  final String? assignedOfficer;
  final String? resolution;

  const IncidentReportModel({
    required this.id,
    required this.reportedBy,
    required this.residentId,
    required this.title,
    required this.description,
    required this.location,
    required this.dateReported,
    required this.timeReported,
    required this.severity,
    required this.status,
    this.assignedOfficer,
    this.resolution,
  });
}

// ─── Emergency Model ─────────────────────────────────────────────────────────

class EmergencyModel {
  final String id;
  final String reportedBy;
  final String residentId;
  final String type;
  final String location;
  final String description;
  final EmergencyLevel level;
  final String dateTime;
  final RequestStatus status;
  final String? responderId;
  final String? responderName;
  final int currentStep; // 0=Pending, 1=Assigned, 2=Responding, 3=Completed

  const EmergencyModel({
    required this.id,
    required this.reportedBy,
    required this.residentId,
    required this.type,
    required this.location,
    required this.description,
    required this.level,
    required this.dateTime,
    required this.status,
    this.responderId,
    this.responderName,
    required this.currentStep,
  });
}

// ─── Staff / Attendance Model ────────────────────────────────────────────────

class StaffModel {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String department;
  final String contactNo;
  final String email;
  final bool isActive;
  final String dateHired;

  const StaffModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.department,
    required this.contactNo,
    required this.email,
    required this.isActive,
    required this.dateHired,
  });

  String get fullName => '$firstName $lastName';
}

class AttendanceModel {
  final String id;
  final String staffId;
  final String staffName;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final AttendanceStatus status;
  final String? notes;

  const AttendanceModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.date,
    this.timeIn,
    this.timeOut,
    required this.status,
    this.notes,
  });
}

// ─── Task Assignment Model ───────────────────────────────────────────────────

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedToId;
  final String assignedBy;
  final String deadline;
  final String dateCreated;
  final RequestStatus status;
  final String priority; // 'Low', 'Medium', 'High'
  final String category;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToId,
    required this.assignedBy,
    required this.deadline,
    required this.dateCreated,
    required this.status,
    required this.priority,
    required this.category,
  });
}

// ─── Patrol Model (Tanod) ────────────────────────────────────────────────────

class PatrolRouteModel {
  final String id;
  final String name;
  final List<String> checkpoints;
  final String startTime;
  final String endTime;
  final String assignedTanod;
  final String assignedTanodId;
  final String date;
  final String status; // 'Scheduled', 'Active', 'Completed'
  final int completedCheckpoints;

  const PatrolRouteModel({
    required this.id,
    required this.name,
    required this.checkpoints,
    required this.startTime,
    required this.endTime,
    required this.assignedTanod,
    required this.assignedTanodId,
    required this.date,
    required this.status,
    required this.completedCheckpoints,
  });

  double get progress =>
      checkpoints.isEmpty ? 0 : completedCheckpoints / checkpoints.length;
}

// ─── Queue Model ─────────────────────────────────────────────────────────────

class QueueTicketModel {
  final String id;
  final String ticketNumber;
  final String residentName;
  final String residentId;
  final String service;
  final String dateTime;
  final QueueStatus status;
  final int? windowNo;
  final String? staffName;
  final int estimatedWaitMinutes;

  const QueueTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.residentName,
    required this.residentId,
    required this.service,
    required this.dateTime,
    required this.status,
    this.windowNo,
    this.staffName,
    required this.estimatedWaitMinutes,
  });
}

// ─── Satisfaction Report Model ───────────────────────────────────────────────

class SatisfactionReportModel {
  final String id;
  final String residentId;
  final String residentName;
  final String service;
  final int rating; // 1–5
  final String comment;
  final String date;
  final String staffName;

  const SatisfactionReportModel({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.service,
    required this.rating,
    required this.comment,
    required this.date,
    required this.staffName,
  });
}

// ─── RBAC Role Model ─────────────────────────────────────────────────────────

class RolePermissionModel {
  final String id;
  final String roleName;
  final String description;
  final List<String> permissions;
  final int userCount;
  final Color accentColor;

  const RolePermissionModel({
    required this.id,
    required this.roleName,
    required this.description,
    required this.permissions,
    required this.userCount,
    required this.accentColor,
  });
}
