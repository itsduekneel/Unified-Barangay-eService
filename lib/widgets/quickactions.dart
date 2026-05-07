import 'package:flutter/material.dart';

// ─── MODEL ─────────────────────────────────────────────
class QuickActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  QuickActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

// ─── COLORS ────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF8B2CF5);
  static final iconBg = primary.withOpacity(0.08);
  static final iconBorder = primary.withOpacity(0.2);
}

// ─── MAIN CONTAINER ────────────────────────────────────
class QuickActionsContainer extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActionsContainer({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: action.onTap,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.iconBorder),
                      ),
                      child: Icon(action.icon, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
