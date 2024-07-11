import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'sunscreen_amount_calculator.dart';
import 'uv_index_graph.dart'; // Import the custom widget

class UVIndexPage extends StatefulWidget {
  final double uvIndex;
  final String cityName;

  const UVIndexPage({Key? key, required this.uvIndex, required this.cityName})
      : super(key: key);

  @override
  _UVIndexPageState createState() => _UVIndexPageState();
}

class _UVIndexPageState extends State<UVIndexPage> {
  int selectedSkinTone = 0;
  TextEditingController spfController = TextEditingController();
  bool notificationEnabled = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<Color> skinTones = [
    const Color(0xFFEDD0A5),
    const Color(0xFFD6A17D),
    const Color(0xFFB47A52),
    const Color(0xFF955539),
    const Color(0xFF713D25),
    const Color(0xFF4E2918),
  ];

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
      if (response.payload == 'reapply_no') {
        // Resend the notification in 5 minutes
        scheduleNotification(0, 1);
      }
    });
    tz.initializeTimeZones();
    requestExactAlarmPermission();
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              ),
              child: Container(
                width: double.infinity,
                color: Color.fromARGB(255, 47, 167, 241),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    _buildCityName(),
                    const SizedBox(height: 70),
                    _buildUVIndexGraph(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSkinToneSelector(),
                  const SizedBox(height: 20),
                  _buildSPFInput(),
                  const SizedBox(height: 20),
                  _buildNotificationSwitch(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildReminderText(),
                  const SizedBox(height: 20),
                  _buildSunscreenCalculatorButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityName() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_city,
            color: Colors.white,
            size: 24.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            widget.cityName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUVIndexGraph() {
    return Center(
      child: UVIndexGraph(uvIndex: widget.uvIndex),
    );
  }

  Widget _buildSkinToneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Skin Tone:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            skinTones.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedSkinTone = index;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: skinTones[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedSkinTone == index
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSPFInput() {
    return TextField(
      controller: spfController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Enter SPF Number',
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        prefixIcon: const Icon(Icons.wb_sunny),
      ),
    );
  }

  Widget _buildNotificationSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reminder to reapply sunscreen',
          style: TextStyle(fontSize: 16),
        ),
        Switch(
          value: notificationEnabled,
          onChanged: (value) {
            setState(() {
              notificationEnabled = value;
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'You will be notified after the calculated duration will run out',
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      onPressed: () {
        calculateSunscreenDuration(widget.uvIndex);
      },
      icon: const Icon(Icons.timer),
      label: const Text('Calculate Sunscreen Duration'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildReminderText() {
    return const Text(
      'Reminder: Apply an adequate amount of sunscreen (2mg/cm²) and reapply after sweating, wiping your face, or swimming.',
      style: TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  Widget _buildSunscreenCalculatorButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(
            255, 87, 81, 255), // Set your desired background color here
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Want to calculate the amount of sunscreen you need?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SunscreenAmountPage(),
                ),
              );
            },
            icon: const Icon(Icons.calculate),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700], // Button background color
              foregroundColor: Colors.black, // Button text and icon color
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            label: const Text('Sunscreen Amount Calculator'),
          ),
        ],
      ),
    );
  }

  void calculateSunscreenDuration(double? uvIndex) {
    if (uvIndex == null || uvIndex <= 0 || uvIndex.isNaN) {
      _showErrorDialog('Invalid UV Index', 'Please enter a valid UV Index.');
      return;
    }

    int? spf = int.tryParse(spfController.text);
    if (spf == null) {
      _showErrorDialog('Invalid SPF', 'Please enter a valid SPF value.');
      return;
    }

    int skinBurnTime;
    switch (selectedSkinTone) {
      case 0:
        skinBurnTime = 67;
        break;
      case 1:
        skinBurnTime = 100;
        break;
      case 2:
        skinBurnTime = 200;
        break;
      case 3:
        skinBurnTime = 300;
        break;
      case 4:
        skinBurnTime = 400;
        break;
      case 5:
      default:
        skinBurnTime = 500;
        break;
    }

    double totalMinutes = (skinBurnTime / uvIndex) * (spf - 2);
    int hours = (totalMinutes / 60).floor();
    int minutes = (totalMinutes % 60).floor();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sunscreen Duration'),
        content: Text(
            'Your sunscreen will last for approximately $hours hours and $minutes minutes.'),
        actions: [
          TextButton(
            onPressed: () {
              if (notificationEnabled) {
                scheduleNotification(hours, minutes);
              }
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void scheduleNotification(int hours, int minutes) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sunscreen_channel',
      'Sunscreen Notifications',
      channelDescription: 'Notifications to remind you to reapply sunscreen',
      importance: Importance.max,
      priority: Priority.high,
      autoCancel:
          true, // This ensures the notification disappears when action is taken
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'reapply_yes',
          'Yes',
        ),
        AndroidNotificationAction(
          'reapply_no',
          'No',
        ),
      ],
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Sunscreen Reminder',
      'Time to reapply your sunscreen! Did you reapply?',
      tz.TZDateTime.now(tz.local).add(Duration(hours: hours, minutes: minutes)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reapply',
    );
  }
}
