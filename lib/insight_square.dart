import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class InsightSquare extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final int wordCount;

  const InsightSquare({
    Key? key,
    required this.title,
    required this.onTap,
    required this.backgroundColor,
    required this.wordCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parts = title.split(' ');
    final emoji = parts.first;
    final insightTitle = parts.sublist(1).join(' ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 300, // Adjusted width to make it wider
        decoration: BoxDecoration(
          color: backgroundColor, // Background color
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          margin: const EdgeInsets.all(4.0), // Margin to show background color
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 150,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      AutoSizeText(
                        insightTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      AutoSizeText(
                        _calculateReadTime(wordCount),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateReadTime(int wordCount) {
    final readTime = (wordCount / 140).ceil();
    return '$readTime min read ($wordCount words)';
  }
}
