import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/app_colors.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedAudience;
  bool _scheduleEnabled = false;
  DateTime? _scheduledDateTime;
  bool _isPosting = false;

  final List<_AudienceOption> _audienceOptions = [
    const _AudienceOption(
      label: 'Specific Individuals',
      subtitle: 'Send to selected individuals',
      icon: Icons.people_alt_rounded,
      iconColor: AppColors.primary,
    ),
    const _AudienceOption(
      label: 'Barangay Workers',
      subtitle: 'All barangay staff and officials',
      icon: Icons.groups_rounded,
      iconColor: AppColors.blue,
    ),
    const _AudienceOption(
      label: 'Barangay Residents',
      subtitle: 'All registered residents',
      icon: Icons.group_rounded,
      iconColor: AppColors.green,
    ),
    const _AudienceOption(
      label: 'Barangay Hall',
      subtitle: 'General announcement for the barangay',
      icon: Icons.account_balance_rounded,
      iconColor: AppColors.orange,
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledDateTime != null
          ? TimeOfDay.fromDateTime(_scheduledDateTime!)
          : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatSchedule(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ·  $h:$m $ampm';
  }

  String? _validate() {
    if (_titleController.text.trim().isEmpty) return 'Please enter a title.';
    if (_descController.text.trim().isEmpty) return 'Please enter a description.';
    if (_selectedAudience == null) return 'Please select a target audience.';
    return null;
  }

  Future<void> _postAnnouncement() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      await Supabase.instance.client.from('announcements').insert({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'author': 'Kap. Maria Santos', // Replace with actual user name
        'target_audience': _selectedAudience,
        if (_scheduleEnabled && _scheduledDateTime != null)
          'scheduled_at': _scheduledDateTime!.toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement posted successfully!'),
          backgroundColor: AppColors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('New Announcement', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: _isPosting ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Announcement Details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Share updates with the community', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Title', required: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    maxLength: 100,
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Enter announcement title',
                      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Description', required: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLength: 2000,
                    maxLines: 6,
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Write your announcement here...',
                      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Target Audience', required: true),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _audienceOptions.length,
                        (i) => Column(
                      children: [
                        _AudienceTile(
                          option: _audienceOptions[i],
                          isSelected: _selectedAudience == _audienceOptions[i].label,
                          onTap: () => setState(() => _selectedAudience = _audienceOptions[i].label),
                        ),
                        if (i < _audienceOptions.length - 1) const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _scheduleEnabled ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border, width: _scheduleEnabled ? 1.5 : 1),
                boxShadow: _scheduleEnabled ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: _scheduleEnabled ? AppColors.primary : AppColors.grayBg, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.calendar_month_rounded, color: _scheduleEnabled ? Colors.white : AppColors.textGrey, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Schedule', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('Publish on a specific date', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _scheduleEnabled,
                          onChanged: (v) => setState(() { _scheduleEnabled = v; if (!v) _scheduledDateTime = null; }),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primaryLight,
                        ),
                      ],
                    ),
                  ),
                  if (_scheduleEnabled) ...[
                    const Divider(height: 1, color: AppColors.border),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: _pickSchedule,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(color: AppColors.bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: _scheduledDateTime != null ? AppColors.primary : AppColors.border)),
                          child: Row(
                            children: [
                              Icon(Icons.event_rounded, color: _scheduledDateTime != null ? AppColors.primary : AppColors.textGrey, size: 20),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_scheduledDateTime != null ? _formatSchedule(_scheduledDateTime!) : 'Select date and time', style: TextStyle(color: _scheduledDateTime != null ? AppColors.textDark : AppColors.textGrey, fontSize: 14))),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isPosting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Post Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: child);

  Widget _fieldLabel(String text, {bool required = false}) => Row(children: [Text(text, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 14)), if (required) const Text(' *', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700))]);
}

class _AudienceOption {
  final String label, subtitle;
  final IconData icon;
  final Color iconColor;
  const _AudienceOption({required this.label, required this.subtitle, required this.icon, required this.iconColor});
}

class _AudienceTile extends StatelessWidget {
  final _AudienceOption option;
  final bool isSelected;
  final VoidCallback onTap;
  const _AudienceTile({required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1), borderRadius: BorderRadius.circular(10), color: isSelected ? AppColors.primaryLight : Colors.white),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: option.iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(option.icon, color: option.iconColor, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(option.label, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14)), Text(option.subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12))])),
            Radio<String>(value: option.label, groupValue: isSelected ? option.label : null, onChanged: (_) => onTap(), activeColor: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
