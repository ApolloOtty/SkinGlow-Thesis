import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NameAndAgeScreen extends StatefulWidget {
  const NameAndAgeScreen({super.key});

  @override
  _NameAndAgeScreenState createState() => _NameAndAgeScreenState();
}

class _NameAndAgeScreenState extends State<NameAndAgeScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      print('Selected date: $_selectedDate');
    }
  }

  String _calculateAge() {
    if (_selectedDate != null) {
      final now = DateTime.now();
      int age = now.year - _selectedDate!.year;
      if (now.month < _selectedDate!.month ||
          (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
        age--;
      }
      return age.toString();
    }
    return '';
  }

  String _calculateSkinRenewals() {
    if (_selectedDate != null) {
      final now = DateTime.now();
      final age = now.year - _selectedDate!.year;
      // Average skin renewal rate: every 28 days
      final skinRenewals = (age * 365 / 28).floor();
      return skinRenewals.toString();
    }
    return '';
  }

  Future<void> _sendData() async {
    if (_selectedDate != null) {
      String name = _nameController.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userid');

      try {
        var urlName = Uri.parse('api-link/postname');
        var responseName = await http.post(
          urlName,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': name,
            'userid': userId.toString(),
          }),
        );

        if (responseName.statusCode == 200) {
          print('Name sent successfully!');
          // Continue to send date of birth
          try {
            var urlDob = Uri.parse('api-link/postdob');
            var responseDob = await http.post(
              urlDob,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'dob': _selectedDate!.toString(),
                'userid': userId.toString(),
              }),
            );

            if (responseDob.statusCode == 200) {
              print('Date of birth sent successfully!');
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              // Navigate to the next screen or perform any other action
            } else {
              print('Failed to send date of birth: ${responseDob.statusCode}');
              // Handle error, if needed
            }
          } catch (e) {
            print('Error sending date of birth: $e');
            // Handle error, if needed
          }
        } else {
          print('Failed to send name: ${responseName.statusCode}');
          // Handle error, if needed
        }
      } catch (e) {
        print('Error sending name: $e');
        // Handle error, if needed
      }
    }
  }

  Widget _buildDateInput(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        width:
            MediaQuery.of(context).size.width, // Match the width of the screen
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Text(
          _selectedDate == null
              ? 'Select your birthday'
              : 'Selected date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          style: TextStyle(
            fontSize: 18.0,
            color: _selectedDate == null ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name and Birthday'),
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to SkinGlow!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  labelStyle: const TextStyle(
                    color: Colors.deepPurple,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20.0),
              _buildDateInput(context),
              const SizedBox(height: 10),
              if (_selectedDate != null) ...[
                Text(
                  'You are ${_calculateAge()} years old! 🎉',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                Text(
                  'That means your skin has renewed itself approximately ${_calculateSkinRenewals()} times 🤯',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendData,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
