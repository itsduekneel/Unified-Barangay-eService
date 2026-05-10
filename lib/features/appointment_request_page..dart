import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SQL — run once before using this module:
//
//   create table appointments (
//     id uuid primary key default gen_random_uuid(),
//     user_id uuid references auth.users(id), -- Added for resident tracking
//     created_at timestamptz default now(),
//     service_name text not null,
//     service_duration text,
//     appointment_date date not null,
//     appointment_time text not null,
//     full_name text not null,
//     contact_no text not null,
//     purpose text,
//     status text default 'pending',
//     reference_no text,
//     notes text                      -- admin notes
//   );
// ─────────────────────────────────────────────────────────────────────────────

final _supabase = Supabase.instance.client;

// ─── Design Tokens ────────────────────────────────────────────────────────────

class _C {
  static const primary = Color(0xFF8B2CF5);
  static const primaryMid = Color(0xFFB06AF5);
  static const primaryLight = Color(0xFFEDE8FF);
  static const primarySuperLight = Color(0xFFF5F0FF);
  static const ink = Color(0xFF1A1033);
  static const ink2 = Color(0xFF6B6480);
  static const ink3 = Color(0xFFADA9C2);
  static const surface = Color(0xFFF5F4FA);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8E3F2);
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);
  static const danger = Color(0xFFDC2626);
  static const warn = Color(0xFFF59E0B);
  static const warnLight = Color(0xFFFEF3C7);
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _Service {
  final String name;
  final String duration;
  final IconData icon;
  const _Service(this.name, this.duration, this.icon);
}

const _kServices = [
  _Service('Barangay Clearance', '15 mins', Icons.article_outlined),
  _Service('Certificate of Indigency', '15 mins', Icons.star_border_rounded),
  _Service('Business Permit', '30 mins', Icons.storefront_outlined),
  _Service('Health Consultation', '20 mins', Icons.add_circle_outline_rounded),
  _Service('Certificate of Residency', '15 mins', Icons.home_outlined),
  _Service('Good Moral Certificate', '20 mins', Icons.verified_outlined),
];

// ─── Date Formatter ───────────────────────────────────────────────────────────

class _Fmt {
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
  static const _short = [
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
  static String full(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';
  static String short(DateTime d) => '${_short[d.month - 1]} ${d.day}';
  static String iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─── Entry Point ─────────────────────────────────────────────────────────────

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  int _step = 0;
  bool _showMyAppointments = false;

  _Service? _service;
  DateTime? _date;
  TimeOfDay? _time;

  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _referenceNo;

  @override
  void initState() {
    super.initState();
    _prefillUserInfo();
  }

  void _prefillUserInfo() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final profile = await _supabase
            .from('profiles')
            .select('first_name, last_name')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null && mounted) {
          setState(() {
            _nameCtrl.text = '${profile['first_name']} ${profile['last_name']}';
          });
        }
      } catch (e) {
        debugPrint('Prefill error: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _goNext() => setState(() => _step++);
  void _goBack() => setState(() => _step--);

  void _reset() => setState(() {
    _step = 0;
    _service = null;
    _date = null;
    _time = null;
    _referenceNo = null;
    _nameCtrl.clear();
    _contactCtrl.clear();
    _purposeCtrl.clear();
    _prefillUserInfo();
  });

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final user = _supabase.auth.currentUser;
    final refNo = 'APT-${Random().nextInt(90000) + 10000}';
    try {
      await _supabase.from('appointments').insert({
        'user_id': user?.id,
        'service_name': _service!.name,
        'service_duration': _service!.duration,
        'appointment_date': _Fmt.iso(_date!),
        'appointment_time': _time!.format(context),
        'full_name': _nameCtrl.text.trim(),
        'contact_no': _contactCtrl.text.trim(),
        'purpose': _purposeCtrl.text.trim().isEmpty
            ? null
            : _purposeCtrl.text.trim(),
        'status': 'pending',
        'reference_no': refNo,
      });

      if (mounted) {
        setState(() {
          _referenceNo = refNo;
          _isSubmitting = false;
          _step = 4;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: _C.danger,
          ),
        );
      }
    }
  }

  static const _titles = [
    'Appointment',
    'Date & Time',
    'Your Details',
    'Review',
    'Confirmed!',
  ];

  @override
  Widget build(BuildContext context) {
    if (_showMyAppointments) {
      return _MyAppointmentsView(
        onBack: () => setState(() => _showMyAppointments = false),
      );
    }

    return Scaffold(
      backgroundColor: _C.surface,
      appBar: AppBar(
        backgroundColor: _C.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          _titles[_step.clamp(0, 4)],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        leading: _step > 0 && _step < 4
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _C.primary,
                  size: 20,
                ),
                onPressed: _goBack,
              )
            : _step == 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _C.primary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          if (_step < 4) _StepBar(step: _step),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepService(
          selected: _service,
          onSelect: (s) => setState(() => _service = s),
          onNext: _service != null ? _goNext : null,
        );
      case 1:
        return _StepDateTime(
          date: _date,
          time: _time,
          onDate: (d) => setState(() => _date = d),
          onTime: (t) => setState(() => _time = t),
          onNext: _date != null && _time != null ? _goNext : null,
        );
      case 2:
        return _StepDetails(
          nameCtrl: _nameCtrl,
          contactCtrl: _contactCtrl,
          purposeCtrl: _purposeCtrl,
          onNext: _goNext,
        );
      case 3:
        return _StepReview(
          service: _service!,
          date: _date!,
          time: _time!.format(context),
          name: _nameCtrl.text,
          contact: _contactCtrl.text,
          purpose: _purposeCtrl.text,
          isSubmitting: _isSubmitting,
          onConfirm: _submit,
        );
      case 4:
        return _StepDone(
          service: _service!,
          date: _date!,
          time: _time!.format(context),
          name: _nameCtrl.text,
          referenceNo: _referenceNo ?? '—',
          onBookAgain: _reset,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step Bar ─────────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: List.generate(4, (i) {
          final done = i < step;
          final active = i == step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active
                          ? _C.primary
                          : _C.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step 1: Select Service ───────────────────────────────────────────────────

class _StepService extends StatelessWidget {
  final _Service? selected;
  final ValueChanged<_Service> onSelect;
  final VoidCallback? onNext;

  const _StepService({
    required this.selected,
    required this.onSelect,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Book an Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Select a barangay service to get started.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
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
          _SectionLabel(label: 'Available Services'),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (_, i) {
              final s = _kServices[i];
              final isSelected = selected == s;
              return GestureDetector(
                onTap: () => onSelect(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF5F0FF) : _C.card,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? _C.primary : _C.border,
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _C.primary.withOpacity(0.12)
                                  : _C.border.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              s.icon,
                              size: 18,
                              color: isSelected ? _C.primary : _C.ink2,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                color: _C.primary,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? _C.primary : _C.ink,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: _C.ink3,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            s.duration,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _C.ink3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          _NextButton(label: 'Choose date & time', onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Step 2: Date & Time ──────────────────────────────────────────────────────

class _StepDateTime extends StatelessWidget {
  final DateTime? date;
  final TimeOfDay? time;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<TimeOfDay> onTime;
  final VoidCallback? onNext;

  const _StepDateTime({
    required this.date,
    required this.time,
    required this.onDate,
    required this.onTime,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Pick a Date'),
          const SizedBox(height: 12),

          // Calendar
          Container(
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _InlineCalendar(selected: date, onSelect: onDate),
            ),
          ),

          if (date != null) ...[
            const SizedBox(height: 10),
            _PillBadge(icon: Icons.event_rounded, text: _Fmt.full(date!)),
          ],

          const SizedBox(height: 20),
          _SectionLabel(label: 'Select a Time'),
          const SizedBox(height: 12),

          // Time picker trigger
          _TapField(
            icon: Icons.access_time_rounded,
            label: 'Preferred time',
            value: time?.format(context) ?? 'Tap to select a time',
            hasValue: time != null,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time ?? TimeOfDay.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: _C.primary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onTime(picked);
            },
          ),

          _NextButton(label: 'Continue to details', onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Inline Calendar ──────────────────────────────────────────────────────────

class _InlineCalendar extends StatefulWidget {
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  const _InlineCalendar({required this.selected, required this.onSelect});

  @override
  State<_InlineCalendar> createState() => _InlineCalendarState();
}

class _InlineCalendarState extends State<_InlineCalendar> {
  late DateTime _viewing;

  @override
  void initState() {
    super.initState();
    _viewing = DateTime.now();
  }

  void _prev() =>
      setState(() => _viewing = DateTime(_viewing.year, _viewing.month - 1));
  void _next() =>
      setState(() => _viewing = DateTime(_viewing.year, _viewing.month + 1));

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(_viewing.year, _viewing.month, 1);
    final lastDay = DateTime(_viewing.year, _viewing.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // Sun=0

    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prev,
                icon: const Icon(Icons.chevron_left_rounded, color: _C.primary),
              ),
              Text(
                '${_Fmt._months[_viewing.month - 1]} ${_viewing.year}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _C.ink,
                ),
              ),
              IconButton(
                onPressed: _next,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: _C.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Day headers
          Row(
            children: days
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.ink3,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),

          // Date grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 0,
            ),
            itemCount: startOffset + lastDay.day,
            itemBuilder: (_, i) {
              if (i < startOffset) return const SizedBox.shrink();
              final day = i - startOffset + 1;
              final date = DateTime(_viewing.year, _viewing.month, day);
              final isPast = date.isBefore(
                DateTime(now.year, now.month, now.day),
              );
              final isSelected =
                  widget.selected != null &&
                  widget.selected!.year == date.year &&
                  widget.selected!.month == date.month &&
                  widget.selected!.day == date.day;
              final isToday =
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              return GestureDetector(
                onTap: isPast ? null : () => widget.onSelect(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _C.primary
                        : isToday
                        ? _C.primaryLight
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : isPast
                            ? _C.ink3
                            : isToday
                            ? _C.primary
                            : _C.ink,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Personal Details ─────────────────────────────────────────────────

class _StepDetails extends StatelessWidget {
  final TextEditingController nameCtrl, contactCtrl, purposeCtrl;
  final VoidCallback onNext;

  final _formKey = GlobalKey<FormState>();

  _StepDetails({
    required this.nameCtrl,
    required this.contactCtrl,
    required this.purposeCtrl,
    required this.onNext,
  });

  void _submit() {
    if (_formKey.currentState!.validate()) onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Personal Information'),
            const SizedBox(height: 12),

            _FormField(
              label: 'Full Name',
              controller: nameCtrl,
              icon: Icons.person_outline_rounded,
              hint: 'Juan dela Cruz',
              required: true,
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Contact Number',
              controller: contactCtrl,
              icon: Icons.phone_outlined,
              hint: '09XX XXX XXXX',
              keyboard: TextInputType.phone,
              required: true,
            ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Purpose / Notes',
              controller: purposeCtrl,
              icon: Icons.notes_rounded,
              hint: 'e.g. For employment requirements',
              maxLines: 3,
              required: false,
            ),

            _NextButton(label: 'Review & Confirm', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

// ─── Step 4: Review ───────────────────────────────────────────────────────────

class _StepReview extends StatelessWidget {
  final _Service service;
  final DateTime date;
  final String time, name, contact, purpose;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  const _StepReview({
    required this.service,
    required this.date,
    required this.time,
    required this.name,
    required this.contact,
    required this.purpose,
    required this.isSubmitting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service highlight
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(18),
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
                        '${_Fmt.short(date)}  ·  $time  ·  ${service.duration}',
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
          _SectionLabel(label: 'Appointment Summary'),
          const SizedBox(height: 12),

          _ReviewCard(
            rows: [
              _ReviewRow(Icons.event_rounded, 'Date', _Fmt.full(date)),
              _ReviewRow(Icons.access_time_rounded, 'Time', time),
              _ReviewRow(Icons.timer_outlined, 'Duration', service.duration),
              _ReviewRow(Icons.person_outline_rounded, 'Name', name),
              _ReviewRow(Icons.phone_outlined, 'Contact', contact),
              if (purpose.trim().isNotEmpty)
                _ReviewRow(Icons.notes_rounded, 'Purpose', purpose),
            ],
          ),

          const SizedBox(height: 14),

          // Consent note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _C.warnLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.warn.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: _C.warn),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Please arrive 10 minutes before your scheduled time. Bring a valid government-issued ID.',
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

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                disabledBackgroundColor: _C.primary.withOpacity(0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Confirm Appointment',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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

// ─── Step 5: Done ─────────────────────────────────────────────────────────────

class _StepDone extends StatelessWidget {
  final _Service service;
  final DateTime date;
  final String time, name, referenceNo;
  final VoidCallback onBookAgain;

  const _StepDone({
    required this.service,
    required this.date,
    required this.time,
    required this.name,
    required this.referenceNo,
    required this.onBookAgain,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          // Success banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Appointment Confirmed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'You will receive a reminder via SMS',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
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
                  child: Text(
                    referenceNo,
                    style: const TextStyle(
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

          _ReviewCard(
            rows: [
              _ReviewRow(
                Icons.medical_services_outlined,
                'Service',
                service.name,
              ),
              _ReviewRow(
                Icons.event_rounded,
                'Date & Time',
                '${_Fmt.short(date)} • $time',
              ),
              _ReviewRow(Icons.person_outline_rounded, 'Name', name),
              _ReviewRow(
                Icons.info_outline_rounded,
                'Status',
                'Scheduled',
                isStatus: true,
              ),
            ],
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
                color: _C.primary,
              ),
              label: const Text(
                'Book Another Appointment',
                style: TextStyle(
                  color: _C.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _C.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── My Appointments View ──────────────────────────────────────────────────────

class _MyAppointmentsView extends StatelessWidget {
  final VoidCallback onBack;
  const _MyAppointmentsView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: _C.surface,
      appBar: AppBar(
        backgroundColor: _C.surface,
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: _C.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _C.primary,
            size: 20,
          ),
          onPressed: onBack,
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('appointments')
            .stream(primaryKey: ['id'])
            .eq('user_id', user?.id ?? '')
            .order('appointment_date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _C.primary),
            );
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 48, color: _C.ink3),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(color: _C.ink2, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final item = data[i];
              final status = item['status']?.toString() ?? 'pending';
              final dateStr = item['appointment_date']?.toString() ?? '';
              final date = DateTime.tryParse(dateStr) ?? DateTime.now();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _kStatusColor(status).withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _C.primarySuperLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 18,
                            color: _C.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['service_name'] ?? 'Service',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _C.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['reference_no'] ?? '—',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _C.ink3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const Divider(height: 24, color: _C.border),
                    Row(
                      children: [
                        _SmallInfo(
                          icon: Icons.event_rounded,
                          text: _Fmt.short(date),
                        ),
                        const SizedBox(width: 16),
                        _SmallInfo(
                          icon: Icons.access_time_rounded,
                          text: item['appointment_time'] ?? '—',
                        ),
                      ],
                    ),
                    if (item['notes'] != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _C.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Note: ${item['notes']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _C.ink2,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _kStatusColor(String s) {
    switch (s) {
      case 'confirmed':
        return _C.success;
      case 'cancelled':
        return _C.danger;
      case 'completed':
        return Colors.blue;
      default:
        return _C.warn;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    switch (status) {
      case 'confirmed':
        color = _C.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'cancelled':
        color = _C.danger;
        icon = Icons.cancel_outlined;
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.task_alt_rounded;
        break;
      default:
        color = _C.warn;
        icon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SmallInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _C.ink3),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: _C.ink2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _C.ink,
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _NextButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null
                ? _C.primary
                : _C.primary.withOpacity(0.35),
            foregroundColor: Colors.white,
            elevation: onPressed != null ? 2 : 0,
            shadowColor: _C.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PillBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _C.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _C.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool hasValue;
  final VoidCallback onTap;

  const _TapField({
    required this.icon,
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? _C.primary : _C.border,
            width: hasValue ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasValue ? _C.primaryLight : _C.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: hasValue ? _C.primary : _C.ink2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: _C.ink3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasValue ? _C.ink : _C.ink3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _C.ink3, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboard;
  final bool required;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboard,
    this.required = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.ink,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: _C.danger, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 14, color: _C.ink),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? '$label is required'
                    : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _C.ink3, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: _C.ink3),
            filled: true,
            fillColor: _C.card,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.danger, width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11, color: _C.danger),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final List<_ReviewRow> rows;
  const _ReviewCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: _C.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isStatus;

  const _ReviewRow(this.icon, this.label, this.value, {this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _C.ink3),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: _C.ink2)),
          const Spacer(),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _C.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Scheduled',
                    style: TextStyle(
                      fontSize: 11,
                      color: _C.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Flexible(
                  child: Text(
                    value.isEmpty ? '—' : value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
