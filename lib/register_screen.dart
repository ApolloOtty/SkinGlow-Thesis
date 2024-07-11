import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'animated_positioned_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool passwordsMatch = false;
  bool isEmailValid = true;
  bool isPasswordValid = false;

  Future<void> _register() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    const String registerUrl = 'api-link/register';

    try {
      final response = await http.post(Uri.parse(registerUrl),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
          body: json.encode({'email': email, 'password': password}));
      print(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userId = data['userid']; // Assuming the server returns userId

        // Save user ID to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('userid', userId);

        // Registration successful, handle the response accordingly
        print('Registration successful');
        Navigator.pushNamedAndRemoveUntil(context, '/name', (route) => false);
      } else {
        // Registration failed, handle the response accordingly
        print('Registration failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Error occurred during registration, handle the error
      print('Error during registration: $e');
    }
  }

  void _validateEmail(String email) {
    setState(() {
      isEmailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email);
    });
  }

  void _validatePassword(String password) {
    setState(() {
      isPasswordValid = password.length >= 6;
      passwordsMatch = password == confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/fundalTare.png'),
                        fit: BoxFit.fill,
                        colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(
                              0.9), // Adjust the opacity value as needed
                          BlendMode.dstATop,
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositionedWidget(
                    left: 30,
                    width: 80,
                    height: 200,
                    imagePath: 'assets/images/bec-1.png',
                    index: 1,
                  ),
                  AnimatedPositionedWidget(
                    left: 250,
                    width: 80,
                    height: 150,
                    imagePath: 'assets/images/bec-2.png',
                    index: 2,
                  ),
                  Positioned(
                    top: 200,
                    left: 0,
                    right: 0,
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1600),
                      child: Center(
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 1800),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color.fromRGBO(143, 148, 251, 1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, .2),
                              blurRadius: 20.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromRGBO(143, 148, 251, 1),
                                  ),
                                ),
                              ),
                              child: TextField(
                                controller: emailController,
                                onChanged: (value) {
                                  _validateEmail(value);
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  errorText: isEmailValid
                                      ? null
                                      : 'Invalid email format',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                obscureText: true,
                                controller: passwordController,
                                onChanged: (value) {
                                  _validatePassword(value);
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  errorText: isPasswordValid
                                      ? null
                                      : 'Password must be at least 6 characters',
                                ),
                              ),
                            ),
                            const Divider(
                              color: Color.fromRGBO(143, 148, 251, 1),
                            ), // Add a divider
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                obscureText: true,
                                controller: confirmPasswordController,
                                onChanged: (value) {
                                  setState(() {
                                    passwordsMatch =
                                        value == passwordController.text;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed:
                              passwordsMatch && isEmailValid && isPasswordValid
                                  ? _register
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor:
                                Colors.transparent, // Remove the shadow color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
