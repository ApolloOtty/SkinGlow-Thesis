import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, String> sectionResults;

  ResultsPage({required this.sectionResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Skin Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGridView(
              categories: [
                'Skin Type',
                'Sensitivity',
                'Acne Proneness',
                'Tone',
              ]
                  .map((category) => {
                        'title': category,
                        'result': sectionResults[category] ?? 'missing',
                        'emoji': _getEmojiForCategory(
                            category, sectionResults[category] ?? 'missing'),
                      })
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView({required List<Map<String, String>> categories}) {
    const double boxWidth = 140;
    const double maxFontSize = 20;
    const double lineHeight = 3;
    final List<Color> pastelColors = [
      const Color.fromARGB(80, 152, 251, 152),
      const Color.fromARGB(83, 216, 191, 216),
      const Color.fromARGB(59, 255, 217, 0),
      const Color.fromARGB(94, 173, 216, 230),
    ];

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final color = pastelColors[index % pastelColors.length];
          return Container(
            width: boxWidth,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: maxFontSize + 5,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: Text(
                      category['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 51, 51, 51),
                        fontSize: maxFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: lineHeight,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category['emoji']!,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  category['result']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: category['result'] == 'missing'
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getEmojiForCategory(String category, String value) {
    switch (category) {
      case 'Skin Type':
        if (value == 'Oily Skin') return '🫒';
        if (value == 'Dry Skin') return '🌵';
        if (value == 'Combination Skin') return '🌗';
        if (value == 'Balanced Skin') return '⚖️';
        break;
      case 'Sensitivity':
        if (value == 'Sensitive Skin') return '🌡️';
        if (value == 'Resilient Skin') return '🛡️';
        break;
      case 'Acne Proneness':
        if (value == 'Congested Skin') return '🌋';
        if (value == 'Occasional Breakout') return '🌤️';
        if (value == 'Clear Skin') return '🌈';
        break;
      case 'Tone':
        if (value == 'Uneven Tone') return '🍪';
        if (value == 'Even Tone') return '🥚';
        break;
      default:
        return '🔦';
    }
    return '🔦';
  }
}
