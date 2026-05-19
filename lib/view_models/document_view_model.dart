
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document_request.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supabase client shorthand
// ─────────────────────────────────────────────────────────────────────────────
SupabaseClient get _db => Supabase.instance.client;

// ─────────────────────────────────────────────────────────────────────────────
// DocumentViewModel
// ─────────────────────────────────────────────────────────────────────────────
class DocumentViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<DocumentRequest> _documents = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DocumentRequest> get filteredDocuments {
    final q = _searchQuery.toLowerCase().trim();
    if (q.isEmpty) return List.unmodifiable(_documents);
    return _documents
        .where((d) => d.title.toLowerCase().contains(q))
        .toList();
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Fetch documents from Supabase ──────────────────────────────────────────
  Future<void> fetchDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _db
          .from('documents')
          .select()
          .eq('is_published', true)          // show only published docs
          .order('created_at', ascending: false);

      _documents = (response as List<dynamic>)
          .map((row) => DocumentRequest.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      _errorMessage = 'Database error: ${e.message}';
    } on AuthException catch (e) {
      _errorMessage = 'Auth error: ${e.message}';
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('[DocumentViewModel] fetchDocuments error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Submit request → insert into document_requests table ───────────────────
  Future<void> submitRequest({
    required DocumentRequest document,
    required String fullName,
    required String address,
    required String contactNo,
    required String email,
    required String dob,
    required Map<String, String> dynamicValues,
  }) async {
    try {
      final payload = {
        'document_id': document.id,
        'document_title': document.title,
        'amount': document.amount,
        'full_name': fullName,
        'address': address,
        'contact_no': contactNo,
        'email': email.isEmpty ? null : email,
        'date_of_birth': dob,
        'form_values': dynamicValues,
        'status': 'pending',
        'submitted_by': _db.auth.currentUser?.id,
      };

      await _db.from('document_requests').insert(payload);
    } catch (e) {
      debugPrint('[DocumentViewModel] submitRequest error: $e');
      rethrow;
    }
  }
}