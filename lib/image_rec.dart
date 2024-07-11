import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  List<File> _images = [];
  double? _probabilityMelanoma;
  double? _probabilityMole;
  bool _isProcessing = false;
  bool _disclaimerAccepted = false;
  bool _evaluationDone = false;
  String _loadingText = 'Evaluating the image...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimer();
    });
  }

  Future<void> _showDisclaimer() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disclaimer'),
          content: const Text(
            'This application is for demonstration purposes only. The predictions provided by the model are not guaranteed to be accurate. It is not a substitute for professional medical advice, diagnosis, or treatment. Please consult a qualified healthcare provider if you have any concerns or questions about your health.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _disclaimerAccepted = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _images.add(File(pickedImage.path));
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) {
      print('No image taken.');
      return;
    }

    final imageFile = File(pickedImage.path);

    setState(() {
      _images.add(imageFile);
    });
  }

  Future<void> _sendImagesToBackend() async {
    setState(() {
      _isProcessing = true;
      _loadingText = 'Evaluating the image...';
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('api-link/evalimage'),
    );

    for (var image in _images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
        ),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(await response.stream.bytesToString());

      setState(() {
        _loadingText = 'Deleting the image from the server...';
      });

      // Simulate a delay for deleting the image from the server
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _probabilityMelanoma = data['probability_melanoma'];
        _probabilityMole = data['probability_mole'];
        _isProcessing = false;
        _evaluationDone = true;
      });
    } else {
      setState(() {
        _isProcessing = false;
      });
      print('Failed to upload images. Error: ${response.reasonPhrase}');
    }
  }

  void _resetScreen() {
    setState(() {
      _images.clear();
      _probabilityMelanoma = null;
      _probabilityMole = null;
      _evaluationDone = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.upload_file, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Upload Pictures of a Mole',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _disclaimerAccepted
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (_images.isEmpty)
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                children: const [
                                  Icon(Icons.info,
                                      color: Colors.green, size: 30),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'To get an evaluation by the model, please upload clear pictures of the mole.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: const [
                                  Icon(Icons.gps_fixed,
                                      color: Colors.orange, size: 30),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'For better accuracy, you can upload multiple pictures of the same mole from different angles.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _images.map((image) {
                            return Stack(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: FileImage(image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (!_evaluationDone)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _images.remove(image);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        if (_probabilityMelanoma != null &&
                            _probabilityMole != null)
                          Column(
                            children: [
                              Text(
                                'Probability of melanoma: ${(_probabilityMelanoma! * 100).toStringAsFixed(2)}%\n'
                                'Probability of mole: ${(_probabilityMole! * 100).toStringAsFixed(2)}%',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'The model predicts the image is ${(_probabilityMelanoma! > _probabilityMole!) ? "melanoma" : "a mole"}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Disclaimer: This is not a medical device. Please consult a doctor for a proper diagnosis.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        if (!_evaluationDone)
                          Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _getImageFromGallery,
                                icon: const Icon(Icons.image),
                                label: const Text('Choose from Gallery'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(200, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _takePicture,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Take a Picture'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(200, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        if (_images.isNotEmpty && !_evaluationDone)
                          ElevatedButton.icon(
                            onPressed: _sendImagesToBackend,
                            icon: const Icon(Icons.send),
                            label: const Text('Send Images for Evaluation'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        if (_evaluationDone)
                          ElevatedButton.icon(
                            onPressed: _resetScreen,
                            icon: const Icon(Icons.refresh),
                            label: const Text('New Scan'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    _showDisclaimer();
                  },
                  child: const Center(
                    child: Text(
                      'Tap here to read the disclaimer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      _loadingText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
