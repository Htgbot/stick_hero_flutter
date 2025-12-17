import 'dart:ui';
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

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  MapType _selectedMapType = MapType.jungle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/images/home.jpg",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                  ),
                ),
              );
            },
          ),
          
          // Content
          SafeArea(
            child: Row(
              children: [
                // Left Side: Title and Buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "STICK HERO",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(5.0, 5.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      _buildGlassButton(
                        label: "EASY MODE",
                        onTap: () => _startGame(GameMode.easy),
                        color: Colors.green.withOpacity(0.3),
                      ),
                      SizedBox(height: 20),
                      _buildGlassButton(
                        label: "HARD MODE",
                        onTap: () => _startGame(GameMode.hard),
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                
                // Right Side: Map Selection
                Expanded(
                  flex: 1,
                  child: Center(
                    child: _buildGlassMapSelection(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(mode: mode, mapType: _selectedMapType)),
    );
  }

  Widget _buildGlassButton({required String label, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 250,
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 5, color: Colors.black45, offset: Offset(2, 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMapSelection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 200,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SELECT MAP",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 5, color: Colors.black45, offset: Offset(1, 1)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MapType>(
                    value: _selectedMapType,
                    isExpanded: true,
                    dropdownColor: Colors.black87,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (MapType? newValue) {
                      setState(() {
                        _selectedMapType = newValue!;
                      });
                    },
                    items: MapType.values.map<DropdownMenuItem<MapType>>((MapType value) {
                      String label;
                      switch (value) {
                        case MapType.jungle: label = "Jungle"; break;
                        case MapType.cool: label = "Cool"; break;
                        case MapType.lava: label = "Lava"; break;
                        case MapType.paradise: label = "Paradise"; break;
                      }
                      return DropdownMenuItem<MapType>(
                        value: value,
                        child: Text(label),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
