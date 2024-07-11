import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'insight_detail.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AllInsightsPage extends StatefulWidget {
  @override
  _AllInsightsPageState createState() => _AllInsightsPageState();
}

class _AllInsightsPageState extends State<AllInsightsPage> {
  List<Insight> _insights = [];
  List<Insight> _filteredInsights = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchInsights();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredInsights = _insights
          .where((insight) =>
              insight.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> fetchInsights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userid');

    if (userId != null) {
      try {
        var url = Uri.parse('api-link/getAllUserInsights');
        var response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          var insightsData = json.decode(response.body) as List;
          setState(() {
            _insights =
                insightsData.map((data) => Insight.fromJson(data)).toList();
            _filteredInsights = _insights;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load insights');
        }
      } catch (e) {
        print('Error fetching insights: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getBackgroundColor(int index) {
    const colors = [
      Color.fromARGB(80, 152, 251, 152),
      Color.fromARGB(83, 216, 191, 216),
      Color.fromARGB(59, 255, 217, 0),
      Color.fromARGB(94, 173, 216, 230),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(
                255, 220, 220, 220), // Background color of the search box
            borderRadius: BorderRadius.circular(12.0), // Rounded edges
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Insights',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10.0),
              hintStyle: TextStyle(color: Colors.black54),
            ),
            style: TextStyle(color: Colors.black, fontSize: 18.0), // Dark text
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredInsights.length,
              itemBuilder: (context, index) {
                final insight = _filteredInsights[index];
                return InsightSquareVertical(
                  title: insight.title,
                  wordCount: insight.text.split(' ').length,
                  backgroundColor: _getBackgroundColor(index), // Cycle colors
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InsightDetailPage(insight: insight),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class InsightSquareVertical extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final int wordCount;

  const InsightSquareVertical({
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
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        height: 120, // Set a fixed height
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Container(
              width: 80, // Reduced width of emoji container
              padding: const EdgeInsets.all(8.0), // Adjusted padding
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 48), // Increased font size
                ),
              ),
            ),
            const SizedBox(width: 8), // Adjusted spacing
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12.0), // Adjusted padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center content vertically
                  children: [
                    const SizedBox(height: 4),
                    Flexible(
                      child: AutoSizeText(
                        insightTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AutoSizeText(
                      _calculateReadTime(wordCount),
                      style: const TextStyle(
                        fontSize: 12,
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
    );
  }

  String _calculateReadTime(int wordCount) {
    final readTime = (wordCount / 140).ceil();
    return '$readTime min read ($wordCount words)';
  }
}
