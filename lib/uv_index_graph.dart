import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('UV Index Graph')),
      ),
    );
  }
}

class UVIndexGraph extends StatelessWidget {
  final double uvIndex;

  const UVIndexGraph({Key? key, required this.uvIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(300, 150), // Adjusted size
          painter: UVIndexPainter(uvIndex),
        ),
        SizedBox(
          width: 120,
          height: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(
                  255, 11, 78, 133), // Button background color
              foregroundColor: Colors.white, // Button text color
              textStyle: const TextStyle(fontSize: 15),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Protective measures'),
                    content: Text(getUVProtectionMessage(uvIndex)),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('More Info'),
          ),
        ),
      ],
    );
  }

  String getUVProtectionMessage(double uvIndex) {
    if (uvIndex <= 2) {
      return 'No protection needed. You can safely stay outside and enjoy the sun using minimal sun protection.';
    } else if (uvIndex <= 5) {
      return 'Take precautions. Wear sunscreen, sunhat, sunglasses, seek shade during peak hours of 11 AM to 4 PM';
    } else if (uvIndex <= 7.9) {
      return 'Protection needed. Seek shade during late morning through mid-afternoon. When outside, generously apply broad-spectrum SPF 15 or higher sunscreen on exposed skin, and wear protective clothing, a wide-brimmed hat, and sunglasses.';
    } else if (uvIndex <= 10) {
      return 'Seek shade. Wear sun protective clothing, sunscreen and sunglasses.';
    } else {
      return 'Extra protection needed. Be careful outside, exposed skin can burn in minutes, especially during late morning through mid-afternoon. If your shadow is shorter than you, seek shade and wear protective clothing, a wide-brimmed hat, and sunglasses, and generously apply a minimum of SPF 15, broad-spectrum sunscreen on exposed skin.';
    }
  }
}

class UVIndexPainter extends CustomPainter {
  final double uvIndex;
  final double maxUVIndex = 11.0; // Assuming the maximum UV index value is 11

  UVIndexPainter(this.uvIndex);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = const Color.fromARGB(255, 8, 57, 97)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    // Determine graph color based on UV index
    Color fillColor;
    if (uvIndex <= 2.9) {
      fillColor = const Color.fromARGB(255, 32, 244, 39);
    } else if (uvIndex <= 5.9) {
      fillColor = Colors.yellow;
    } else if (uvIndex <= 7.9) {
      fillColor = Colors.orange;
    } else if (uvIndex <= 10.9) {
      fillColor = const Color.fromARGB(255, 255, 17, 0);
    } else {
      fillColor = const Color.fromARGB(255, 145, 84, 249);
    }

    Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      pi, // Start angle (pi radians)
      pi, // Sweep angle (pi radians, making a half circle)
      false,
      backgroundPaint,
    );

    // Clamp the UV index value to the maximum value
    double clampedUVIndex = uvIndex.clamp(0, maxUVIndex);

    // Calculate the sweep angle based on the clamped UV index
    double sweepAngle = (clampedUVIndex / maxUVIndex) * pi;

    // Draw filled arc
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      pi, // Start angle (pi radians)
      sweepAngle,
      false,
      fillPaint,
    );

    // Draw the UV index number
    TextSpan uvIndexSpan = TextSpan(
      style: const TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      text: uvIndex.toString(),
    );
    TextPainter uvIndexPainter = TextPainter(
      text: uvIndexSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    uvIndexPainter.layout();
    uvIndexPainter.paint(
      canvas,
      Offset(size.width / 2 - uvIndexPainter.width / 2, size.height - 185),
    );

    // Draw the UV index level text in the middle
    TextSpan span = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      text: getUVLevel(clampedUVIndex),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, size.height - 85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  String getUVLevel(double uvIndex) {
    if (uvIndex <= 2.9) {
      return 'Low';
    } else if (uvIndex <= 5.9) {
      return 'Moderate';
    } else if (uvIndex <= 7.9) {
      return 'High';
    } else if (uvIndex <= 10.9) {
      return 'Very High';
    } else {
      return 'Extremely High';
    }
  }
}
