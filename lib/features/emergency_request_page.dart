import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────
class _T {
  static const purple = Color(0xFF8B2CF5);
  static const purpleLight = Color(0xFFEDE9FE);
  static const purpleSoft = Color(0xFFFAF8FF);
  static const purpleBorder = Color(0xFFE9D5FF);

  // Step-aware status colors
  static Color statusColor(int step) => switch (step) {
    0 => const Color(0xFFF59E0B), // amber  – Pending
    1 => const Color(0xFF3B82F6), // blue   – Assigned
    2 => const Color(0xFFF97316), // orange – Responding
    _ => const Color(0xFF22C55E), // green  – Completed
  };
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class StepItem {
  final String label;
  final String desc;
  const StepItem(this.label, this.desc);
}

const _kSteps = [
  StepItem('Pending', 'Waiting for admin to approve'),
  StepItem('Assigned', 'Responder team are preparing'),
  StepItem('Responding', 'Responder team is on the way'),
  StepItem('Completed', 'Responder operation successful'),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class EmergencyRequestPage extends StatelessWidget {
  final String emergencyLabel;
  final String emergencySub;
  final int currentStep;

  const EmergencyRequestPage({
    super.key,
    this.emergencyLabel = 'Emergency Request',
    this.emergencySub = 'No details provided',
    this.currentStep = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const Expanded(child: _MapPlaceholder()),
          _EmergencyBottomSheet(
            steps: _kSteps,
            currentStep: currentStep,
            emergencyLabel: emergencyLabel,
            emergencySub: emergencySub,
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: Color(0xFF9CA3AF)),
            SizedBox(height: 8),
            Text(
              'Map goes here',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet ─────────────────────────────────────────────────────────────

class _EmergencyBottomSheet extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStep;
  final String emergencyLabel;
  final String emergencySub;

  const _EmergencyBottomSheet({
    required this.steps,
    required this.currentStep,
    required this.emergencyLabel,
    required this.emergencySub,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EmergencyCard(
                  steps: steps,
                  currentStep: currentStep,
                  emergencyLabel: emergencyLabel,
                  emergencySub: emergencySub,
                ),
                const SizedBox(height: 12),
                const _ActionButtonsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _EmergencyCard extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStep;
  final String emergencyLabel;
  final String emergencySub;

  // Capture timestamp at construction, not on every rebuild.
  final DateTime _submittedAt = DateTime.now();

  _EmergencyCard({
    required this.steps,
    required this.currentStep,
    required this.emergencyLabel,
    required this.emergencySub,
  });

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep.clamp(0, steps.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emergencyLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    emergencySub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(label: step.label, step: currentStep),
          ],
        ),
        const SizedBox(height: 14),
        _StepProgressBar(totalSteps: steps.length, currentStep: currentStep),
        const SizedBox(height: 6),
        // Step description below bar
        Text(
          step.desc,
          style: TextStyle(
            fontSize: 11,
            color: _T.statusColor(currentStep),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow(submittedAt: _submittedAt),
      ],
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final int step;

  const _StatusBadge({required this.label, required this.step});

  @override
  Widget build(BuildContext context) {
    final color = _T.statusColor(step);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const _StepProgressBar({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 5),
            decoration: BoxDecoration(
              color: active ? _T.statusColor(currentStep) : _T.purpleLight,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Info chips row ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final DateTime submittedAt;
  const _InfoRow({required this.submittedAt});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _InfoChip(label: 'Responder', value: 'Tanod'),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _InfoChip(
              label: 'Submitted',
              value: DateFormat('MMM dd, yyyy\nhh:mm a').format(submittedAt),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _InfoChip(label: 'Distance', value: '0.8 km'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: _T.purpleSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.purpleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _T.purple,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.call_rounded,
            label: 'Call',
            variant: _ButtonVariant.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            variant: _ButtonVariant.outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.close_rounded,
            label: 'Cancel',
            variant: _ButtonVariant.destructive,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

enum _ButtonVariant { primary, outline, destructive }

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final _ButtonVariant variant;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.variant,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(24));
    const vPad = EdgeInsets.symmetric(vertical: 13);

    return switch (variant) {
      _ButtonVariant.primary => ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _T.purple,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: vPad,
        ),
      ),
      _ButtonVariant.outline => OutlinedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16, color: _T.purple),
        label: Text(
          label,
          style: const TextStyle(color: _T.purple, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _T.purple),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: vPad,
        ),
      ),
      _ButtonVariant.destructive => OutlinedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16, color: Colors.red.shade600),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade400),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: vPad,
        ),
      ),
    };
  }
}
