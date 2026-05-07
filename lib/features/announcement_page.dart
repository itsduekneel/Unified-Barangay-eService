import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _isPosting = false; // ← loading state

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _lightPurple = Color(0xFFEDE9FE);
  static const Color _bgGray = Color(0xFFF5F4FA);
  static const Color _borderGray = Color(0xFFE5E7EB);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGray = Color(0xFF6B7280);

  final List<_AudienceOption> _audienceOptions = [
    _AudienceOption(
      label: 'Specific Individuals',
      subtitle: 'Send to selected individuals',
      icon: Icons.people_alt_rounded,
      iconColor: _purple,
    ),
    _AudienceOption(
      label: 'Barangay Workers',
      subtitle: 'All barangay staff and officials',
      icon: Icons.groups_rounded,
      iconColor: Color(0xFF3B82F6),
    ),
    _AudienceOption(
      label: 'Barangay Residents',
      subtitle: 'All registered residents',
      icon: Icons.group_rounded,
      iconColor: Color(0xFF16A34A),
    ),
    _AudienceOption(
      label: 'Barangay Hall',
      subtitle: 'General announcement for the barangay',
      icon: Icons.account_balance_rounded,
      iconColor: Color(0xFFF59E0B),
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ─── Validation ─────────────────────────────────────────────────────────────
  String? _validate() {
    if (_titleController.text.trim().isEmpty) {
      return 'Please enter a title.';
    }
    if (_descController.text.trim().isEmpty) {
      return 'Please enter a description.';
    }
    if (_selectedAudience == null) {
      return 'Please select a target audience.';
    }
    return null;
  }

  // ─── Post to Supabase ────────────────────────────────────────────────────────
  Future<void> _postAnnouncement() async {
    // 1. Validate first
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // 2. Set loading
    setState(() => _isPosting = true);

    try {
      await Supabase.instance.client.from('announcements').insert({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'author': 'Kap. Maria Santos',
        'target_audience': _selectedAudience,
      });

      if (!mounted) return;

      // 3. Success feedback then go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on PostgrestException catch (e) {
      // Supabase-specific error (e.g. RLS policy blocked it)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supabase error: ${e.message}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // Generic error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        title: const Text(
          'Announcement',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F4FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF8B2CF5),
            size: 20,
          ),
          onPressed: _isPosting ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEBE0FF)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Announcement Details',
                          style: TextStyle(
                            color: _purple,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Share updates and important information',
                          style: TextStyle(color: _textGray, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Title field
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Title', required: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    maxLength: 100,
                    style: const TextStyle(fontSize: 14, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Enter announcement title',
                      hintStyle: const TextStyle(
                        color: _textGray,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _borderGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: _purple,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      counterStyle: const TextStyle(
                        fontSize: 12,
                        color: _textGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description field
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Description', required: true),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderGray),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      color: _bgGray,
                    ),
                    child: Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: [
                        _toolbarBtn(Icons.format_bold_rounded),
                        _toolbarBtn(Icons.format_italic_rounded),
                        _toolbarBtn(Icons.format_underline_rounded),
                        _toolbarBtn(Icons.format_list_bulleted_rounded),
                        _toolbarBtn(Icons.format_list_numbered_rounded),
                        _toolbarBtn(Icons.format_indent_increase_rounded),
                        _toolbarBtn(Icons.link_rounded),
                        _toolbarBtn(Icons.image_outlined),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _descController,
                    maxLength: 2000,
                    maxLines: 6,
                    style: const TextStyle(fontSize: 14, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Write your announcement here...',
                      hintStyle: const TextStyle(
                        color: _textGray,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        borderSide: const BorderSide(color: _borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        borderSide: const BorderSide(color: _borderGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        borderSide: const BorderSide(
                          color: _purple,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      counterStyle: const TextStyle(
                        fontSize: 12,
                        color: _textGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Target audience
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Target Audience', required: true),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose who will receive this announcement',
                    style: TextStyle(fontSize: 13, color: _textGray),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _audienceOptions.length,
                    (i) => Column(
                      children: [
                        _AudienceTile(
                          option: _audienceOptions[i],
                          isSelected:
                              _selectedAudience == _audienceOptions[i].label,
                          onTap: () => setState(
                            () => _selectedAudience = _audienceOptions[i].label,
                          ),
                        ),
                        if (i < _audienceOptions.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_rounded, color: _purple, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important Note',
                                style: TextStyle(
                                  color: _purple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Make sure your announcement is clear and respectful. False information may be subject to review.',
                                style: TextStyle(color: _purple, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Additional options
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Options',
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _lightPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: _purple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Schedule',
                                  style: TextStyle(
                                    color: _textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '(Optional)',
                                  style: TextStyle(
                                    color: _textGray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Set when this announcement will be posted',
                              style: TextStyle(color: _textGray, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _scheduleEnabled,
                        onChanged: (v) => setState(() => _scheduleEnabled = v),
                        activeThumbColor: _purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CTA button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  disabledBackgroundColor: _purple.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Review & Post Announcement',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }

  Widget _toolbarBtn(IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Icon(icon, size: 18, color: _textGray),
      ),
    );
  }
}

class _AudienceOption {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _AudienceOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

class _AudienceTile extends StatelessWidget {
  final _AudienceOption option;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _borderGray = Color(0xFFE5E7EB);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGray = Color(0xFF6B7280);

  const _AudienceTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? _purple : _borderGray,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: option.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(option.icon, color: option.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: const TextStyle(color: _textGray, fontSize: 12),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: option.label,
              groupValue: isSelected ? option.label : null,
              onChanged: (_) => onTap(),
              activeColor: _purple,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
