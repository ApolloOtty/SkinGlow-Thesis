import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'detailed_ingredient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';

class DecodeScreen extends StatelessWidget {
  const DecodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const IngredientDecoder(),
    );
  }
}

class IngredientDecoder extends StatefulWidget {
  const IngredientDecoder({Key? key}) : super(key: key);

  @override
  _IngredientDecoderState createState() => _IngredientDecoderState();
}

class _IngredientDecoderState extends State<IngredientDecoder> {
  final TextEditingController _textFieldController = TextEditingController();
  List<Map<String, dynamic>> _decodeResults = [];
  int lovedIngredientCount = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  Map<String, dynamic>? _skinProfile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      await _cropImage(image);
    }
  }

  Future<void> _cropImage(File image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
    );

    if (croppedFile != null) {
      _performOcr(croppedFile.path);
    }
  }

  Future<void> _performOcr(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _textFieldController.text = recognizedText.text;
    });

    textRecognizer.close();
  }

  Future<void> _fetchSkinProfile(int userId) async {
    final response = await http.post(
      Uri.parse('api-link/getSkinProfile'),
      body: json.encode({'userid': userId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _skinProfile = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load skin profile'),
        ),
      );
    }
  }

  Future<void> _fetchDataFromAPI(String searchText) async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid') ?? 0;

    await _fetchSkinProfile(userId);

    final selectedIngredients =
        await _loadSelectedIngredientsFromServer(userId);
    final selectedLovedIngredients =
        await _loadSelectedLovedIngredientsFromServer(userId);

    final response = await http.post(
      Uri.parse('api-link/decode'),
      body: json.encode({'ingredients': searchText}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _decodeResults = data.entries.map((entry) {
          final ingredient = entry.value;
          final description = ingredient['Function'];
          final properties = <Widget>[];

          if (ingredient['oily_skin'] == 1) {
            properties.add(_buildPropertyText('🫒 Good for oily skin'));
          } else if (ingredient['oily_skin'] == 0) {
            properties.add(_buildOverlayEmoji('🫒 Bad for oily skin'));
          }

          if (ingredient['dry_skin'] == 1) {
            properties.add(_buildPropertyText('🌵 Good for dry skin'));
          } else if (ingredient['dry_skin'] == 0) {
            properties.add(_buildOverlayEmoji('🌵 Bad for dry skin'));
          }

          if (ingredient['acne_prone_skin'] == 1) {
            properties.add(_buildPropertyText('🌋 Good for acne-prone skin'));
          } else if (ingredient['acne_prone_skin'] == 0) {
            properties.add(_buildOverlayEmoji('🌋 Bad for acne-prone skin'));
          }

          if (ingredient['sensitive_skin'] == 1) {
            properties.add(_buildPropertyText('🪶 Good for sensitive skin'));
          } else if (ingredient['sensitive_skin'] == 0) {
            properties.add(_buildOverlayEmoji('🪶 Bad for sensitive skin'));
          }

          if (ingredient['anti_aging'] == 1) {
            properties.add(_buildPropertyText('⏳ Anti-Aging'));
          }

          if (ingredient['wound_heal'] == 1) {
            properties.add(_buildPropertyText('🩹 Wound Healing'));
          }

          if (ingredient['brightening'] == 1) {
            properties.add(_buildPropertyText('💎 Brightening'));
          }

          if (ingredient['antioxidant'] == 1) {
            properties.add(_buildPropertyText('🛡️ Antioxidant'));
          }

          return {
            'Name': entry.key,
            'Description': description,
            'Properties': properties,
            'Ingredient': ingredient,
          };
        }).toList();
      });

      if (selectedIngredients != null && selectedLovedIngredients != null) {
        final bannedIngredientsSet = selectedIngredients
            .map((ingredient) => ingredient.toUpperCase())
            .toSet();
        final lovedIngredientsSet = selectedLovedIngredients
            .map((ingredient) => ingredient.toUpperCase())
            .toSet();

        List<String> bannedIngredients = [];
        lovedIngredientCount = 0;

        setState(() {
          for (final ingredientData in _decodeResults) {
            final ingredientName = ingredientData['Name']?.toUpperCase();
            if (ingredientName != null) {
              if (bannedIngredientsSet.contains(ingredientName)) {
                ingredientData['isBanned'] = true;
                bannedIngredients.add(ingredientData['Name']);
              }
              if (lovedIngredientsSet.contains(ingredientName)) {
                ingredientData['isLoved'] = true;
                lovedIngredientCount++;
              }
            }
          }
        });

        if (bannedIngredients.isNotEmpty) {
          showBannedIngredientDialog(bannedIngredients);
        }
      }
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingredient not found'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load data from API'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<List<String>?> _loadSelectedIngredientsFromServer(int userId) async {
    final response = await http.get(
      Uri.parse('api-link/user/$userId/selectedBannedIngredients'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> selectedIngredients = json.decode(response.body);
      return selectedIngredients.cast<String>();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load selected ingredients'),
        ),
      );
      return null;
    }
  }

  Future<List<String>?> _loadSelectedLovedIngredientsFromServer(
      int userId) async {
    final response = await http.get(
      Uri.parse('api-link/user/$userId/selectedLovedIngredients'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> selectedLovedIngredients = json.decode(response.body);
      return selectedLovedIngredients.cast<String>();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load selected loved ingredients'),
        ),
      );
      return null;
    }
  }

  Future<void> _fetchDetailedIngredient(String ingredientName) async {
    final response = await http.get(
      Uri.parse('api-link/viewingredient/$ingredientName'),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailedIngredient(response.body),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch detailed ingredient'),
        ),
      );
    }
  }

  Future<void> showBannedIngredientDialog(List<String> ingredientNames) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Banned Ingredient Detected'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: ingredientNames.join(', '),
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ingredientNames.length > 1
                            ? ' are in your banned ingredients list!'
                            : ' is in your banned ingredients list!',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverlayEmoji(String text) {
    return Stack(
      children: [
        Text(text, style: const TextStyle(fontSize: 16)),
        Positioned(
          top: 0,
          left: 0,
          child: Text(
            '🚫',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyText(String text) {
    return Text(text, style: const TextStyle(fontSize: 16));
  }

  void _showPhotoHints(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Photo Hints'),
          content: const Text(
            '✓ Sharp\n'
            '✓ Flat surface\n'
            '✓ Straight and well cut\n'
            '✓ Latin-alphabet (no Korean / Cyrillic / etc. chars)\n\n'
            '✕ Blurred\n'
            '✕ Not flat surface\n'
            '✕ Not straight\n'
            '✕ Not cut to contain ingredients only',
          ),
          actions: <Widget>[
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
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final BoxConstraints boxConstraints = BoxConstraints(
      minWidth: screenWidth - 130,
    );

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    _showPhotoHints(context);
                  },
                  child: const Text(
                    'Take a photo of the ingredients ⓘ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Choose from Gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Take a Picture'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8.0),
                      Text('Upload'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Or',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Enter them manually',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(
                    hintText: 'Enter ingredients',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 10.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String searchText = _textFieldController.text;
                    if (searchText.isNotEmpty) {
                      _fetchDataFromAPI(searchText);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter ingredients'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.search),
                      SizedBox(width: 8.0),
                      Text('Analyze'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (lovedIngredientCount > 0)
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'We found $lovedIngredientCount loved ${lovedIngredientCount > 1 ? 'ingredients' : 'ingredient'} in this ingredients list!',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _decodeResults.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final ingredientData = _decodeResults[index];
                    final ingredientName = ingredientData['Name'];
                    final ingredientDescription = ingredientData['Description'];
                    final isBanned = ingredientData['isBanned'] ?? false;
                    final isLoved = ingredientData['isLoved'] ?? false;

                    Color textColor;
                    if (isBanned) {
                      textColor = Colors.red;
                    } else if (isLoved) {
                      textColor = const Color.fromARGB(255, 45, 185, 66);
                    } else {
                      textColor = const Color.fromARGB(255, 105, 72, 252);
                    }

                    final List<Widget> profileProperties = [];
                    final List<Widget> otherProperties = [];

                    if (_skinProfile != null) {
                      if (ingredientData['Ingredient']['oily_skin'] == 1 &&
                          _skinProfile!['oily'] == 1) {
                        profileProperties
                            .add(_buildPropertyText('🫒 Good for oily skin'));
                      } else if (ingredientData['Ingredient']['oily_skin'] ==
                              0 &&
                          _skinProfile!['oily'] == 1) {
                        profileProperties
                            .add(_buildOverlayEmoji('🫒 Bad for oily skin'));
                      }
                      if (ingredientData['Ingredient']['dry_skin'] == 1 &&
                          _skinProfile!['dry'] == 1) {
                        profileProperties
                            .add(_buildPropertyText('🌵 Good for dry skin'));
                      } else if (ingredientData['Ingredient']['dry_skin'] ==
                              0 &&
                          _skinProfile!['dry'] == 1) {
                        profileProperties
                            .add(_buildOverlayEmoji('🌵 Bad for dry skin'));
                      }

                      if (ingredientData['Ingredient']['acne_prone_skin'] ==
                              1 &&
                          (_skinProfile!['occasional_breakout'] == 1 ||
                              _skinProfile!['congested'] == 1)) {
                        profileProperties.add(
                            _buildPropertyText('🌋 Good for acne-prone skin'));
                      } else if (ingredientData['Ingredient']
                                  ['acne_prone_skin'] ==
                              0 &&
                          (_skinProfile!['occasional_breakout'] == 1 ||
                              _skinProfile!['congested'] == 1)) {
                        profileProperties.add(
                            _buildOverlayEmoji('🌋 Bad for acne-prone skin'));
                      }
                      if (ingredientData['Ingredient']['sensitive_skin'] == 1 &&
                          _skinProfile!['sensitivity'] == 1) {
                        profileProperties.add(
                            _buildPropertyText('🪶 Good for sensitive skin'));
                      } else if (ingredientData['Ingredient']
                                  ['sensitive_skin'] ==
                              0 &&
                          _skinProfile!['sensitivity'] == 1) {
                        profileProperties.add(
                            _buildOverlayEmoji('🪶 Bad for sensitive skin'));
                      }
                      if (ingredientData['Ingredient']['brightening'] == 1 &&
                          _skinProfile!['tone'] == 1) {
                        profileProperties
                            .add(_buildPropertyText('💎 Brightening'));
                      }
                    }

                    for (var property in ingredientData['Properties']) {
                      if (!_isPropertyInProfile(property)) {
                        otherProperties.add(property);
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        _fetchDetailedIngredient(ingredientName);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredientName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "$ingredientDescription",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 84, 84, 84),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (profileProperties.isNotEmpty)
                                ConstrainedBox(
                                  constraints: boxConstraints,
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Based on your skin profile:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        ...profileProperties,
                                      ],
                                    ),
                                  ),
                                ),
                              if (otherProperties.isNotEmpty)
                                const SizedBox(height: 10),
                              if (otherProperties.isNotEmpty)
                                ConstrainedBox(
                                  constraints: boxConstraints,
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(133, 222, 222, 222),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: otherProperties,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  bool _isPropertyInProfile(Widget property) {
    if (_skinProfile == null) return false;

    String propertyText;
    if (property is Text) {
      propertyText = property.data ?? '';
    } else if (property is Stack &&
        property.children.isNotEmpty &&
        property.children[0] is Text) {
      propertyText = (property.children[0] as Text).data ?? '';
    } else {
      return false;
    }

    if (propertyText.contains('Good for oily skin') &&
        _skinProfile!['oily'] == 1) return true;
    if (propertyText.contains('Bad for oily skin') &&
        _skinProfile!['oily'] == 1) return true;
    if (propertyText.contains('Good for dry skin') && _skinProfile!['dry'] == 1)
      return true;
    if (propertyText.contains('Bad for dry skin') && _skinProfile!['dry'] == 1)
      return true;
    if (propertyText.contains('Good for acne-prone skin') &&
        (_skinProfile!['occasional_breakout'] == 1 ||
            _skinProfile!['congested'] == 1)) return true;
    if (propertyText.contains('Bad for acne-prone skin') &&
        (_skinProfile!['occasional_breakout'] == 1 ||
            _skinProfile!['congested'] == 1)) return true;
    if (propertyText.contains('Good for sensitive skin') &&
        _skinProfile!['sensitivity'] == 1) return true;
    if (propertyText.contains('Bad for sensitive skin') &&
        _skinProfile!['sensitivity'] == 1) return true;
    if (propertyText.contains('Brightening') && _skinProfile!['tone'] == 1)
      return true;

    return false;
  }

  bool _hasSkinProfileData() {
    if (_skinProfile == null) return false;
    return _skinProfile!.values.any((value) => value != null);
  }

  bool _shouldShowSkinProfile(Map<String, dynamic> ingredientData) {
    if (_skinProfile == null || !_hasSkinProfileData()) return false;

    final ingredient = ingredientData['Ingredient'];
    if (ingredient['oily_skin'] != null ||
        ingredient['dry_skin'] != null ||
        ingredient['acne_prone_skin'] != null ||
        ingredient['sensitive_skin'] != null ||
        ingredient['anti_aging'] != null ||
        ingredient['wound_heal'] != null ||
        ingredient['brightening'] != null ||
        ingredient['antioxidant'] != null) {
      return true;
    }
    return false;
  }
}
