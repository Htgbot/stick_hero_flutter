import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'game_logic.dart';
import 'painters.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final MapType mapType;

  const GameScreen({Key? key, required this.mode, this.mapType = MapType.jungle}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameState gameState;
  late Ticker _ticker;
  Duration? _lastElapsed;
  
  int highScore = 0;
  bool isGameOver = false;
  
  // For UI animations
  bool showPerfect = false;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    _loadHighScore();
    _startGame();
    
    _ticker = createTicker(_onTick);
    _ticker.start();
  }
  
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    String key = widget.mode == GameMode.easy ? 'highscore_easy' : 'highscore_hard';
    setState(() {
      highScore = prefs.getInt(key) ?? 0;
    });
  }
  
  Future<void> _saveHighScore(int score) async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      String key = widget.mode == GameMode.easy ? 'highscore_easy' : 'highscore_hard';
      await prefs.setInt(key, score);
      setState(() {
        highScore = score;
      });
    }
  }

  void _startGame() {
    gameState.reset(widget.mode, widget.mapType);
    setState(() {
      isGameOver = false;
      showPerfect = false;
    });
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == null) {
      _lastElapsed = elapsed;
      return;
    }
    
    double dt = (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    
    // Cap dt to avoid huge jumps
    if (dt > 0.1) dt = 0.1;
    
    setState(() {
      gameState.update(dt, _onGameOver, _onScore);
      
      // Handle perfect indicator visibility from logic state
      if (gameState.showPerfect) {
        _showPerfectIndicator();
        gameState.showPerfect = false; // Reset flag in logic so we don't trigger again
      }
    });
  }
  
  void _onScore(int score) {
    _saveHighScore(score);
  }
  
  void _onGameOver() {
    if (!isGameOver) {
      isGameOver = true;
      _vibrate();
    }
  }
  
  void _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }
  
  void _showPerfectIndicator() {
    setState(() {
      showPerfect = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showPerfect = false;
        });
      }
    });
  }

  void _revive() {
    setState(() {
      gameState.revive();
      isGameOver = false;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (gameState.phase == GamePhase.waiting) {
      gameState.phase = GamePhase.stretching;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (gameState.phase == GamePhase.stretching) {
      gameState.phase = GamePhase.turning;
    }
  }

  Widget _buildGlassNeonButton({required IconData icon, required String label}) {
    return Container(
      width: 200,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.redAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.red,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: isGameOver ? null : _handleTapDown,
        onTapUp: isGameOver ? null : _handleTapUp,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Game Painter
            CustomPaint(
              painter: GamePainter(gameState, MediaQuery.of(context).size),
            ),
            
            // Score and Hearts
            Positioned(
              top: 30,
              right: 30,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${gameState.score}",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "BEST: $highScore",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: List.generate(3, (index) {
                        return Icon(
                          index < gameState.revives ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 24,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            
            // Introduction Text
            if (gameState.phase == GamePhase.waiting && gameState.score == 0)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Hold down to stretch the stick",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                    ),
                  ),
                ),
              ),
              
            // Perfect Indicator
            if (showPerfect)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 50,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: showPerfect ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      "DOUBLE SCORE",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

            // Game Over Popup
            if (isGameOver)
              Stack(
                children: [
                  // Blurred Background
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                  // Popup Content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (gameState.canRevive())
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: GestureDetector(
                              onTap: _revive,
                              child: _buildGlassNeonButton(
                                icon: Icons.arrow_forward,
                                label: "CONTINUE",
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: _startGame,
                          child: _buildGlassNeonButton(
                            icon: Icons.refresh,
                            label: "RESTART",
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: _buildGlassNeonButton(
                            icon: Icons.home,
                            label: "HOME",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
            // Back Button
            Positioned(
              top: 30,
              left: 30,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
