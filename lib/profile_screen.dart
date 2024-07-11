import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:skinglow/loved_ingredients.dart';
import 'package:skinglow/skin_type_quiz_screen.dart';
import 'banned_ingredients.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loved_ingredients.dart';

class ProfilePage extends StatefulWidget {
  final List<String> ingredients;
  final String userName;
  final Function(String) updateProfileImage;

  const ProfilePage(
      {super.key,
      required this.ingredients,
      required this.userName,
      required this.updateProfileImage});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String skinType = 'Loading...';
  String sensitivity = 'Loading...';
  String acneProneness = 'Loading...';
  String tone = 'Loading...';
  String profileImagePath = '';
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    loadProfileImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userid');
    final url = 'api-link/getSkinProfile';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userid': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            skinType = _determineSkinType(data);
            sensitivity = _determineSensitivity(data['sensitivity']);
            tone = _determineTone(data['tone']);
            acneProneness = _determineAcneProneness(data);
          });
        }
      } else {
        print('Failed to load profile data');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userid');
    if (userId != null && mounted) {
      setState(() {
        profileImagePath = prefs.getString('profileImagePath_$userId') ?? '';
      });
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null && userId != null) {
      File? croppedImage = await _cropImage(File(pickedImage.path));
      if (croppedImage != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImagePath_$userId', croppedImage.path);

        if (mounted) {
          setState(() {
            profileImagePath = croppedImage.path;
          });
        }

        widget.updateProfileImage(croppedImage
            .path); // Call the callback to update the profile image in HomeScreen
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      cropStyle: CropStyle.circle,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<void> deleteProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.remove('profileImagePath_$userId');

      if (mounted) {
        setState(() {
          profileImagePath = '';
        });
      }

      widget.updateProfileImage(
          ''); // Call the callback to update the profile image in HomeScreen
    }
  }

  String _determineSensitivity(dynamic sensitivity) {
    if (sensitivity == null) return 'Missing';
    return sensitivity == 1 ? 'Sensitive Skin' : 'Resilient Skin';
  }

  String _determineTone(dynamic tone) {
    if (tone == null) return 'Missing';
    return tone == 1 ? 'Uneven Tone' : 'Even Tone';
  }

  String _determineSkinType(Map<String, dynamic> data) {
    if (data['oily'] == 1) return 'Oily Skin';
    if (data['dry'] == 1) return 'Dry Skin';
    if (data['normal'] == 1) return 'Balanced Skin';
    if (data['combination'] == 1) return 'Combination Skin';
    return 'Missing';
  }

  String _determineAcneProneness(Map<String, dynamic> data) {
    if (data['congested'] == 1) return 'Congested Skin';
    if (data['occasional_breakout'] == 1) return 'Occasional Breakout';
    if (data['clear'] == 1) return 'Clear Skin';
    return 'Missing';
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  pickProfileImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Picture'),
                onTap: () {
                  pickProfileImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove Picture'),
                onTap: () {
                  deleteProfileImage();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showImageOptions(context),
                  child: Container(
                    padding: EdgeInsets.all(7), // Border width
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 206, 255, 227),
                          Color.fromARGB(255, 202, 208, 245),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImagePath.isEmpty
                          ? AssetImage('assets/profile_picture.jpg')
                          : FileImage(File(profileImagePath)) as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildHorizontalScrollView(
                  categories: [
                    {'name': 'Skin Type', 'value': skinType},
                    {'name': 'Sensitivity', 'value': sensitivity},
                    {'name': 'Acne Proneness', 'value': acneProneness},
                    {'name': 'Tone', 'value': tone},
                  ],
                ),
                const SizedBox(height: 20),
                _buildVerticalClickableTiles(context: context, tiles: [
                  {
                    'emoji': '☠️',
                    'title': "Ingredients banned by you",
                    'description': "Ingredients you want to stay away from",
                    'screenBuilder': BannedIngredientsScreen(
                      ingredients: widget.ingredients,
                    ),
                  },
                  {
                    'emoji': '💖',
                    'title': "Favorite ingredients",
                    'description':
                        "Ingredients you prefer to have in your products",
                    'screenBuilder': LovedIngredientsScreen(
                      ingredients: widget.ingredients,
                    ),
                  },
                  {
                    'emoji': '📝',
                    'title': "Take Skin Quiz",
                    'description':
                        "Take the skin quiz to find out what your skin profile is",
                    'screenBuilder': SkinTypeQuiz(),
                  },
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScrollView(
      {required List<Map<String, String>> categories}) {
    const double boxWidth = 140;
    const double maxFontSize = 20;
    const double lineHeight = 3;
    final List<Color> pastelColors = [
      const Color.fromARGB(80, 152, 251, 152),
      const Color.fromARGB(83, 216, 191, 216),
      const Color.fromARGB(59, 255, 217, 0),
      const Color.fromARGB(94, 173, 216, 230),
    ];

    return SizedBox(
      height: maxFontSize + lineHeight * 2 + 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.asMap().entries.map((entry) {
          final index = entry.key % pastelColors.length;
          final category = entry.value;
          final color = pastelColors[index];
          return Container(
            width: boxWidth,
            margin: const EdgeInsets.symmetric(horizontal: 10),
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
                      category['name']!,
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
                      _getEmojiForCategory(
                          category['name']!, category['value']!),
                      style: const TextStyle(
                        fontSize: 32,
                        fontFamily: 'NotoColorEmoji',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  category['value']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          );
        }).toList(),
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

  Widget _buildVerticalClickableTiles({
    required BuildContext context,
    required List<Map<String, dynamic>> tiles,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double boxWidth = (screenWidth - 40); // Adjust as needed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tiles.map((tile) {
        return InkWell(
          onTap: () {
            // Show the corresponding screen when a tile is tapped
            if (tile['screenBuilder'] is Widget Function(BuildContext)) {
              showModalBottomSheet(
                context: context,
                builder: tile['screenBuilder'],
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => tile['screenBuilder'],
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              width: boxWidth,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey), // Border similar to the image
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    tile['emoji']!, // Example emoji, change accordingly
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tile['title']!,
                          style: const TextStyle(
                            fontSize: 18,
                            color:
                                Colors.black, // Changed to black for contrast
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tile['description']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey, // Changed to grey for contrast
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAgeScreen(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: const Center(
        child: Text(
          'Age Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildMelaninLevelScreen(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: const Center(
        child: Text(
          'Melanin Level Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildSkinConcernsScreen(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: const Center(
        child: Text(
          'Skin Concerns Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
