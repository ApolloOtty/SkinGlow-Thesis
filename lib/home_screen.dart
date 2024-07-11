import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'decode_screen.dart';
import 'package:location/location.dart';
import 'uv_page.dart';
import 'routine_page.dart';
import 'image_rec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'insight_detail.dart';
import 'profile_screen.dart';
import 'dart:io';
import 'insight_square.dart';
import 'all_insights_page.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;
  double? _uvIndex;
  String? _userName;
  List<Insight> _insights = [];
  String? _cityName; // Variable to store city name
  late TabController _tabController;
  String? profileImagePath; // Variable to store profile image path
  int? userId;
  bool _isLoadingInsights =
      true; // Variable to indicate loading state for insights

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 4 tabs
    _tabController = TabController(length: 4, vsync: this);
    // Fetch user information, UV index, and insights when the app starts
    fetchUserInfo();
    fetchUVIndex();
    fetchInsights(); // Fetch insights when the app opens
    loadProfileImage(); // Load profile image when the app opens
  }

  @override
  void dispose() {
    // Dispose the TabController when the widget is disposed
    _tabController.dispose();
    super.dispose();
  }

  // Function to load the profile image path from SharedPreferences
  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userid');
    setState(() {
      profileImagePath = prefs.getString('profileImagePath_$userId') ?? '';
    });
  }

  // Function to fetch user information from the server
  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userid');
    if (userId != null) {
      try {
        var url = Uri.parse('api-link/getuserinfo?userid=$userId');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var userData = json.decode(response.body);
          String? userName = userData['name'];

          if (userName != null) {
            await prefs.setString('username', userName);
          }

          setState(() {
            _userName = userName;
          });
        } else {
          throw Exception('Failed to load user info');
        }
      } catch (e) {
        print('Error fetching user info: $e');
      }
    }
  }

  // Function to fetch the UV index using the user's location
  Future<void> fetchUVIndex() async {
    Location location = Location();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    final latitude = _locationData!.latitude!;
    final longitude = _locationData!.longitude!;
    print(latitude);
    print(longitude);

    await fetchCityName(
        latitude, longitude); // Fetch city name based on location

    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=uv_index_max&forecast_days=1');
    final response = await http.get(
      url,
    );
    if (response.statusCode == 200) {
      final uvData = json.decode(response.body);
      setState(() {
        if (uvData.containsKey('daily')) {
          var dailyData = uvData['daily'];
          if (dailyData is Map && dailyData.containsKey('uv_index_max')) {
            var uvIndexMax = dailyData['uv_index_max'];
            if (uvIndexMax is List && uvIndexMax.isNotEmpty) {
              _uvIndex = uvIndexMax[0].toDouble();
            }
          }
        }
      });
    } else {
      throw Exception('Failed to load UV index');
    }
  }

  // Function to fetch the city name using latitude and longitude
  Future<void> fetchCityName(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=en');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _cityName = data['city'] ?? 'Unknown location';
      });
    } else {
      throw Exception('Failed to load city name');
    }
  }

  // Function to fetch user insights from the server
  Future<void> fetchInsights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userid');

    if (userId != null) {
      try {
        var url = Uri.parse('api-link/user/$userId/getUserInsights');
        var response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          var insightsData = json.decode(response.body) as List;
          setState(() {
            _insights =
                insightsData.map((data) => Insight.fromJson(data)).toList();
            _isLoadingInsights = false; // Set loading state to false
          });
        } else {
          throw Exception('Failed to load insights');
        }
      } catch (e) {
        print('Error fetching insights: $e');
      }
    }
  }

  // Function to update the profile image path
  void updateProfileImage(String path) {
    setState(() {
      profileImagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/profile',
                  );
                },
                child: Row(
                  children: <Widget>[
                    if (profileImagePath != null &&
                        profileImagePath!.isNotEmpty)
                      CircleAvatar(
                        backgroundImage: FileImage(File(profileImagePath!)),
                        radius: 15,
                      )
                    else
                      const Icon(
                        Icons.person,
                        size: 30.0,
                      ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (_userName != null) Text(_userName!),
                        if (_userName != null)
                          const Text(
                            'Hey, nice skin!',
                            style: TextStyle(fontSize: 15),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_uvIndex != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UVIndexPage(
                            uvIndex: _uvIndex!, cityName: _cityName!),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/sun.png',
                            width: 73,
                            height: 73,
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _uvIndex!.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 132, 70, 0),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const CircularProgressIndicator(), // Show loading indicator while UV index is loading
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Insights',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: const Color.fromARGB(255, 96, 96, 96),
                              ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors
                                .blue.shade50, // Set the background color here
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/all_insights');
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: _isLoadingInsights
                        ? _buildShimmerEffect() // Show shimmer effect if loading
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _insights.length,
                            itemBuilder: (context, index) {
                              final insight = _insights[index];
                              return InsightSquare(
                                title: insight.title,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InsightDetailPage(insight: insight),
                                    ),
                                  );
                                },
                                backgroundColor: _getBackgroundColor(index),
                                wordCount: _getWordCount(insight.text),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 70),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'What do you want to do today?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionSquare(
                            title: 'Decode Ingredients',
                            icon: Image.asset('assets/images/decode3.png',
                                width: 52, height: 52),
                            onTap: () {
                              _tabController.animateTo(3);
                            },
                          ),
                          const SizedBox(width: 16),
                          ActionSquare(
                            title: 'Scan Moles',
                            icon: Transform.translate(
                              offset:
                                  Offset(0, -8), // Move the image 10 pixels up
                              child: Image.asset(
                                'assets/images/mole.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            onTap: () {
                              _tabController.animateTo(2);
                            },
                          ),
                          const SizedBox(width: 16),
                          ActionSquare(
                            title: 'Add a product',
                            icon: Transform.translate(
                              offset:
                                  Offset(0, -8), // Move the image 10 pixels up
                              child: Image.asset('assets/images/addproduct.png',
                                  width: 50, height: 50),
                            ),
                            onTap: () {
                              _tabController.animateTo(1);
                            },
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SkincareProductPage(),
            const ImageUploadPage(),
            const DecodeScreen(),
          ],
        ),
        bottomNavigationBar: Material(
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.house_outlined),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Home'),
                  ],
                ),
              ),
              Tab(
                icon: Icon(Icons.add_box_outlined),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Add a'),
                    Text('product'),
                  ],
                ),
              ),
              Tab(
                icon: Icon(Icons.donut_large),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Scan your'),
                    Text('moles'),
                  ],
                ),
              ),
              Tab(
                icon: Icon(Icons.text_snippet_outlined),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Decode'),
                    Text('ingredients'),
                  ],
                ),
              ),
            ],
            labelStyle: TextStyle(fontSize: 11.0), // Selected tab text style
            unselectedLabelStyle:
                TextStyle(fontSize: 0.0), // Unselected tab text style
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
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

  int _getWordCount(String content) {
    return content.split(' ').length;
  }
}

class ActionSquare extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const ActionSquare({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white, // Set background color to white
          border: Border.all(
              color: const Color.fromARGB(255, 76, 76, 76),
              width: 2), // Dark border
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon, // Use the widget directly
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
