import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';
import 'game_logic.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stick Hero Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Segoe UI',
      ),
      home: MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBBD691), Color(0xFFFEF1E1)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "STICK HERO",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black26,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              _buildButton(context, "EASY MODE", GameMode.easy, Colors.green),
              SizedBox(height: 20),
              _buildButton(context, "HARD MODE", GameMode.hard, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, GameMode mode, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(mode: mode)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
