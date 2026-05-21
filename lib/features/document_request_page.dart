import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/document_request.dart';
import '../view_models/document_view_model.dart';
import '../core/utils/snackbar_utils.dart';
import '../core/utils/route_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
const Color kPrimary = Color(0xFF7C3AED);
const Color kPrimaryMid = Color(0xFF9D5FF3);
const Color kPrimaryBg = Color(0xFFF5F0FF);
const Color kPrimaryLight = Color(0xFFEDE8FF);
const Color kInk = Color(0xFF130B2E);
const Color kInk2 = Color(0xFF5B5271);
const Color kInk3 = Color(0xFFA399BE);
const Color kSurface = Color(0xFFF8F7FC);
const Color kCard = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFE9E3F8);
const Color kSuccess = Color(0xFF059669);
const Color kSuccessBg = Color(0xFFECFDF5);
const Color kWarn = Color(0xFFD97706);
const Color kWarnBg = Color(0xFFFFFBEB);
const Color kDanger = Color(0xFFDC2626);
const Color kDangerBg = Color(0xFFFEF2F2);

// ─────────────────────────────────────────────────────────────────────────────
// Document Requests List Screen
// ─────────────────────────────────────────────────────────────────────────────
class DocumentRequestsScreen extends StatefulWidget {
  const DocumentRequestsScreen({super.key});

  @override
  State<DocumentRequestsScreen> createState() => _DocumentRequestsScreenState();
}

class _DocumentRequestsScreenState extends State<DocumentRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentViewModel>().fetchDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DocumentViewModel>();

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Text(
          'Document Requests',
          style: TextStyle(
            color: kInk,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
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
      ),
      body: RefreshIndicator(
        color: kPrimary,
        onRefresh: vm.fetchDocuments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Search ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchField(onChanged: vm.setSearchQuery),
              ),

              const SizedBox(height: 16),

              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Documents',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    Text(
                      '${vm.filteredDocuments.length} items',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── States ──────────────────────────────────────────────────
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                )
              else if (vm.errorMessage != null)
                _ErrorState(
                  message: vm.errorMessage!,
                  onRetry: vm.fetchDocuments,
                )
              else if (vm.filteredDocuments.isEmpty)
                const _EmptyState()
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.filteredDocuments.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                        ),
                    itemBuilder: (context, index) =>
                        _DocumentCard(doc: vm.filteredDocuments[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Field
// ─────────────────────────────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: kInk),
        decoration: InputDecoration(
          hintText: 'Search documents...',
          hintStyle: TextStyle(color: kInk3, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: kPrimary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document Card
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final DocumentRequest doc;
  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        instantRoute(DocumentRequestFormScreen(document: doc)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF8B2CF5).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    doc.isPublished ? 'Published' : 'Unpublished',
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
                      ? 'FREE'
                      : '₱${doc.amount.toStringAsFixed(2)}',
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

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error States
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: kPrimaryBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: kPrimary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No documents found',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: kInk,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Documents will appear here once available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kInk2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: kDangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: kDanger,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kDanger, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: kPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Screen
// ─────────────────────────────────────────────────────────────────────────────
class DocumentRequestFormScreen extends StatefulWidget {
  final DocumentRequest document;
  const DocumentRequestFormScreen({super.key, required this.document});

  @override
  State<DocumentRequestFormScreen> createState() =>
      _DocumentRequestFormScreenState();
}

// ── TickerProviderStateMixin removed — no more AnimationController needed ────
class _DocumentRequestFormScreenState extends State<DocumentRequestFormScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // ── Personal step form key & controllers ───────────────────────────────────
  final _personalFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();

  // ── Dynamic step form key & controllers ───────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  // ── PageController — replaces the old SlideTransition / FadeTransition ────
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.document.formFields)
        (field['label'] as String? ?? ''): TextEditingController(),
    };
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _next() {
    if (_currentStep == 0 && !_personalFormKey.currentState!.validate()) return;
    if (_currentStep == 1 &&
        _controllers.isNotEmpty &&
        !_formKey.currentState!.validate()) {
      return;
    }
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final vm = context.read<DocumentViewModel>();
      await vm.submitRequest(
        document: widget.document,
        fullName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        contactNo: _contactController.text.trim(),
        email: _emailController.text.trim(),
        dob: _birthdateController.text,
        dynamicValues: {
          for (var e in _controllers.entries) e.key: e.value.text.trim(),
        },
      );
      if (mounted) _showSuccess();
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Submission failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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

  // ── Build ──────────────────────────────────────────────────────────────────
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
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _currentStep),
          _DocumentHeaderCard(document: widget.document),

          // ── PageView replaces the old FadeTransition + SlideTransition ───
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _Step1Personal(
                  key: const ValueKey('s1'),
                  formKey: _personalFormKey,
                  nameController: _nameController,
                  addressController: _addressController,
                  contactController: _contactController,
                  emailController: _emailController,
                  birthdateController: _birthdateController,
                ),
                _Step2Requirements(
                  key: const ValueKey('s2'),
                  formKey: _formKey,
                  fields: widget.document.formFields,
                  controllers: _controllers,
                ),
                _Step3Confirm(
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
                ),
              ],
            ),
          ),

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
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Personal', 'Details', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Segmented bars
          Row(
            children: List.generate(_labels.length, (i) {
              final isDone = i < currentStep;
              final isActive = i == currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDone
                              ? kSuccess
                              : isActive
                              ? kPrimary
                              : kBorder,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    if (i < _labels.length - 1) const SizedBox(width: 6),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // ── Step label
          Text(
            'Step ${currentStep + 1} of ${_labels.length}  ·  ${_labels[currentStep]}',
            style: const TextStyle(
              fontSize: 11,
              color: kInk2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document Header Card
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentHeaderCard extends StatelessWidget {
  final DocumentRequest document;
  const _DocumentHeaderCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimaryBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              IconData(document.iconCode, fontFamily: 'MaterialIcons'),
              color: kPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Processing fee',
                      style: TextStyle(fontSize: 11, color: kInk2),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryBg,
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

// ─────────────────────────────────────────────────────────────────────────────
// Steps
// ─────────────────────────────────────────────────────────────────────────────
class _Step1Personal extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController,
      addressController,
      contactController,
      emailController,
      birthdateController;

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: _FormCard(
        eyebrow: 'Personal Information',
        eyebrowIcon: Icons.person_outline_rounded,
        title: 'Who are you?',
        subtitle: 'Fill in your basic personal information to proceed.',
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _FieldInput(
                label: 'Full Name',
                controller: nameController,
                icon: Icons.person_outline_rounded,
                hint: 'Juan dela Cruz',
              ),
              _FieldInput(
                label: 'Home Address',
                controller: addressController,
                icon: Icons.location_on_outlined,
                hint: 'Purok, Barangay, City',
                maxLines: 2,
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateFieldInput(
                      label: 'Date of Birth',
                      controller: birthdateController,
                    ),
                  ),
                ],
              ),
              _FieldInput(
                label: 'Email Address',
                controller: emailController,
                icon: Icons.mail_outline_rounded,
                hint: 'Optional',
                required: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: _FormCard(
        eyebrow: 'Document Details',
        eyebrowIcon: Icons.edit_note_rounded,
        title: 'A few more details',
        subtitle: 'Fields specific to this document type.',
        child: fields.isEmpty
            ? _EmptyFields()
            : Form(
                key: formKey,
                child: Column(
                  children: [
                    const _InfoBanner(
                      message:
                          'These fields will be pre-filled by the barangay staff.',
                    ),
                    ...fields.map((field) {
                      final label = field['label'] as String? ?? '';
                      if (label.isEmpty) return const SizedBox.shrink();
                      final ctrl = controllers[label]!;
                      if (label.toLowerCase().contains('date')) {
                        return _DateFieldInput(label: label, controller: ctrl);
                      }
                      return _FieldInput(
                        label: label,
                        controller: ctrl,
                        icon: Icons.short_text_rounded,
                        hint: 'Enter $label',
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: _FormCard(
        eyebrow: 'Review & Confirm',
        eyebrowIcon: Icons.fact_check_outlined,
        title: 'Almost there!',
        subtitle: 'Review all details before submitting.',
        child: Column(
          children: [
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
            const SizedBox(height: 10),
            _ReviewSection(
              title: 'Personal Details',
              rows: [
                _ReviewRow(label: 'Full Name', value: name),
                _ReviewRow(label: 'Address', value: address),
                _ReviewRow(label: 'Contact', value: contact),
                if (email.isNotEmpty) _ReviewRow(label: 'Email', value: email),
                _ReviewRow(label: 'Birthdate', value: birthdate),
              ],
            ),
            if (dynamicValues.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ReviewSection(
                title: 'Requirements',
                rows: dynamicValues.entries
                    .map((e) => _ReviewRow(label: e.key, value: e.value))
                    .toList(),
              ),
            ],
            const SizedBox(height: 14),
            const _InfoBanner(
              message: 'Changes cannot be made after submission.',
              isWarning: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentStep;
  final bool isSubmitting;
  final VoidCallback onBack, onNext;

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
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: kCard,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            OutlinedButton(
              onPressed: isSubmitting ? null : onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                foregroundColor: kInk2,
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 13),
                  SizedBox(width: 4),
                  Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? kSuccess : kPrimary,
                disabledBackgroundColor: (isLast ? kSuccess : kPrimary)
                    .withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLast
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLast ? 'Submit Request' : 'Continue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Card
// ─────────────────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final String eyebrow, title, subtitle;
  final IconData eyebrowIcon;
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
            color: kPrimary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: kPrimaryBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(eyebrowIcon, color: kPrimary, size: 13),
              ),
              const SizedBox(width: 7),
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kInk,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: kInk2, height: 1.4),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field Input
// ─────────────────────────────────────────────────────────────────────────────
class _FieldInput extends StatefulWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
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
  State<_FieldInput> createState() => _FieldInputState();
}

class _FieldInputState extends State<_FieldInput> {
  final _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _isFocused ? kPrimary : kInk2,
                ),
              ),
              if (widget.required)
                const Text(
                  ' *',
                  style: TextStyle(color: kDanger, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboard,
            maxLines: widget.maxLines,
            style: const TextStyle(
              fontSize: 14,
              color: kInk,
              fontWeight: FontWeight.w500,
            ),
            validator: widget.required
                ? (v) => (v == null || v.trim().isEmpty)
                      ? '${widget.label} is required'
                      : null
                : null,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: kInk3, fontSize: 13),
              prefixIcon: Icon(
                widget.icon,
                size: 17,
                color: _isFocused ? kPrimary : kInk3,
              ),
              filled: true,
              fillColor: _isFocused ? kPrimaryBg : kSurface,
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

// ─────────────────────────────────────────────────────────────────────────────
// Date Field Input
// ─────────────────────────────────────────────────────────────────────────────
class _DateFieldInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _DateFieldInput({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kInk2,
                ),
              ),
              const Text(' *', style: TextStyle(color: kDanger, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(
              fontSize: 14,
              color: kInk,
              fontWeight: FontWeight.w500,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please select a date' : null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: kPrimary,
                      onPrimary: Colors.white,
                    ),
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
              hintStyle: TextStyle(color: kInk3, fontSize: 13),
              prefixIcon: const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: kInk3,
              ),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: kInk3,
                size: 20,
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
              errorStyle: const TextStyle(fontSize: 11, color: kDanger),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Banner
// ─────────────────────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final String message;
  final bool isWarning;
  const _InfoBanner({required this.message, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? kWarn : kPrimary;
    final bg = isWarning ? kWarnBg : kPrimaryBg;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Fields
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kPrimaryBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: kPrimary, size: 28),
          SizedBox(height: 10),
          Text(
            'No additional fields required.',
            style: TextStyle(
              color: kInk2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Section / Row
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewSection extends StatelessWidget {
  final String title;
  final List<_ReviewRow> rows;
  const _ReviewSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kInk3,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: kBorder),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
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
                fontWeight: FontWeight.w700,
                color: valueColor ?? kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success Screen
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessScreen extends StatelessWidget {
  final String documentTitle, trackingId;
  const _SuccessScreen({required this.documentTitle, required this.trackingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: kSuccessBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: kSuccess,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Request Submitted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your $documentTitle request has been received and is now being processed.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kInk2,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Tracking ID',
                        style: TextStyle(
                          fontSize: 11,
                          color: kInk2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trackingId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Keep this ID to track your request status.',
                  style: TextStyle(fontSize: 11, color: kInk3),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
