import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'animated_positioned_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    final String email = emailController.text;
    final String password = passwordController.text;
    print(email);
    print(password);
    const String registerUrl = 'api-link/login';

    try {
      final response = await http.post(Uri.parse(registerUrl),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
          body: json.encode({'email': email, 'password': password}));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userId = data['userid']; // Assuming the server returns userId

        // Save user ID to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('userid', userId);

        // Remove all previous routes and navigate to the home screen
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fundalTare.png'),
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                    Colors.white
                        .withOpacity(0.9), // Adjust the opacity value as needed
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  AnimatedPositionedWidget(
                    left: 30,
                    width: 80,
                    height: 200,
                    imagePath: 'assets/images/bec-1.png',
                    index: 1,
                  ),
                  AnimatedPositionedWidget(
                    left: 230,
                    width: 80,
                    height: 150,
                    imagePath: 'assets/images/bec-2.png',
                    index: 2,
                  ),
                  Positioned(
                    top: 170,
                    left: 0,
                    right: 0,
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1600),
                      child: Center(
                        child: Text(
                          "Login",
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
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              obscureText: true,
                              controller: passwordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1900),
                    child: InkWell(
                      onTap: _login,
                      splashColor: Colors.transparent,
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
                        child: Center(
                          child: Text(
                            "Login",
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
                    height: 70,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//inspired by https://github.com/afgprogrammer/Flutter-Login-Page-UI/tree/master