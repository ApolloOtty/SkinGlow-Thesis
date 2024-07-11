import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BannedIngredientsScreen extends StatefulWidget {
  final List<String> ingredients;

  const BannedIngredientsScreen({super.key, required this.ingredients});

  @override
  _BannedIngredientsScreenState createState() =>
      _BannedIngredientsScreenState();
}

class _BannedIngredientsScreenState extends State<BannedIngredientsScreen> {
  List<String> searchResults = [];
  List<String> selectedIngredients = [];
  Map<String, int> originalIndices = {};
  bool isSearching = false;
  // Example user ID, replace with actual user ID

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSelectedIngredients();
    for (int i = 0; i < widget.ingredients.length; i++) {
      originalIndices[widget.ingredients[i]] = i;
    }
  }

  Future<void> _loadSelectedIngredients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userid');
    final response = await http
        .get(Uri.parse('api-link/user/$userId/selectedBannedIngredients'));

    if (response.statusCode == 200) {
      setState(() {
        selectedIngredients = List<String>.from(json.decode(response.body));
      });
    } else {
      // Handle error
      print('Failed to load selected ingredients');
    }
  }

  Future<void> _saveSelectedIngredients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userid');
    final response = await http.post(
      Uri.parse('api-link/user/$userId/selectedBannedIngredients'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'selectedIngredients': selectedIngredients}),
    );

    if (response.statusCode != 200) {
      // Handle error
      print('Failed to save selected ingredients');
    }
  }

  void searchIngredients(String query) {
    if (query.length < 2) {
      return;
    }

    if (query.isNotEmpty) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          isSearching = true;
          final lowerCaseQuery = query.toLowerCase();
          final exactMatches = widget.ingredients
              .where((ingredient) => ingredient.toLowerCase() == lowerCaseQuery)
              .toList();
          final partialMatches = widget.ingredients
              .where((ingredient) =>
                  ingredient.toLowerCase().contains(lowerCaseQuery) &&
                  !exactMatches.contains(ingredient))
              .toList();
          searchResults = [...exactMatches, ...partialMatches];
        });
      });
    } else {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
    }
  }

  void addToSelectedIngredients(String ingredient) {
    setState(() {
      searchResults.remove(ingredient);
      searchResults.insert(0, ingredient);
      selectedIngredients.add(ingredient);
    });
    _saveSelectedIngredients();
  }

  void removeFromSelectedIngredients(String ingredient) {
    setState(() {
      selectedIngredients.remove(ingredient);
      searchResults = selectedIngredients.toList();
    });
    _saveSelectedIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Banned Ingredients'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Search'),
              Tab(text: 'Selected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: searchIngredients,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search for ingredients...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final ingredient = searchResults[index];
                        final isSelected =
                            selectedIngredients.contains(ingredient);
                        return ListTile(
                          title: Text(ingredient),
                          onTap: () {
                            if (isSelected) {
                              removeFromSelectedIngredients(ingredient);
                            } else {
                              addToSelectedIngredients(ingredient);
                            }
                          },
                          trailing: isSelected
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    removeFromSelectedIngredients(ingredient);
                                  },
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedIngredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = selectedIngredients[index];
                        return ListTile(
                          title: Text(ingredient),
                          onTap: () {
                            removeFromSelectedIngredients(ingredient);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              removeFromSelectedIngredients(ingredient);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
