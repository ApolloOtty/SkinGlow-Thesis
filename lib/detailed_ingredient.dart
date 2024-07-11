import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DetailedIngredient extends StatelessWidget {
  final String ingredientDescription;

  const DetailedIngredient(this.ingredientDescription, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Ingredient'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (ingredientDescription.contains('<') &&
        ingredientDescription.contains('>')) {
      // Render HTML content
      return Html(
        data: ingredientDescription,
        style: {
          "body": Style(
            fontSize: FontSize(16.0),
          ),
        },
      );
    } else {
      // Render plain text
      return Text(
        ingredientDescription,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
      );
    }
  }
}
