import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: TabBar(
                splashFactory: NoSplash.splashFactory,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide.none,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                      icon: Transform.scale(
                          scale: 0.7, child: const Icon(Icons.circle))),
                  Tab(
                      icon: Transform.scale(
                          scale: 0.7, child: const Icon(Icons.circle))),
                  Tab(
                      icon: Transform.scale(
                          scale: 0.7, child: const Icon(Icons.circle))),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Builder(
              builder: (BuildContext context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Get to know your skin',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Discover your unique skin profile and learn targeted solutions to achieve optimal skin health',
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (BuildContext context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Decode your ingredients list',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Are your products friends or foes? Scan them now to find your perfect matches, learn about your ingredients and identify the culprits behind your skin problems',
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(2);
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (BuildContext context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Welcome to SkinGlow',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Start your skincare journey! ',
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Get the screen width
                      double screenWidth = MediaQuery.of(context).size.width;
                      // Calculate the desired button width
                      double buttonWidth = screenWidth / 1.3;
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 200.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    const Text('New to SkinGlow?'),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the bottom sheet
                                        Navigator.pushNamed(
                                            context, '/register');
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                                Size(buttonWidth, 40)),
                                      ),
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .white), // Set the text color to white
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15.0),
                                Column(
                                  children: <Widget>[
                                    const Text('Already registered?'),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the bottom sheet
                                        Navigator.pushNamed(context, '/login');
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color.fromARGB(
                                                    255, 145, 111, 239)),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                                Size(buttonWidth, 40)),
                                      ),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .white), // Set the text color to white
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Continue with Email'),
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
