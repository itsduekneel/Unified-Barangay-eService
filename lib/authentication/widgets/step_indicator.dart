import 'package:flutter/material.dart';
import 'package:ube/authentication/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String>? labels;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (i) {
            final isDone   = i < currentStep;
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
                            ? AppColors.green
                            : isActive
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (i < totalSteps - 1) const SizedBox(width: 6),
                ],
              ),
            );
          }),
        ),
        if (labels != null && currentStep < labels!.length) ...[
          const SizedBox(height: 8),
          Text(
            'Step ${currentStep + 1} of $totalSteps  ·  ${labels![currentStep]}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
