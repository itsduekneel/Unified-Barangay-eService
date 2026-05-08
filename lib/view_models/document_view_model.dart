import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document_request.dart';

class DocumentViewModel extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<DocumentRequest> _allDocuments = [];
  List<DocumentRequest> get allDocuments => _allDocuments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<DocumentRequest> get filteredDocuments {
    return _allDocuments.where((doc) {
      return _searchQuery.isEmpty ||
          doc.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _client
          .from('documents')
          .select()
          .eq('is_published', true)
          .order('created_at', ascending: false);

      _allDocuments = (data as List)
          .map((e) => DocumentRequest.fromMap(e))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> submitRequest({
    required DocumentRequest document,
    required String fullName,
    required String address,
    required String contactNo,
    required String? email,
    required String dob,
    required Map<String, String> dynamicValues,
  }) async {
    try {
      final res = await _client
          .from('document_requests')
          .insert({
            'document_id': document.id,
            'full_name': fullName,
            'address': address,
            'contact_no': contactNo,
            'email': email?.isEmpty ?? true ? null : email,
            'date_of_birth': dob,
            'form_values': dynamicValues,
          })
          .select()
          .single();
      return res;
    } catch (e) {
      rethrow;
    }
  }
}
