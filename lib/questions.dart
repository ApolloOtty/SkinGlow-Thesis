// questions.dart

class Question {
  final String questionText;
  final List<String> options;

  const Question({required this.questionText, required this.options});
}

final List<Question> questions = [
  // Skin Type Questions
  const Question(
    questionText:
        'You washed your face and did not apply any skincare after. It\'s been a few minutes to an hour, how does your face feel?',
    options: [
      'It feels tight',
      'It\'s shiny',
      'Shiny in T-Zone',
      'Feels normal'
    ],
  ),
  const Question(
    questionText: 'Do you wake up with shine all over your face?',
    options: [
      'Yes',
      'No',
      'The opposite, it looks dry',
      'Only in "T-Zone" (nose and forehead)'
    ],
  ),
  const Question(
    questionText: 'How does your skin feel at the end of the day?',
    options: ['Oily all around', 'Oily in T-zone', 'Dry', 'Normal'],
  ),
  // Sensitivity Questions
  const Question(
    questionText:
        'Does your skin often burn or itch after applying skincare products?',
    options: [
      'Very often',
      'Only sometimes',
      'Never',
    ],
  ),
  const Question(
    questionText:
        'Does your skin get red and/or irritated from products that have fragrance?',
    options: ['Frequently', 'Rarely', 'No or I don\'t know'],
  ),
  // Acne Proneness Questions
  const Question(
    questionText:
        'How many new whiteheads or bumps do you notice on your face on a weekly basis?',
    options: [
      'None',
      'Less than five per week',
      'More than five per week',
      'More than five inflamed and painful bumps per week'
    ],
  ),
  const Question(
    questionText: 'Do you often get new pimples after wearing sunscreen?',
    options: ['Yes', 'No', 'Sometimes', 'Never'],
  ),
  const Question(
    questionText: 'Do you notice a lot of black dots on your face?',
    options: ['Yes', 'No'],
  ),
  // Tone Questions
  const Question(
    questionText: 'Do you have dark under-eye circles?',
    options: [
      'Yes, they move with the skin if I stretch or move it',
      'Yes, they do not move with the skin if I stretch or move it',
      'No'
    ],
  ),
  const Question(
    questionText: 'is your skin tone the same in all parts of your face?',
    options: [
      'Yes',
      'It is not exactly the same in ALL parts of my face',
      'I have redness in some parts',
      'It is uneven'
    ],
  ),
  const Question(
    questionText:
        'Does your skin appear darker in the spots where you had pimples in the past?',
    options: ['Yes', 'No', 'I don\'t know'],
  ),
];
