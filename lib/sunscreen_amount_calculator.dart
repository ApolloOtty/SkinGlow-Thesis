import 'package:flutter/material.dart';
import 'dart:math'; // Importing dart:math for the pow function

class SunscreenAmountPage extends StatefulWidget {
  const SunscreenAmountPage({super.key});

  @override
  _SunscreenAmountPageState createState() => _SunscreenAmountPageState();
}

class _SunscreenAmountPageState extends State<SunscreenAmountPage> {
  bool calculateForBody = true;
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController faceLengthController = TextEditingController();
  TextEditingController faceWidthController = TextEditingController();
  String sleeveType = "No Shirt";
  String pantsType = "No Pants";
  String footwearType = "No Shoes";
  bool wearingHat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunscreen Amount'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Sunscreen Amount Calculator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          calculateForBody = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: calculateForBody ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Body',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          calculateForBody = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: !calculateForBody ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Face',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (calculateForBody) ...[
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Height (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        const Text(
                          'Clothing Details:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text('Shirt:'),
                        DropdownButton<String>(
                          value: sleeveType,
                          onChanged: (String? newValue) {
                            setState(() {
                              sleeveType = newValue!;
                            });
                          },
                          items: <String>[
                            'No Shirt',
                            'Long sleeves',
                            'Short sleeves',
                            'Sleeveless'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        const Text('Pants:'),
                        DropdownButton<String>(
                          value: pantsType,
                          onChanged: (String? newValue) {
                            setState(() {
                              pantsType = newValue!;
                            });
                          },
                          items: <String>[
                            'No Pants',
                            'Long pants',
                            'Short pants'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        const Text('Footwear:'),
                        DropdownButton<String>(
                          value: footwearType,
                          onChanged: (String? newValue) {
                            setState(() {
                              footwearType = newValue!;
                            });
                          },
                          items: <String>['No Shoes', 'Shoes', 'Flip flops']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          title: const Text("Wearing a hat"),
                          value: wearingHat,
                          onChanged: (bool? value) {
                            setState(() {
                              wearingHat = value!;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: calculateSunscreenAmount,
                          child: const Text('Calculate Sunscreen Amount'),
                        ),
                      ],
                    ),
                  )
                ] else ...[
                  TextField(
                    controller: faceLengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Face Length (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: faceWidthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Face Width (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: calculateSunscreenAmount,
                      child: const Text('Calculate Sunscreen Amount'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/images/face_measurement_guide.png',
                      width: 300,
                      height: 300,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void calculateSunscreenAmount() {
    double amount = 0;
    if (calculateForBody) {
      double? height = double.tryParse(heightController.text);
      double? weight = double.tryParse(weightController.text);
      if (height == null || weight == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('Please enter valid height and weight values.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      double bodySurfaceArea =
          0.007184 * pow(height, 0.725) * pow(weight, 0.425);
      amount = bodySurfaceArea * 20; // 2mg/cm² and convert to ml

      // Adjust amount based on clothing
      double exposedBodyPercentage = 1.0; // Assume fully exposed initially
      amount *= (exposedBodyPercentage - 0.03);
      if (sleeveType == "Long sleeves") {
        exposedBodyPercentage -= 0.38; // Assume 38% covered
      } else if (sleeveType == "Short sleeves") {
        exposedBodyPercentage -= 0.32; // Assume 32% covered
      } else if (sleeveType == "Sleeveless") {
        exposedBodyPercentage -= 0.26; // Assume 35% covered
      }

      if (pantsType == "Long pants") {
        exposedBodyPercentage -= 0.21; // Assume 21% covered
      }

      if (pantsType == "Short pants") {
        exposedBodyPercentage -= 0.15; // Assume 15% covered
      }

      if (footwearType == "Shoes") {
        exposedBodyPercentage -= 0.03; // Assume 3% covered
      }

      if (footwearType == "Flip flops") {
        exposedBodyPercentage -= 0.015; // Assume 1.5% covered
      }

      if (wearingHat) {
        exposedBodyPercentage -= 0.02; // Assume 2% covered
      }
      amount *= exposedBodyPercentage;
    } else {
      double? faceLength = double.tryParse(faceLengthController.text);
      double? faceWidth = double.tryParse(faceWidthController.text);
      if (faceLength == null || faceWidth == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Input'),
            content:
                const Text('Please enter valid face length and width values.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      double faceArea = (faceLength / 2) * (faceWidth / 2) * pi;
      amount = faceArea * 2; // 2mg/cm² for face in mg
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sunscreen Amount'),
        content: Text(
            'You need approximately ${amount.toStringAsFixed(0)} ${calculateForBody ? "ml" : "mg"} of sunscreen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
