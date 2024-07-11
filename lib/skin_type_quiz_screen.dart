import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'questions.dart';
import 'questions_result_screen.dart';

class SkinTypeQuiz extends StatefulWidget {
  const SkinTypeQuiz({Key? key}) : super(key: key);

  @override
  _SkinTypeQuizState createState() => _SkinTypeQuizState();
}

class _SkinTypeQuizState extends State<SkinTypeQuiz> {
  int currentQuestionIndex = 0;
  Map<int, int> answers = {}; // To store the selected option for each question
  bool showSectionResult = false;
  String sectionResult = '';
  String sectionDescription = '';
  Map<String, String> sectionResults = {};

  void nextQuestion(int selectedIndex) {
    setState(() {
      answers[currentQuestionIndex] = selectedIndex;
      if ((currentQuestionIndex == 2) ||
          (currentQuestionIndex == 4) ||
          (currentQuestionIndex == 7) ||
          (currentQuestionIndex == 10)) {
        // End of section
        sectionResult = determineSectionResult(currentQuestionIndex);
        sectionDescription = getSectionDescription(sectionResult);
        showSectionResult = true;
        sectionResults[getSectionName(currentQuestionIndex)] = sectionResult;
      } else if (currentQuestionIndex == questions.length - 1) {
        // Last question, show final result
        sectionResult = determineFinalResult();
        sectionResults[getSectionName(currentQuestionIndex)] = sectionResult;
        navigateToResultsPage();
        saveResultsToDatabase(); // Save results to the database
      } else {
        currentQuestionIndex++;
      }
    });
  }

  void continueQuiz() {
    setState(() {
      showSectionResult = false;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        navigateToResultsPage();
        saveResultsToDatabase(); // Save results to the database
      }
    });
  }

  void navigateToResultsPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultsPage(sectionResults: sectionResults),
      ),
    );
  }

  Future<void> saveResultsToDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid');
    if (userId != null) {
      const url = 'api-link/updateSkinProfile';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'oily': sectionResults['Skin Type'] == 'Oily Skin',
          'dry': sectionResults['Skin Type'] == 'Dry Skin',
          'normal': sectionResults['Skin Type'] == 'Balanced Skin',
          'combination': sectionResults['Skin Type'] == 'Combination Skin',
          'sensitivity': sectionResults['Sensitivity'] == 'Sensitive Skin',
          'tone': sectionResults['Tone'] == 'Uneven Tone',
          'occasional_breakout':
              sectionResults['Acne Proneness'] == 'Occasional Breakout',
          'congested': sectionResults['Acne Proneness'] == 'Congested Skin',
          'clear': sectionResults['Acne Proneness'] == 'Clear Skin',
          'userid': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Skin profile updated successfully in the database.');
      } else {
        print('Failed to update skin profile: ${response.body}');
      }
    } else {
      print('User ID not found in SharedPreferences.');
    }
  }

  String getSectionName(int index) {
    if (index <= 2) {
      return 'Skin Type';
    } else if (index <= 4) {
      return 'Sensitivity';
    } else if (index <= 7) {
      return 'Acne Proneness';
    } else {
      return 'Tone';
    }
  }

  String determineSectionResult(int currentIndex) {
    int sectionStartIndex;
    int sectionEndIndex;

    // Determine the start and end indices for each section
    if (currentIndex <= 2) {
      sectionStartIndex = 0;
      sectionEndIndex = 3;
    } else if (currentIndex <= 4) {
      sectionStartIndex = 3;
      sectionEndIndex = 5;
    } else if (currentIndex <= 7) {
      sectionStartIndex = 5;
      sectionEndIndex = 8;
    } else {
      sectionStartIndex = 8;
      sectionEndIndex = 11;
    }

    int count1 = 0;
    int count2 = 0;
    int count3 = 0;
    int count4 = 0;

    for (int i = sectionStartIndex; i < sectionEndIndex; i++) {
      if (answers.containsKey(i)) {
        int value = answers[i]!;
        switch (getSectionName(i)) {
          case 'Skin Type':
            if (questions[i].options[value] == 'It feels tight' ||
                questions[i].options[value] == 'The opposite, it looks dry' ||
                questions[i].options[value] == 'Dry') {
              count1++;
            } else if (questions[i].options[value] == 'It\'s shiny' ||
                questions[i].options[value] == 'Oily all around') {
              count2++;
            } else if (questions[i].options[value] == 'Shiny in T-Zone' ||
                questions[i].options[value] == 'Oily in T-zone') {
              count3++;
            } else if (questions[i].options[value] == 'Feels normal' ||
                questions[i].options[value] == 'Normal') {
              count4++;
            }
            break;
          case 'Sensitivity':
            if (questions[i].options[value] == 'Very often' ||
                questions[i].options[value] == 'Frequently') {
              count1++;
            } else {
              count2++;
            }
            break;

          case 'Acne Proneness':
            if (questions[i].options[value] ==
                    'More than five inflamed and painful bumps per week' ||
                questions[i].options[value] == 'More than five per week') {
              count1++; // High acne proneness (Congested Skin)
            } else if (questions[i].options[value] ==
                    'Less than five per week' ||
                questions[i].options[value] == 'Sometimes') {
              count2++; // Moderate acne proneness (Occasional Breakout)
            } else if (questions[i].options[value] == 'None' ||
                questions[i].options[value] == 'No' ||
                questions[i].options[value] == 'Never') {
              count3++; // Low acne proneness (Clear Skin)
            } else if (currentIndex == 6 || currentIndex == 7) {
              if (questions[i].options[value] == 'Yes') count1++;
            } else
              count4++; // Default or unknown
            break;

          case 'Tone':
            if (questions[i].options[value] ==
                    'Yes, they move with the skin if I stretch or move it' ||
                questions[i].options[value] == 'It is uneven' ||
                questions[i].options[value] ==
                    'It is not exactly the same in ALL parts of my face' ||
                questions[i].options[value] == 'I have redness in some parts') {
              count1++;
            } else if (currentIndex == 9 ||
                currentIndex == 10) if (questions[i].options[value] == 'Yes') {
              count1++;
            } else {
              count2++;
            }
            break;
        }
      }
    }

    switch (getSectionName(sectionStartIndex)) {
      case 'Skin Type':
        if (count2 > count1 && count2 > count3 && count2 > count4) {
          return 'Oily Skin';
        } else if (count1 > count2 && count1 > count3 && count1 > count4) {
          return 'Dry Skin';
        } else if (count3 > count2 && count3 > count1 && count3 > count4) {
          return 'Combination Skin';
        } else {
          return 'Balanced Skin';
        }
      case 'Sensitivity':
        if (count1 > count2) {
          return 'Sensitive Skin';
        } else {
          return 'Resilient Skin';
        }
      case 'Acne Proneness':
        if (count1 >= count2 && count1 >= count3 && count1 >= count4) {
          return 'Congested Skin';
        } else if (count2 >= count1 && count2 >= count3 && count2 >= count4) {
          return 'Occasional Breakout';
        } else {
          return 'Clear Skin';
        }
      case 'Tone':
        if (count1 > count2) {
          return 'Uneven Tone';
        } else {
          return 'Even Tone';
        }
      default:
        return '';
    }
  }

  String determineFinalResult() {
    Map<String, bool> finalResults = {
      'oily': sectionResults['Skin Type'] == 'Oily Skin',
      'dry': sectionResults['Skin Type'] == 'Dry Skin',
      'normal': sectionResults['Skin Type'] == 'Balanced Skin',
      'combination': sectionResults['Skin Type'] == 'Combination Skin',
      'sensitivity': sectionResults['Sensitivity'] == 'Sensitive Skin',
      'tone': sectionResults['Tone'] == 'Uneven Tone',
      'occasional_breakout':
          sectionResults['Acne Proneness'] == 'Occasional Breakout',
      'congested': sectionResults['Acne Proneness'] == 'Congested Skin',
      'clear': sectionResults['Acne Proneness'] == 'Clear Skin',
    };

    return finalResults.toString();
  }

  String getSectionDescription(String result) {
    switch (result) {
      case 'Dry Skin':
        return 'Dry skin can feel tight and rough and may have flaky patches. It is prone to irritation and may appear dull. Proper hydration and moisturizing are key to managing dry skin.';
      case 'Oily Skin':
        return 'Oily skin tends to have enlarged pores and a shiny complexion. It is more prone to acne and blackheads. Regular cleansing and using non-comedogenic products can help manage oiliness.';
      case 'Combination Skin':
        return 'Combination skin features both dry and oily areas. Typically, the T-zone (forehead, nose, and chin) is oily, while the cheeks are dry. Balanced skincare routines can help address the different needs of combination skin.';
      case 'Balanced Skin':
        return 'Balanced skin feels neither too dry nor too oily. It has a smooth texture with minimal imperfections. Maintaining this balance involves using gentle skincare products and staying hydrated.';
      case 'Sensitive Skin':
        return 'Sensitive skin is prone to irritation and reactions from various products and environmental factors. It is important to use gentle, hypoallergenic skincare products.';
      case 'Resilient Skin':
        return 'Resilient skin rarely reacts to products or environmental factors. It is generally low-maintenance but still requires proper care to maintain its health.';
      case 'Congested Skin':
        return 'Congested skin is prone to frequent breakouts, blackheads, and clogged pores. A regular cleansing routine and using products with salicylic acid can help manage congestion.';
      case 'Clear Skin':
        return 'Clear skin rarely experiences breakouts and has minimal blemishes. Maintaining a consistent skincare routine can help keep the skin clear.';
      case 'Occasional Breakout':
        return 'Skin with occasional breakouts experiences pimples or acne infrequently. Using gentle products and avoiding harsh treatments can help manage these occasional issues.';
      case 'Even Tone':
        return 'Even tone skin has a uniform color and texture. It is important to maintain this balance with regular exfoliation and using products that support skin health.';
      case 'Uneven Tone':
        return 'Uneven tone skin may have dark spots, redness, or other discoloration. Using products with ingredients like vitamin C or niacinamide can help improve the skin tone.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Type Quiz'),
        backgroundColor: Color.fromARGB(255, 230, 252, 239),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 230, 252, 239),
                  Color.fromARGB(255, 234, 236, 249),
                  Color.fromARGB(255, 230, 235, 254)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          showSectionResult
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Result',
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '$sectionResult',
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          sectionDescription,
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: continueQuiz,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              questions[currentQuestionIndex].questionText,
                              style: const TextStyle(fontSize: 18.0),
                            ),
                            const SizedBox(height: 20),
                            ...questions[currentQuestionIndex]
                                .options
                                .asMap()
                                .entries
                                .map((entry) {
                              int idx = entry.key;
                              String text = entry.value;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () => nextQuestion(idx),
                                child: Text(text),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ProgressIndicator(
                          currentQuestionIndex: currentQuestionIndex),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  final int currentQuestionIndex;

  const ProgressIndicator({required this.currentQuestionIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircle(
          context,
          'Skin Type',
          currentQuestionIndex < 3,
          currentQuestionIndex >= 3,
          1,
        ),
        _buildCircle(
          context,
          'Sensitivity',
          currentQuestionIndex >= 3 && currentQuestionIndex < 5,
          currentQuestionIndex >= 5,
          2,
        ),
        _buildCircle(
          context,
          'Acne Proneness',
          currentQuestionIndex >= 5 && currentQuestionIndex < 8,
          currentQuestionIndex >= 8,
          3,
        ),
        _buildCircle(
          context,
          'Tone',
          currentQuestionIndex >= 8,
          false,
          4,
        ),
      ],
    );
  }

  Widget _buildCircle(BuildContext context, String label, bool isActive,
      bool isCompleted, int number) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? Color.fromARGB(255, 35, 197, 94)
                  : isActive
                      ? Color.fromARGB(255, 86, 165, 118)
                      : Color.fromARGB(255, 240, 253, 244),
              width: 2.0,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: isCompleted
                ? Color.fromARGB(255, 35, 197, 94)
                : Color.fromARGB(255, 240, 253, 244),
            radius: 10.0,
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isCompleted
                    ? Colors.white
                    : isActive
                        ? Colors.black
                        : Color.fromARGB(145, 84, 84, 84),
                fontSize: 12.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color.fromARGB(255, 84, 84, 84),
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }
}
