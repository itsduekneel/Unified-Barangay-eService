// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SQL — run this once before using the drag-to-place feature:
//
//   alter table documents
//     add column if not exists form_fields jsonb default '[]'::jsonb;
//
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ube/core/utils/route_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// ─────────────────────────────────────────────
// Supabase client shorthand
// ─────────────────────────────────────────────

final _supabase = Supabase.instance.client;

// ─────────────────────────────────────────────
// PlacedField — a field dragged onto the PDF
// ─────────────────────────────────────────────

class PlacedField {
  final String id;
  final String label;
  double xPct; // 0.0–1.0 fraction of container width
  double yPct; // 0.0–1.0 fraction of container height

  PlacedField({
    required this.id,
    required this.label,
    required this.xPct,
    required this.yPct,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'x': xPct,
    'y': yPct,
  };

  factory PlacedField.fromMap(Map<String, dynamic> m) => PlacedField(
    id: m['id']?.toString() ?? UniqueKey().toString(),
    label: m['label']?.toString() ?? '',
    xPct: (m['x'] as num?)?.toDouble() ?? 0,
    yPct: (m['y'] as num?)?.toDouble() ?? 0,
  );
}

// ─────────────────────────────────────────────
// DocumentRequest model
// ─────────────────────────────────────────────

class DocumentRequest {
  final String? id;
  final String title;
  final double amount;
  final bool isPublished;
  final int iconCode;
  final String? pdfName;
  final String? pdfUrl;
  final String status;
  final List<Map<String, dynamic>> formFields;

  const DocumentRequest({
    this.id,
    required this.title,
    required this.amount,
    required this.isPublished,
    required this.iconCode,
    this.pdfName,
    this.pdfUrl,
    this.status = 'pending',
    this.formFields = const [],
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  factory DocumentRequest.fromMap(Map<String, dynamic> map) {
    return DocumentRequest(
      id: map['id'],
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      isPublished: map['is_published'] ?? false,
      iconCode: map['icon_code'] ?? 57701,
      pdfName: map['pdf_name'],
      pdfUrl: map['pdf_url'],
      status: map['status'] ?? 'pending',
      formFields: List<Map<String, dynamic>>.from(
        (map['form_fields'] as List? ?? []).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'is_published': isPublished,
    'icon_code': iconCode,
    'pdf_name': pdfName,
    'pdf_url': pdfUrl,
    'status': status,
    'form_fields': formFields,
  };
}

// ─────────────────────────────────────────────
// Colors
// ─────────────────────────────────────────────

const Color kPrimary = Color(0xFF8B2CF5);
const Color kPrimaryBg = Color(0xFFF4F0FD);

class AppColors {
  static const primary = Color(0xFF8B2CF5);
  static const primaryLight = Color(0xFFEBE0FF);
  static const primarySuperLight = Color(0xFFF5F0FF);
  static const textDark = Color(0xFF1E0447);
}

// ─────────────────────────────────────────────
// Document Issuance Page (list)
// ─────────────────────────────────────────────

class DocumentIssuance extends StatefulWidget {
  const DocumentIssuance({super.key});

  @override
  State<DocumentIssuance> createState() => _DocumentIssuanceState();
}

class _DocumentIssuanceState extends State<DocumentIssuance> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DocumentRequest> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('documents')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _documents = (data as List)
            .map((e) => DocumentRequest.fromMap(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load documents: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  List<DocumentRequest> get _filtered => _documents.where((doc) {
    return _searchQuery.isEmpty ||
        doc.title.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text(
          'Documents',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F4FA),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: kPrimary, size: 20),
            onPressed: () async {
              await Navigator.push(
                context,
                instantRoute(const DocumentCreationPage()),
              );
              _fetchDocuments();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: kPrimary,
        onRefresh: _fetchDocuments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: kPrimary, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: kPrimary,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F0FF),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEBE0FF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEBE0FF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Available Documents",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "${filtered.length} items",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                )
              else if (filtered.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      "No documents yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                        ),
                    itemBuilder: (context, index) => _DocumentCard(
                      doc: filtered[index],
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          instantRoute(
                            DocumentCreationPage(existingDoc: filtered[index]),
                          ),
                        );
                        _fetchDocuments();
                      },
                      onDelete: () => _confirmDelete(filtered[index]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(DocumentRequest doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Document",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _supabase.from('documents').delete().eq('id', doc.id!);
              _fetchDocuments();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Document Card
// ─────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  final DocumentRequest doc;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.doc,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF8B2CF5).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(doc.icon, color: const Color(0xFF8B2CF5)),
            ),
            const SizedBox(height: 12),
            Text(
              doc.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    doc.isPublished ? "Published" : "Unpublished",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: doc.isPublished
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  doc.amount == 0
                      ? "FREE"
                      : "₱${doc.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Document Creation / Edit Page
// ─────────────────────────────────────────────

class DocumentCreationPage extends StatefulWidget {
  final DocumentRequest? existingDoc;
  const DocumentCreationPage({super.key, this.existingDoc});

  @override
  State<DocumentCreationPage> createState() => _DocumentCreationPageState();
}

class _DocumentCreationPageState extends State<DocumentCreationPage> {
  // ── Controllers ──
  late final TextEditingController _titleController;
  late final TextEditingController _feeController;
  final TextEditingController _customFieldController = TextEditingController();

  // ── PDF state ──
  late bool _isPublished;
  bool _hasPdf = false;
  String? _pdfName;
  String? _pdfPath;
  String? _pdfUrl;
  PdfViewerController? _pdfController;

  // ── UI state ──
  int _selectedTab = 0;
  bool _isSaving = false;

  // ── Form field state ──
  static const List<String> _commonFields = [
    'Full Name',
    'Address',
    'Date',
    'Contact No.',
    'Date of Birth',
    'Civil Status',
    'Age',
    'Signature',
  ];

  // User-typed field names added to the palette
  final List<String> _customPaletteFields = [];

  // Fields dropped onto the PDF
  final List<PlacedField> _placedFields = [];

  bool get _isEditing => widget.existingDoc != null;

  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final doc = widget.existingDoc;
    _titleController = TextEditingController(text: doc?.title ?? '');
    _feeController = TextEditingController(
      text: doc != null ? doc.amount.toStringAsFixed(2) : '',
    );
    _isPublished = doc?.isPublished ?? false;
    _pdfName = doc?.pdfName;
    _pdfUrl = doc?.pdfUrl;

    // ✅ Check both name and url
    _hasPdf =
        (_pdfName != null && _pdfName!.isNotEmpty) ||
        (_pdfUrl != null && _pdfUrl!.isNotEmpty);

    // Restore placed fields
    if (doc != null && doc.formFields.isNotEmpty) {
      _placedFields.addAll(doc.formFields.map(PlacedField.fromMap));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _feeController.dispose();
    _customFieldController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Add field name to custom palette
  // ─────────────────────────────────────────────
  void _addCustomField() {
    final label = _customFieldController.text.trim();
    if (label.isEmpty) return;
    if (_customPaletteFields.contains(label) || _commonFields.contains(label)) {
      _customFieldController.clear();
      return;
    }
    setState(() => _customPaletteFields.add(label));
    _customFieldController.clear();
  }

  // ─────────────────────────────────────────────
  // PDF helpers
  // ─────────────────────────────────────────────
  Future<String?> _uploadPdfToStorage(File file, String fileName) async {
    try {
      final path = 'documents/$fileName';
      await _supabase.storage
          .from('pdf-templates')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'application/pdf',
            ),
          );
      return _supabase.storage.from('pdf-templates').getPublicUrl(path);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  void _handleUploadPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final dir = await getApplicationDocumentsDirectory();
        final saved = await file.copy(
          '${dir.path}/${result.files.single.name}',
        );
        setState(() {
          _pdfPath = saved.path;
          _pdfName = result.files.single.name;
          _hasPdf = true;
          _pdfController = PdfViewerController();
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Save
  // ─────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document name is required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      String? pdfUrl = widget.existingDoc?.pdfUrl;

      if (_pdfPath != null) {
        final uploaded = await _uploadPdfToStorage(File(_pdfPath!), _pdfName!);
        if (uploaded != null) {
          pdfUrl = uploaded;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'PDF upload failed. Check your storage bucket permissions.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
      }

      final payload = DocumentRequest(
        id: widget.existingDoc?.id,
        title: _titleController.text.trim(),
        amount: double.tryParse(_feeController.text.trim()) ?? 0,
        isPublished: _isPublished,
        iconCode: 57701,
        pdfName: _pdfName,
        pdfUrl: pdfUrl,
        formFields: _placedFields.map((f) => f.toMap()).toList(),
      ).toMap();

      if (_isEditing) {
        await _supabase
            .from('documents')
            .update(payload)
            .eq('id', widget.existingDoc!.id!);
      } else {
        await _supabase.from('documents').insert(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Document updated!' : 'Document created!',
            ),
            backgroundColor: kPrimary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Document' : 'New Document',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F4FA),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPrimary,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.save_rounded,
                    color: kPrimary,
                    size: 20,
                  ),
                  onPressed: _handleSave,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildActionRow(),
            const SizedBox(height: 16),
            _buildTabSection(),
            const SizedBox(height: 12),

            // ── Custom tab: field palette ──
            if (_selectedTab == 1) ...[
              _buildCustomFieldPalette(),
              const SizedBox(height: 12),
            ],

            // ── PDF area ──
            if (!_hasPdf) _buildPdfSection(),

            if (_hasPdf && _pdfPath != null)
              _buildPdfViewer(
                child: SfPdfViewer.file(
                  File(_pdfPath!),
                  controller: _pdfController,
                  enableDoubleTapZooming: false,
                  enableTextSelection: false,
                ),
              ),

            if (_hasPdf && _pdfPath == null && _pdfUrl != null)
              _buildPdfViewer(
                child: SfPdfViewer.network(
                  _pdfUrl!,
                  enableDoubleTapZooming: false,
                  enableTextSelection: false,
                  onDocumentLoadFailed: (_) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _hasPdf = false;
                          _pdfUrl = null;
                        });
                      }
                    });
                  },
                ),
              ),

            if (_hasPdf && _pdfPath == null && _pdfUrl == null)
              _buildPdfSection(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Custom Field Palette
  // ─────────────────────────────────────────────
  Widget _buildCustomFieldPalette() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.primarySuperLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: kPrimary,
                  size: 15,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drag a field onto the PDF below to place it.\nLong-press a placed field to remove it.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Custom field input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _customFieldController,
                    style: const TextStyle(fontSize: 13),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Purok, Precinct No., Purpose...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.text_fields_rounded,
                        color: kPrimary,
                        size: 18,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addCustomField(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addCustomField,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Common fields
          Text(
            'Common Fields — drag onto the PDF',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonFields
                .map((l) => _DraggableChip(label: l))
                .toList(),
          ),

          // User-added custom fields
          if (_customPaletteFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Your Fields',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _customPaletteFields
                  .map(
                    (l) => _DraggableChip(
                      label: l,
                      onDelete: () =>
                          setState(() => _customPaletteFields.remove(l)),
                    ),
                  )
                  .toList(),
            ),
          ],

          // Placed field summary
          if (_placedFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: kPrimary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_placedFields.length} field(s) placed on PDF',
                  style: const TextStyle(
                    fontSize: 11,
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _placedFields.clear()),
                  child: Text(
                    'Clear all',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade400),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PDF Viewer with DragTarget + placed-field overlays
  // ─────────────────────────────────────────────
  Widget _buildPdfViewer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 480,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cw = constraints.maxWidth;
            final ch = constraints.maxHeight;

            return Stack(
              children: [
                // PDF content
                Positioned.fill(child: child),

                // DragTarget — only active on Custom tab
                if (_selectedTab == 1)
                  Positioned.fill(
                    child: DragTarget<String>(
                      onWillAcceptWithDetails: (_) => true,
                      onAcceptWithDetails: (details) {
                        final box = context.findRenderObject() as RenderBox;
                        final localPos = box.globalToLocal(details.offset);
                        setState(() {
                          _placedFields.add(
                            PlacedField(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              label: details.data,
                              xPct: (localPos.dx / cw).clamp(0.01, 0.78),
                              yPct: (localPos.dy / ch).clamp(0.01, 0.93),
                            ),
                          );
                        });
                      },
                      builder: (ctx, candidates, _) => candidates.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.07),
                                border: Border.all(
                                  color: kPrimary.withOpacity(0.35),
                                  width: 2,
                                ),
                              ),
                            )
                          : const SizedBox.expand(),
                    ),
                  ),

                // Placed field overlays (always visible)
                ..._placedFields.map(
                  (field) => _PlacedFieldOverlay(
                    key: ValueKey(field.id),
                    field: field,
                    containerW: cw,
                    containerH: ch,
                    editMode: _selectedTab == 1,
                    onMove: (dx, dy) {
                      setState(() {
                        field.xPct = ((field.xPct * cw + dx) / cw).clamp(
                          0.01,
                          0.78,
                        );
                        field.yPct = ((field.yPct * ch + dy) / ch).clamp(
                          0.01,
                          0.93,
                        );
                      });
                    },
                    onDelete: () => setState(() => _placedFields.remove(field)),
                  ),
                ),

                // Drop hint when Custom tab and no fields placed yet
                if (_selectedTab == 1 && _placedFields.isEmpty)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Drag fields here to place them',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Replace button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _handleUploadPdf,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Replace',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Action Row
  // ─────────────────────────────────────────────
  Widget _buildActionRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPublishToggle(),
              const Spacer(),
              _buildPreviewPill(),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Document Name',
            icon: Icons.description_outlined,
            controller: _titleController,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Fee',
            icon: Icons.payments_outlined,
            controller: _feeController,
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPublishToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isPublished = !_isPublished),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 38,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isPublished ? kPrimary : Colors.grey.shade300,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: _isPublished
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(2),
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _isPublished ? 'Publish' : 'Unpublish',
          style: TextStyle(
            color: _isPublished
                ? const Color(0xFF2E7D32)
                : const Color(0xFFD32F2F),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.1)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove_red_eye_outlined, size: 14, color: kPrimary),
          SizedBox(width: 4),
          Text(
            "Preview",
            style: TextStyle(
              color: kPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: controller,
              keyboardType: isNumber
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: isNumber ? '₱ 0.00' : 'Enter $label',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(icon, size: 18, color: kPrimary),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tab Section
  // ─────────────────────────────────────────────
  Widget _buildTabSection() {
    const tabLabels = ['View', 'Forms', 'Editor'];
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: List.generate(tabLabels.length, (index) {
                final isActive = _selectedTab == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? kPrimaryBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? kPrimary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabLabels[index],
                          style: TextStyle(
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                            color: isActive ? kPrimary : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Editor toolbar
          AnimatedCrossFade(
            firstChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _toolbarBtn(Icons.format_bold_rounded),
                    _toolbarBtn(Icons.format_italic_rounded),
                    _toolbarBtn(Icons.format_underline_rounded),
                    const VerticalDivider(width: 20),
                    _toolbarBtn(Icons.format_list_bulleted_rounded),
                    _toolbarBtn(Icons.format_list_numbered_rounded),
                    _toolbarBtn(Icons.format_indent_increase_rounded),
                    const VerticalDivider(width: 20),
                    _toolbarBtn(Icons.link_rounded),
                    _toolbarBtn(Icons.image_outlined),
                  ],
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _selectedTab == 2
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _toolbarBtn(IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Empty PDF Prompt
  // ─────────────────────────────────────────────
  Widget _buildPdfSection() {
    return GestureDetector(
      onTap: _handleUploadPdf,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primaryLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primarySuperLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No PDF uploaded',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to attach a PDF template',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Draggable Chip (palette item)
// ─────────────────────────────────────────────

class _DraggableChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;

  const _DraggableChip({required this.label, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySuperLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.drag_indicator_rounded, size: 13, color: kPrimary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: kPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 5),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close_rounded, size: 13, color: kPrimary),
            ),
          ],
        ],
      ),
    );

    final feedback = Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.drag_indicator_rounded,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Draggable<String>(
      data: label,
      feedback: feedback,
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
// Placed Field Overlay (rendered on the PDF)
// ─────────────────────────────────────────────

class _PlacedFieldOverlay extends StatelessWidget {
  final PlacedField field;
  final double containerW;
  final double containerH;
  final bool editMode;
  final void Function(double dx, double dy) onMove;
  final VoidCallback onDelete;

  const _PlacedFieldOverlay({
    super.key,
    required this.field,
    required this.containerW,
    required this.containerH,
    required this.editMode,
    required this.onMove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: field.xPct * containerW,
      top: field.yPct * containerH,
      child: GestureDetector(
        onPanUpdate: editMode ? (d) => onMove(d.delta.dx, d.delta.dy) : null,
        onLongPress: editMode ? onDelete : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: kPrimary, width: 1.5),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.18),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (editMode) ...[
                const Icon(
                  Icons.drag_indicator_rounded,
                  size: 11,
                  color: kPrimary,
                ),
                const SizedBox(width: 3),
              ],
              Text(
                field.label,
                style: const TextStyle(
                  fontSize: 10,
                  color: kPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (editMode) ...[
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close_rounded,
                    size: 11,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────
