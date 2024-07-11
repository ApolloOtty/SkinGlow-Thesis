import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart'; // Ensure you import ProfilePage
import 'settings_page.dart';
import 'nameage_page.dart';
import 'skin_type_quiz_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'all_insights_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<String>> _fetchIngredientsFuture;

  @override
  void initState() {
    super.initState();
    _fetchIngredientsFuture = fetchAllIngredients();
  }

  Future<List<String>> fetchIngredients(int page, int pageSize) async {
    final response = await http.get(
      Uri.parse('api-link/fetchingredients?page=$page&page_size=$pageSize'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> ingredients = data.cast<String>();
      return ingredients;
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  Future<List<String>> fetchAllIngredients() async {
    List<String> allIngredients = [];
    int page = 1;
    int pageSize = 5000;
    bool hasMoreData = true;

    while (hasMoreData) {
      try {
        List<String> ingredients = await fetchIngredients(page, pageSize);
        if (ingredients.isNotEmpty) {
          allIngredients.addAll(ingredients);
          page++; // Move to the next page
        } else {
          hasMoreData = false; // No more data available
        }
      } catch (e) {
        print('Error fetching ingredients: $e');
        break; // Exit loop on error
      }
    }

    return allIngredients;
  }

  void updateProfileImage(String path) {
    // Update the profile image path in the state and shared preferences
    setState(() {
      // Handle updating the profile image path
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/all_insights': (context) => AllInsightsPage(),
        '/name': (context) => const NameAndAgeScreen(),
        '/login': (context) => const LoginScreen(),
        '/skin_type_quiz': (context) => const SkinTypeQuiz(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => FutureBuilder(
              future:
                  Future.wait([_fetchIngredientsFuture, getUserName(context)]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<String> ingredients = snapshot.data![0];
                    String userName = snapshot.data![1];

                    // Pass the fetched ingredients array and username to ProfilePage
                    return ProfilePage(
                      ingredients: ingredients,
                      userName: userName,
                      updateProfileImage:
                          updateProfileImage, // Pass the callback
                    );
                  }
                }
              },
            ),
        '/settings': (context) => const SettingsPage(),
        '/': (context) => FutureBuilder<bool>(
              future: isLoggedIn(context),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading spinner while waiting for isLoggedIn to complete
                } else {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return snapshot.data == true
                        ? const HomeScreen()
                        : const WelcomeScreen(); // Show HomeScreen if isLoggedIn is true, otherwise show WelcomeScreen
                  }
                }
              },
            ),
      },
    );
  }

  Future<bool> isLoggedIn(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userid'); // Change type to int?
    print(userId);
    return userId !=
        null; // Return true if user ID exists (i.e., user is logged in)
  }

  Future<String?> getUserName(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    print(username);
    return username;
  }
}
