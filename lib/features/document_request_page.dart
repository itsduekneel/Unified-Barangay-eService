import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

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
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  factory DocumentRequest.fromMap(Map<String, dynamic> map) {
    return DocumentRequest(
      id: map['id'].toString(),
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

class DocumentRequestsScreen extends StatefulWidget {
  const DocumentRequestsScreen({super.key});

  @override
  State<DocumentRequestsScreen> createState() => _DocumentRequestsScreenState();
}

class _DocumentRequestsScreenState extends State<DocumentRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<DocumentRequest> _allDocuments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await Supabase.instance.client
          .from('documents') // 👈 changed here
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _allDocuments = (data as List)
            .map((e) => DocumentRequest.fromMap(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load documents: $e';
        _isLoading = false;
      });
    }
  }

  List<DocumentRequest> get _filteredDocuments {
    return _allDocuments.where((doc) {
      return _searchQuery.isEmpty ||
          doc.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDocuments;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text(
          'Document Requests',
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
            color: Color(0xFF8B2CF5),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8B2CF5),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8B2CF5),
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
                    borderSide: const BorderSide(color: Color(0xFF8B2CF5)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // HEADER
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
                      color: Color(0xFF8B2CF5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // STATES: Loading / Error / Empty / Grid
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF8B2CF5)),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _fetchDocuments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'No documents found.',
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
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) =>
                      _DocumentCard(doc: filtered[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentRequest doc;

  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👈 idagdag ito
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentRequestFormScreen(document: doc),
        ),
      ),
      child: Container(
        // 👈 yung dati mong Container, ilagay sa loob
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
                  "₱${doc.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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
// Design tokens
// ─────────────────────────────────────────────

const Color kPrimary = Color(0xFF8B2CF5);
const Color kPrimaryLight = Color(0xFFEDE8FF);
const Color kPrimaryMid = Color(0xFFA07FF5);
const Color kInk = Color(0xFF1A1033);
const Color kInk2 = Color(0xFF6B6480);
const Color kInk3 = Color(0xFFA09BB5);
const Color kSurface = Color(0xFFFAFAF9);
const Color kCard = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFE8E3F2);
const Color kSuccess = Color(0xFF16A360);
const Color kSuccessLight = Color(0xFFE8F7EF);
const Color kWarn = Color(0xFFF59E0B);
const Color kWarnLight = Color(0xFFFEF3C7);
const Color kDanger = Color(0xFFDC2626);

// ─────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────

class DocumentRequestFormScreen extends StatefulWidget {
  final DocumentRequest document;
  const DocumentRequestFormScreen({super.key, required this.document});

  @override
  State<DocumentRequestFormScreen> createState() =>
      _DocumentRequestFormScreenState();
}

class _DocumentRequestFormScreenState extends State<DocumentRequestFormScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // ── Personal controllers ──
  final _personalFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();

  // ── Dynamic field controllers ──
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  // ── Animation ──
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.document.formFields)
        (field['label'] as String? ?? ''): TextEditingController(),
    };
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _animateIn() {
    _slideController.reset();
    _slideController.forward();
  }

  // ── Navigation ──

  void _next() {
    if (_currentStep == 0) {
      if (!_personalFormKey.currentState!.validate()) return;
    }
    if (_currentStep == 1) {
      if (_controllers.isNotEmpty && !_formKey.currentState!.validate()) return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _animateIn();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animateIn();
    }
  }

  // ── Submit ──

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final res = await Supabase.instance.client
          .from('document_requests')
          .insert({
            'document_id': widget.document.id,
            'full_name': _nameController.text.trim(),
            'address': _addressController.text.trim(),
            'contact_no': _contactController.text.trim(),
            'email': _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            'date_of_birth': _birthdateController.text,
            'form_values': {
              for (var e in _controllers.entries) e.key: e.value.text.trim(),
            },
          })
          .select()
          .single();

      print('SUCCESS: $res');

      if (mounted) _showSuccess();
    } catch (e) {
      print('ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.document.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: kInk,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Document header card ──
          _DocumentHeaderCard(document: widget.document),

          // ── Step indicator ──
          _StepIndicator(currentStep: _currentStep),

          // ── Form area ──
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildCurrentStep(),
              ),
            ),
          ),

          // ── Bottom bar ──
          _BottomBar(
            currentStep: _currentStep,
            isSubmitting: _isSubmitting,
            onBack: _back,
            onNext: _currentStep == 2 ? _submit : _next,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _Step1Personal(
          key: const ValueKey('s1'),
          formKey: _personalFormKey,
          nameController: _nameController,
          addressController: _addressController,
          contactController: _contactController,
          emailController: _emailController,
          birthdateController: _birthdateController,
        );
      case 1:
        return _Step2Requirements(
          key: const ValueKey('s2'),
          formKey: _formKey,
          fields: widget.document.formFields,
          controllers: _controllers,
        );
      case 2:
        return _Step3Confirm(
          key: const ValueKey('s3'),
          document: widget.document,
          name: _nameController.text,
          address: _addressController.text,
          contact: _contactController.text,
          email: _emailController.text,
          birthdate: _birthdateController.text,
          dynamicValues: {
            for (var e in _controllers.entries) e.key: e.value.text,
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showSuccess() {
    final trackingId = 'BRG-${(Random().nextInt(90000) + 10000)}';
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => _SuccessScreen(
          documentTitle: widget.document.title,
          trackingId: trackingId,
        ),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Document Header Card
// ─────────────────────────────────────────────

class _DocumentHeaderCard extends StatelessWidget {
  final DocumentRequest document;
  const _DocumentHeaderCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(document.icon, color: kPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: kInk,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'Processing fee',
                      style: TextStyle(fontSize: 11, color: kInk2),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        document.amount == 0
                            ? 'FREE'
                            : '₱ ${document.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step Indicator
// ─────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Personal', 'Details', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(3, (i) {
          final isDone = i < currentStep;
          final isActive = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone || isActive ? kPrimary : kCard,
                          border: Border.all(
                            color: isDone || isActive ? kPrimary : kBorder,
                            width: 2,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.25),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : kInk3,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive || isDone ? kPrimary : kInk3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        height: 2,
                        decoration: BoxDecoration(
                          color: isDone ? kPrimary : kBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 1 — Personal Details
// ─────────────────────────────────────────────

class _Step1Personal extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController contactController;
  final TextEditingController emailController;
  final TextEditingController birthdateController;

  const _Step1Personal({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.addressController,
    required this.contactController,
    required this.emailController,
    required this.birthdateController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      child: _FormCard(
        eyebrow: 'Step 1 of 3',
        eyebrowIcon: Icons.person_outline_rounded,
        title: 'Who are you?',
        subtitle:
            'Please fill in your personal information to proceed with this request.',
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _FieldInput(
                label: 'Full Name',
                controller: nameController,
                icon: Icons.person_outline_rounded,
                hint: 'Juan dela Cruz',
                keyboard: TextInputType.name,
                required: true,
              ),
              _FieldInput(
                label: 'Home Address',
                controller: addressController,
                icon: Icons.location_on_outlined,
                hint: 'House No., Street, Barangay, City',
                keyboard: TextInputType.streetAddress,
                maxLines: 2,
                required: true,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FieldInput(
                      label: 'Contact No.',
                      controller: contactController,
                      icon: Icons.phone_outlined,
                      hint: '09XXXXXXXXX',
                      keyboard: TextInputType.phone,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateFieldInput(
                      label: 'Date of Birth',
                      controller: birthdateController,
                      required: true,
                    ),
                  ),
                ],
              ),
              _FieldInput(
                label: 'Email Address',
                controller: emailController,
                icon: Icons.mail_outline_rounded,
                hint: 'Optional',
                keyboard: TextInputType.emailAddress,
                required: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 2 — Dynamic Requirements
// ─────────────────────────────────────────────

class _Step2Requirements extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Map<String, dynamic>> fields;
  final Map<String, TextEditingController> controllers;

  const _Step2Requirements({
    super.key,
    required this.formKey,
    required this.fields,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      child: _FormCard(
        eyebrow: 'Step 2 of 3',
        eyebrowIcon: Icons.edit_note_rounded,
        title: 'A few more details',
        subtitle:
            'These fields are specific to the document you\'re requesting.',
        child: fields.isEmpty
            ? _EmptyFields()
            : Form(
                key: formKey,
                child: Column(
                  children: [
                    _InfoBanner(
                      message:
                          'Your answers here will be pre-filled onto the document template by the barangay staff.',
                    ),
                    const SizedBox(height: 8),
                    ...fields.map((field) {
                      final label = field['label'] as String? ?? '';
                      if (label.isEmpty) return const SizedBox.shrink();
                      final ctrl = controllers[label]!;
                      if (label.toLowerCase().contains('date')) {
                        return _DateFieldInput(
                          label: label,
                          controller: ctrl,
                          required: true,
                        );
                      }
                      return _FieldInput(
                        label: label,
                        controller: ctrl,
                        icon: _inferIcon(label),
                        hint: 'Enter $label',
                        keyboard: _inferKeyboard(label),
                        required: true,
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }

  IconData _inferIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('contact') || l.contains('phone')) {
      return Icons.phone_outlined;
    }
    if (l.contains('age')) return Icons.numbers_rounded;
    if (l.contains('email')) return Icons.mail_outline_rounded;
    if (l.contains('purpose')) return Icons.description_outlined;
    if (l.contains('civil') || l.contains('status')) {
      return Icons.people_outline_rounded;
    }
    return Icons.short_text_rounded;
  }

  TextInputType _inferKeyboard(String label) {
    final l = label.toLowerCase();
    if (l.contains('contact') || l.contains('phone') || l.contains('no.')) {
      return TextInputType.phone;
    }
    if (l.contains('age')) return TextInputType.number;
    if (l.contains('email')) return TextInputType.emailAddress;
    return TextInputType.text;
  }
}

// ─────────────────────────────────────────────
// Step 3 — Confirm
// ─────────────────────────────────────────────

class _Step3Confirm extends StatelessWidget {
  final DocumentRequest document;
  final String name, address, contact, email, birthdate;
  final Map<String, String> dynamicValues;

  const _Step3Confirm({
    super.key,
    required this.document,
    required this.name,
    required this.address,
    required this.contact,
    required this.email,
    required this.birthdate,
    required this.dynamicValues,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      child: _FormCard(
        eyebrow: 'Step 3 of 3',
        eyebrowIcon: Icons.fact_check_outlined,
        title: 'Confirm your request',
        subtitle: 'Please review all details carefully before submitting.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document row
            _ReviewSection(
              title: 'Document',
              rows: [
                _ReviewRow(label: 'Type', value: document.title),
                _ReviewRow(
                  label: 'Fee',
                  value: document.amount == 0
                      ? 'FREE'
                      : '₱ ${document.amount.toStringAsFixed(2)}',
                  valueColor: kPrimary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Personal details
            _ReviewSection(
              title: 'Personal Details',
              rows: [
                _ReviewRow(label: 'Full Name', value: name),
                _ReviewRow(label: 'Address', value: address),
                _ReviewRow(label: 'Contact No.', value: contact),
                if (email.isNotEmpty) _ReviewRow(label: 'Email', value: email),
                _ReviewRow(label: 'Date of Birth', value: birthdate),
              ],
            ),

            if (dynamicValues.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ReviewSection(
                title: 'Requirements',
                rows: dynamicValues.entries
                    .map((e) => _ReviewRow(label: e.key, value: e.value))
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Warning note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kWarnLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kWarn.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: kWarn, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Changes cannot be made after submission. The barangay office will process your request within 1–3 business days.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Success Screen (full page)
// ─────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  final String documentTitle;
  final String trackingId;
  const _SuccessScreen({required this.documentTitle, required this.trackingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated checkmark ring
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kSuccessLight,
                      border: Border.all(
                        color: kSuccess.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: kSuccess,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Request Submitted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your $documentTitle request has been received.\nYou\'ll be notified once it\'s ready for pickup.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kInk2,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                // Tracking ID chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sell_outlined,
                        size: 14,
                        color: kPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tracking ID: ',
                        style: TextStyle(fontSize: 12, color: kInk2),
                      ),
                      Text(
                        trackingId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info note
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPrimary.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: kPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Estimated processing time: 1–3 business days.\nPlease bring a valid ID when claiming your document.',
                          style: TextStyle(
                            fontSize: 12,
                            color: kPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Done button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom Bar
// ─────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentStep;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomBar({
    required this.currentStep,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == 2;
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        12,
        14,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: kCard,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorder, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: kInk2,
                ),
                child: const Text(
                  '← Back',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: kPrimary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isLast ? 'Submit Request ✓' : 'Continue →',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Form Card
// ─────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final String eyebrow;
  final IconData eyebrowIcon;
  final String title;
  final String subtitle;
  final Widget child;

  const _FormCard({
    required this.eyebrow,
    required this.eyebrowIcon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Row(
            children: [
              Icon(eyebrowIcon, color: kPrimary, size: 13),
              const SizedBox(width: 5),
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: kInk,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: kInk2, height: 1.5),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Field Input
// ─────────────────────────────────────────────

class _FieldInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboard;
  final bool required;
  final int maxLines;

  const _FieldInput({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboard = TextInputType.text,
    this.required = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: label, required: required),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 13,
              color: kInk,
              fontWeight: FontWeight.w500,
            ),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty)
                      ? '$label is required'
                      : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: kInk3, fontSize: 13),
              prefixIcon: Icon(icon, size: 17, color: kInk3),
              filled: true,
              fillColor: kSurface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kDanger, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kDanger, width: 1.5),
              ),
              errorStyle: const TextStyle(fontSize: 11, color: kDanger),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Date Field Input
// ─────────────────────────────────────────────

class _DateFieldInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;

  const _DateFieldInput({
    required this.label,
    required this.controller,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: label, required: required),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(
              fontSize: 13,
              color: kInk,
              fontWeight: FontWeight.w500,
            ),
            validator: required
                ? (v) => (v == null || v.isEmpty) ? 'Required' : null
                : null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: kPrimary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                controller.text =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              }
            },
            decoration: InputDecoration(
              hintText: 'Select date',
              hintStyle: const TextStyle(color: kInk3, fontSize: 13),
              prefixIcon: const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: kInk3,
              ),
              filled: true,
              fillColor: kSurface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kDanger, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: kDanger, width: 1.5),
              ),
              errorStyle: const TextStyle(fontSize: 11, color: kDanger),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Field Label
// ─────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kInk,
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: kDanger, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Info Banner
// ─────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPrimary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: kPrimary, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: kPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Empty Fields State
// ─────────────────────────────────────────────

class _EmptyFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: kPrimary,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'No additional fields required.',
            style: TextStyle(color: kInk2, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Review Section
// ─────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<_ReviewRow> rows;
  const _ReviewSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kInk3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ReviewRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: kInk2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
