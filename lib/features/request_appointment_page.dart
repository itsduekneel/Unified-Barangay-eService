import 'package:flutter/material.dart';
import 'package:ube/widgets/calendar.dart';

// ─── Constants & Styling ──────────────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF8B2CF5);
  static const primaryLight = Color(0xFFEEECFD);
  static const text = Colors.black;
  static const subtext = Color(0xFF9490B0);
  static const border = Color(0xFFE4E2F7);
  static const background = Color(0xFFF9F9FC);
  static const errorBg = Color(0xFFFFEBEE);
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class DateFormatter {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String formatFull(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';
  static String formatShort(DateTime d) =>
      '${_shortMonths[d.month - 1]} ${d.day}';
}

// ─── Models ───────────────────────────────────────────────────────────────────
class Service {
  final String name;
  final String duration;
  final IconData icon;
  const Service(this.name, this.duration, this.icon);
}

const kServices = [
  Service('Barangay Clearance', '15 mins', Icons.article_outlined),
  Service('Certificate of Indigency', '15 mins', Icons.star_border_rounded),
  Service('Business Permit', '30 mins', Icons.storefront_outlined),
  Service('Health Consultation', '20 mins', Icons.add_circle_outline),
];

const kTimeSlots = [
  '08:00 AM',
  '08:30 AM',
  '09:00 AM',
  '09:30 AM',
  '10:00 AM',
  '10:30 AM',
  '01:00 PM',
  '01:30 PM',
  '02:00 PM',
];

// ─── Appointment Page ─────────────────────────────────────────────────────────
class AddAppointment extends StatefulWidget {
  const AddAppointment({super.key});

  @override
  State<AddAppointment> createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  int _step = 0;

  Service? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  String _language = 'Filipino';

  void _next() => setState(() => _step++);
  void _back() => setState(() => _step--);
  void _reset() => setState(() {
    _step = 0;
    _selectedService = null;
    _selectedDate = null;
    _selectedTime = null;
    _nameCtrl.clear();
    _contactCtrl.clear();
    _purposeCtrl.clear();
  });

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (_step) {
      case 0:
        return 'Appointment';
      case 1:
        return 'Choose date & time';
      case 2:
        return 'Your details';
      case 3:
        return 'Review & confirm';
      case 4:
        return 'Done';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: _step < 4,
        leading: _step < 4
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _step > 0 ? _back : () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          if (_step < 4)
            _StepIndicator(totalSteps: 4, currentStep: _step.clamp(0, 3)),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _Step1SelectService(
          selectedService: _selectedService,
          onSelect: (s) => setState(() => _selectedService = s),
          onNext: _selectedService != null ? _next : null,
        );
      case 1:
        return _Step2DateTime(
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          onDateSelect: (d) => setState(() => _selectedDate = d),
          onTimeSelect: (t) => setState(() => _selectedTime = t),
          onNext: (_selectedDate != null && _selectedTime != null)
              ? _next
              : null,
        );
      case 2:
        return _Step3Details(
          nameCtrl: _nameCtrl,
          contactCtrl: _contactCtrl,
          purposeCtrl: _purposeCtrl,
          language: _language,
          onLanguageChange: (l) => setState(() => _language = l),
          selectedDate: _selectedDate!,
          selectedTime: _selectedTime!.format(context),
          onNext: _next,
        );
      case 3:
        return _Step4Review(
          service: _selectedService!,
          date: _selectedDate!,
          time: _selectedTime!.format(context),
          name: _nameCtrl.text,
          contact: _contactCtrl.text,
          language: _language,
          onConfirm: _next,
        );
      case 4:
        return _StepDone(
          service: _selectedService!,
          date: _selectedDate!,
          time: _selectedTime!.format(context),
          name: _nameCtrl.text,
          onBookAgain: _reset,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  const _StepIndicator({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i <= currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Reusable Next Button ─────────────────────────────────────────────────────
Widget _buildNextButton(String label, VoidCallback? onPressed) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
    child: SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null
              ? AppColors.primary
              : const Color(0xFFCCC9F5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: onPressed != null ? 2 : 0,
          shadowColor: AppColors.primary.withOpacity(0.35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 16),
          ],
        ),
      ),
    ),
  );
}

// ─── Section Header Helper ────────────────────────────────────────────────────
Widget _sectionHeader(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: 0.1,
          ),
        ),
      ],
    ),
  );
}

// ─── Step 1: Select Service ───────────────────────────────────────────────────
class _Step1SelectService extends StatelessWidget {
  final Service? selectedService;
  final ValueChanged<Service> onSelect;
  final VoidCallback? onNext;

  const _Step1SelectService({
    required this.selectedService,
    required this.onSelect,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B2CF5), Color(0xFF6B12D5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Book an appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose a barangay service below to get started.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _sectionHeader('Available services'),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: kServices.map((s) {
              final selected = selectedService == s;
              return GestureDetector(
                onTap: () => onSelect(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (!selected)
                        const BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.border.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              s.icon,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.subtext,
                              size: 18,
                            ),
                          ),
                          if (selected)
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.primary : AppColors.text,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: AppColors.subtext.withOpacity(0.8),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            s.duration,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.subtext,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          _buildNextButton('Choose date & time', onNext),
        ],
      ),
    );
  }
}

// ─── Step 2: Date & Time ──────────────────────────────────────────────────────
class _Step2DateTime extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateSelect;
  final ValueChanged<TimeOfDay> onTimeSelect;
  final VoidCallback? onNext;

  const _Step2DateTime({
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelect,
    required this.onTimeSelect,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = selectedTime?.format(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Pick a date'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CalendarContainer(onDateChanged: onDateSelect),
            ),
          ),

          if (selectedDate != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.formatFull(selectedDate!),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          _sectionHeader('Select a time'),

          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );
              if (picked != null) onTimeSelect(picked);
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selectedTime != null
                      ? AppColors.primary
                      : AppColors.border,
                  width: selectedTime != null ? 1.5 : 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedTime != null
                          ? AppColors.primaryLight
                          : AppColors.border.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: selectedTime != null
                          ? AppColors.primary
                          : AppColors.subtext,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preferred time',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.subtext,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeText ?? 'Tap to select a time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: timeText != null
                                ? AppColors.text
                                : AppColors.subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.subtext.withOpacity(0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          _buildNextButton('Continue to details', onNext),
        ],
      ),
    );
  }
}

// ─── Step 3: Details ──────────────────────────────────────────────────────────
class _Step3Details extends StatelessWidget {
  final TextEditingController nameCtrl, contactCtrl, purposeCtrl;
  final String language;
  final ValueChanged<String> onLanguageChange;
  final DateTime selectedDate;
  final String selectedTime;
  final VoidCallback onNext;

  final _formKey = GlobalKey<FormState>();

  _Step3Details({
    required this.nameCtrl,
    required this.contactCtrl,
    required this.purposeCtrl,
    required this.language,
    required this.onLanguageChange,
    required this.selectedDate,
    required this.selectedTime,
    required this.onNext,
  });

  void _submit() {
    if (_formKey.currentState!.validate()) {
      onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment context chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormatter.formatFull(selectedDate)}  •  $selectedTime',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionHeader('Personal information'),

            _buildFormField(
              label: 'Full name',
              controller: nameCtrl,
              hint: 'Juan dela Cruz',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 14),
            _buildFormField(
              label: 'Contact number',
              controller: contactCtrl,
              hint: '09XX XXX XXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _buildFormField(
              label: 'Purpose / notes',
              controller: purposeCtrl,
              hint: 'e.g. For employment requirements',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _buildNextButton('Review & confirm', _submit),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.subtext,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.text),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'This field is required'
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.subtext, fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, size: 18, color: AppColors.subtext),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 4: Review & Confirm ─────────────────────────────────────────────────
class _Step4Review extends StatelessWidget {
  final Service service;
  final DateTime date;
  final String time, name, contact, language;
  final VoidCallback onConfirm;

  const _Step4Review({
    required this.service,
    required this.date,
    required this.time,
    required this.name,
    required this.contact,
    required this.language,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service highlight card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B2CF5), Color(0xFF6B12D5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(service.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${DateFormatter.formatShort(date)}  ·  $time  ·  ${service.duration}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _sectionHeader('Appointment summary'),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _summaryRow(
                  Icons.event_rounded,
                  'Date',
                  DateFormatter.formatFull(date),
                ),
                _divider(),
                _summaryRow(Icons.access_time_rounded, 'Time', time),
                _divider(),
                _summaryRow(Icons.timer_outlined, 'Duration', service.duration),
                _divider(),
                _summaryRow(Icons.person_outline_rounded, 'Name', name),
                _divider(),
                _summaryRow(
                  Icons.phone_outlined,
                  'Contact',
                  contact.isEmpty ? '—' : contact,
                ),
                _divider(),
                _summaryRow(
                  Icons.language_rounded,
                  'Language',
                  language,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Consent note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By confirming, you agree to receive appointment reminders via SMS.',
                    style: TextStyle(fontSize: 11, color: AppColors.subtext),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Confirm appointment',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    indent: 16,
    endIndent: 16,
    color: AppColors.border,
  );

  Widget _summaryRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.subtext),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.subtext),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 5: Done ─────────────────────────────────────────────────────────────
class _StepDone extends StatelessWidget {
  final Service service;
  final DateTime date;
  final String time, name;
  final VoidCallback onBookAgain;

  const _StepDone({
    required this.service,
    required this.date,
    required this.time,
    required this.name,
    required this.onBookAgain,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Success animation area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B2CF5), Color(0xFF6B12D5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Appointment confirmed!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'You will receive a reminder via SMS',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Text(
                    'REF-847291',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Details card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _doneRow(
                  Icons.medical_services_outlined,
                  'Service',
                  service.name,
                ),
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.border,
                ),
                _doneRow(
                  Icons.event_rounded,
                  'Date & time',
                  '${DateFormatter.formatShort(date)} • $time',
                ),
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.border,
                ),
                _doneRow(Icons.person_outline_rounded, 'Name', name),
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.border,
                ),
                _doneRow(
                  Icons.info_outline_rounded,
                  'Status',
                  'Scheduled',
                  isStatus: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onBookAgain,
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: const Text(
                'Book another appointment',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _doneRow(
    IconData icon,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.subtext),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.subtext),
          ),
          const Spacer(),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Scheduled',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
        ],
      ),
    );
  }
}
