import 'package:flutter/material.dart';

class ProgressItem {
  final String label;
  final double value;
  const ProgressItem({required this.label, required this.value});
}

class MultiRingChart extends StatefulWidget {
  final List<ProgressItem> items;
  const MultiRingChart({super.key, required this.items});

  @override
  State<MultiRingChart> createState() => _MultiRingChartState();
}

class _MultiRingChartState extends State<MultiRingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late ScrollController _scrollController;

  static const double chartSize = 140;

  final List<double> ringSizes = [140, 115, 90, 65, 40];
  final List<Color> ringColors = [
    const Color(0xFF8B2CF5),
    const Color(0xFF9D4EDD),
    const Color(0xFFC77DFF),
    const Color(0xFFE0AAFF),
    const Color(0xFFF3D9FF),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animations = List.generate(widget.items.length, (index) {
      return Tween<double>(begin: 0, end: widget.items[index].value).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (index * 0.1).clamp(0.0, 0.9),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180, // Importante para sa scrollable area
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // CHART SECTION
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(widget.items.length, (index) {
                return SizedBox(
                  // Gamit ang % para hindi lumampas sa list length (Modulo)
                  width: ringSizes[index % ringSizes.length],
                  height: ringSizes[index % ringSizes.length],
                  child: AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _animations[index].value,
                        strokeWidth: 8,
                        color: ringColors[index % ringColors.length],
                        backgroundColor: Colors.black12,
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                );
              }),
            ),
          ),

          const SizedBox(width: 20),

          // LEGEND SECTION
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ringColors[index % ringColors.length],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
