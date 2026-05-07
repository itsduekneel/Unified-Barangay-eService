import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final int value;
  final String label;
  final double pct;
  final bool isActive;

  const StatusCard({
    super.key,
    required this.value,
    required this.label,
    required this.pct,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF8B2CF5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Color(0xFF8B2CF5) : Color(0xFFEBE0FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Color(0xFF360C78),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.white70 : Color(0xFF8B2CF5),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.25)
                  : Color(0xFFEBE0FF),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Color(0xFF8B2CF5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
