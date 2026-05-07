import 'package:flutter/material.dart';
import 'package:ube/authentication/app_colors.dart';

// ─── STEP INDICATOR ──────────────────────────────────────────────────────────

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i <= currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
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
