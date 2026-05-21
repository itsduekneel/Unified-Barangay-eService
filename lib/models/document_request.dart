// lib/models/document_request.dart
import 'package:flutter/material.dart';
class DocumentRequest {
  final String id;
  final String title;
  final double amount;
  final bool isPublished;
  final int iconCode;
  final String? pdfName;
  final String? pdfUrl;
  final String status;
  final List<Map<String, dynamic>> formFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentRequest({
    required this.id,
    required this.title,
    required this.amount,
    required this.isPublished,
    required this.iconCode,
    this.pdfName,
    this.pdfUrl,
    required this.status,
    required this.formFields,
    required this.createdAt,
    required this.updatedAt,
  });
  IconData get icon =>
      IconData(iconCode, fontFamily: 'MaterialIcons');

  factory DocumentRequest.fromJson(Map<String, dynamic> json) {
    return DocumentRequest(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPublished: json['is_published'] as bool,
      iconCode: json['icon_code'] as int,
      pdfName: json['pdf_name'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      status: json['status'] as String,
      formFields: (json['form_fields'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'is_published': isPublished,
    'icon_code': iconCode,
    'pdf_name': pdfName,
    'pdf_url': pdfUrl,
    'status': status,
    'form_fields': formFields,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}