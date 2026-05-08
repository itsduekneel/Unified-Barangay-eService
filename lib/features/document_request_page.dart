import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/document_request.dart';
import '../view_models/document_view_model.dart';
import '../core/utils/snackbar_utils.dart';
import '../core/utils/route_utils.dart';

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
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text(
          'Document Requests',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F4FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8B2CF5), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: vm.fetchDocuments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: vm.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Color(0xFF8B2CF5), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8B2CF5), size: 20),
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      "${vm.filteredDocuments.length} items",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8B2CF5)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // STATES
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF8B2CF5))),
                )
              else if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(vm.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
                        const SizedBox(height: 12),
                        TextButton(onPressed: vm.fetchDocuments, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              else if (vm.filteredDocuments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: Text('No documents found.', style: TextStyle(color: Colors.grey))),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.filteredDocuments.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (context, index) => _DocumentCard(doc: vm.filteredDocuments[index]),
                  ),
                ),
            ],
          ),
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
      onTap: () => Navigator.push(
        context,
        instantRoute(DocumentRequestFormScreen(document: doc)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF8B2CF5).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF5F0FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(IconData(doc.iconCode, fontFamily: 'MaterialIcons'), color: const Color(0xFF8B2CF5)),
            ),
            const SizedBox(height: 12),
            Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(doc.isPublished ? "Published" : "Unpublished", maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: doc.isPublished ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                  ),
                ),
                const SizedBox(width: 4),
                Text("₱${doc.amount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
// Form Screen (View)
// ─────────────────────────────────────────────
class DocumentRequestFormScreen extends StatefulWidget {
  final DocumentRequest document;
  const DocumentRequestFormScreen({super.key, required this.document});

  @override
  State<DocumentRequestFormScreen> createState() => _DocumentRequestFormScreenState();
}

class _DocumentRequestFormScreenState extends State<DocumentRequestFormScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isSubmitting = false;

  final _personalFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

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
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _slideAnim = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
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
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0 && !_personalFormKey.currentState!.validate()) return;
    if (_currentStep == 1 && _controllers.isNotEmpty && !_formKey.currentState!.validate()) return;
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _slideController.reset();
      _slideController.forward();
    }
  }

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
        dynamicValues: { for (var e in _controllers.entries) e.key: e.value.text.trim() },
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
        pageBuilder: (_, _, _) => _SuccessScreen(documentTitle: widget.document.title, trackingId: trackingId),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface, elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.document.title, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _DocumentHeaderCard(document: widget.document),
          _StepIndicator(currentStep: _currentStep),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(position: _slideAnim, child: _buildCurrentStep()),
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
          dynamicValues: { for (var e in _controllers.entries) e.key: e.value.text },
        );
      default: return const SizedBox.shrink();
    }
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _DocumentHeaderCard extends StatelessWidget {
  final DocumentRequest document;
  const _DocumentHeaderCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(11)),
            child: Icon(IconData(document.iconCode, fontFamily: 'MaterialIcons'), color: kPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kInk)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('Processing fee', style: TextStyle(fontSize: 11, color: kInk2)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(99)),
                      child: Text(document.amount == 0 ? 'FREE' : '₱ ${document.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kPrimary),
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

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});
  static const _labels = ['Personal', 'Details', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Row(
        children: List.generate(3, (i) {
          final isDone = i < currentStep;
          final isActive = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: isDone || isActive ? kPrimary : kCard,
                          border: Border.all(color: isDone || isActive ? kPrimary : kBorder, width: 2),
                        ),
                        child: Center(
                          child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                              : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : kInk3)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(_labels[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isActive || isDone ? kPrimary : kInk3)),
                    ],
                  ),
                ),
                if (i < 2) Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 20), child: Container(height: 2, color: isDone ? kPrimary : kBorder))),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Step1Personal extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController, addressController, contactController, emailController, birthdateController;
  const _Step1Personal({super.key, required this.formKey, required this.nameController, required this.addressController, required this.contactController, required this.emailController, required this.birthdateController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      child: _FormCard(
        eyebrow: 'Step 1 of 3', eyebrowIcon: Icons.person_outline_rounded,
        title: 'Who are you?', subtitle: 'Please fill in your personal information.',
        child: Form(key: formKey, child: Column(children: [
          _FieldInput(label: 'Full Name', controller: nameController, icon: Icons.person_outline_rounded, hint: 'Juan dela Cruz'),
          _FieldInput(label: 'Home Address', controller: addressController, icon: Icons.location_on_outlined, hint: 'Address', maxLines: 2),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _FieldInput(label: 'Contact No.', controller: contactController, icon: Icons.phone_outlined, hint: '09XXXXXXXXX', keyboard: TextInputType.phone)),
            const SizedBox(width: 10),
            Expanded(child: _DateFieldInput(label: 'Date of Birth', controller: birthdateController)),
          ]),
          _FieldInput(label: 'Email Address', controller: emailController, icon: Icons.mail_outline_rounded, hint: 'Optional', required: false),
        ])),
      ),
    );
  }
}

class _Step2Requirements extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Map<String, dynamic>> fields;
  final Map<String, TextEditingController> controllers;
  const _Step2Requirements({super.key, required this.formKey, required this.fields, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      child: _FormCard(
        eyebrow: 'Step 2 of 3', eyebrowIcon: Icons.edit_note_rounded,
        title: 'A few more details', subtitle: 'Fields specific to this document.',
        child: fields.isEmpty ? _EmptyFields() : Form(key: formKey, child: Column(children: [
          const _InfoBanner(message: 'Answers will be pre-filled by staff.'),
          ...fields.map((field) {
            final label = field['label'] as String? ?? '';
            if (label.isEmpty) return const SizedBox.shrink();
            final ctrl = controllers[label]!;
            if (label.toLowerCase().contains('date')) return _DateFieldInput(label: label, controller: ctrl);
            return _FieldInput(label: label, controller: ctrl, icon: Icons.short_text_rounded, hint: 'Enter $label');
          }),
        ])),
      ),
    );
  }
}

class _Step3Confirm extends StatelessWidget {
  final DocumentRequest document;
  final String name, address, contact, email, birthdate;
  final Map<String, String> dynamicValues;
  const _Step3Confirm({super.key, required this.document, required this.name, required this.address, required this.contact, required this.email, required this.birthdate, required this.dynamicValues});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      child: _FormCard(
        eyebrow: 'Step 3 of 3', eyebrowIcon: Icons.fact_check_outlined,
        title: 'Confirm your request', subtitle: 'Review all details carefully.',
        child: Column(children: [
          _ReviewSection(title: 'Document', rows: [_ReviewRow(label: 'Type', value: document.title), _ReviewRow(label: 'Fee', value: document.amount == 0 ? 'FREE' : '₱ ${document.amount.toStringAsFixed(2)}', valueColor: kPrimary)]),
          const SizedBox(height: 12),
          _ReviewSection(title: 'Personal Details', rows: [_ReviewRow(label: 'Full Name', value: name), _ReviewRow(label: 'Address', value: address), _ReviewRow(label: 'Contact', value: contact), if (email.isNotEmpty) _ReviewRow(label: 'Email', value: email), _ReviewRow(label: 'Birthdate', value: birthdate)]),
          if (dynamicValues.isNotEmpty) ...[const SizedBox(height: 12), _ReviewSection(title: 'Requirements', rows: dynamicValues.entries.map((e) => _ReviewRow(label: e.key, value: e.value)).toList())],
          const SizedBox(height: 16),
          const _InfoBanner(message: 'Changes cannot be made after submission.', isWarning: true),
        ]),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final String documentTitle, trackingId;
  const _SuccessScreen({required this.documentTitle, required this.trackingId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, color: kSuccess, size: 80),
            const SizedBox(height: 24),
            const Text('Request Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
            const SizedBox(height: 8),
            Text('Your $documentTitle request has been received.', textAlign: TextAlign.center, style: const TextStyle(color: kInk2)),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(99), border: Border.all(color: kBorder)),
              child: Text('Tracking ID: $trackingId', style: const TextStyle(fontWeight: FontWeight.w700, color: kPrimary)),
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          ]),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentStep; final bool isSubmitting; final VoidCallback onBack, onNext;
  const _BottomBar({required this.currentStep, required this.isSubmitting, required this.onBack, required this.onNext});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: kCard, boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))]),
      child: Row(children: [
        if (currentStep > 0) ...[Expanded(child: OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(side: const BorderSide(color: kBorder, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('← Back'))), const SizedBox(width: 10)],
        Expanded(flex: 2, child: ElevatedButton(onPressed: isSubmitting ? null : onNext, style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)), child: isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(currentStep == 2 ? 'Submit Request ✓' : 'Continue →', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
      ]),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String eyebrow, title, subtitle; final IconData eyebrowIcon; final Widget child;
  const _FormCard({required this.eyebrow, required this.eyebrowIcon, required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(eyebrowIcon, color: kPrimary, size: 13), const SizedBox(width: 5), Text(eyebrow.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kPrimary))]),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: kInk)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: kInk2)),
        const SizedBox(height: 18),
        child,
      ]),
    );
  }
}

class _FieldInput extends StatelessWidget {
  final String label, hint; final TextEditingController controller; final IconData icon; final TextInputType keyboard; final bool required; final int maxLines;
  const _FieldInput({required this.label, required this.controller, required this.icon, required this.hint, this.keyboard = TextInputType.text, this.required = true, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kInk)), if (required) const Text(' *', style: TextStyle(color: kDanger))]),
        const SizedBox(height: 6),
        TextFormField(controller: controller, keyboardType: keyboard, maxLines: maxLines, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 17), filled: true, fillColor: kSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: kBorder)))),
      ]),
    );
  }
}

class _DateFieldInput extends StatelessWidget {
  final String label; final TextEditingController controller;
  const _DateFieldInput({required this.label, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kInk)),
        const SizedBox(height: 6),
        TextFormField(controller: controller, readOnly: true, onTap: () async {
          final p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
          if (p != null) controller.text = "${p.year}-${p.month.toString().padLeft(2,'0')}-${p.day.toString().padLeft(2,'0')}";
        }, decoration: InputDecoration(hintText: 'Select date', prefixIcon: const Icon(Icons.calendar_today, size: 16), filled: true, fillColor: kSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)))),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message; final bool isWarning;
  const _InfoBanner({required this.message, this.isWarning = false});
  @override
  Widget build(BuildContext context) {
    final c = isWarning ? kWarn : kPrimary;
    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isWarning ? kWarnLight : kPrimaryLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.2))), child: Row(children: [Icon(Icons.info_outline, color: c, size: 15), const SizedBox(width: 8), Expanded(child: Text(message, style: TextStyle(fontSize: 12, color: c)))]));
  }
}

class _EmptyFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12)), child: const Column(children: [Icon(Icons.check_circle_outline, color: kPrimary, size: 26), SizedBox(height: 10), Text('No additional fields required.', style: TextStyle(color: kInk2, fontSize: 13))]));
  }
}

class _ReviewSection extends StatelessWidget {
  final String title; final List<_ReviewRow> rows;
  const _ReviewSection({required this.title, required this.rows});
  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(13), border: Border.all(color: kBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kInk3)), const SizedBox(height: 10), const Divider(height: 1), const SizedBox(height: 8), ...rows]),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value; final Color? valueColor;
  const _ReviewRow({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: kInk2))), const SizedBox(width: 12), Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor ?? kInk)))]));
  }
}
