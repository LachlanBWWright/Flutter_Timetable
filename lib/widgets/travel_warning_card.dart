import 'package:flutter/material.dart';

class TravelWarningCard extends StatelessWidget {
  const TravelWarningCard({
    super.key,
    required this.title,
    required this.children,
    this.margin,
  });

  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  static const Color foregroundColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: Colors.amber.shade300,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: foregroundColor),
          child: IconTheme.merge(
            data: const IconThemeData(color: foregroundColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
