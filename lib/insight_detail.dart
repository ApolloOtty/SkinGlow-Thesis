import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class InsightDetailPage extends StatelessWidget {
  final Insight insight;

  const InsightDetailPage({Key? key, required this.insight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(insight.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Html(data: insight.text),
        ),
      ),
    );
  }
}

class Insight {
  final int insightId;
  final String title;
  final String text;

  Insight({required this.insightId, required this.title, required this.text});

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      insightId: json['insight_id'],
      title: json['title'],
      text: json['text'],
    );
  }
}
