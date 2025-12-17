import 'dart:math';
import 'package:flutter/material.dart';
import 'game_logic.dart';

class GamePainter extends CustomPainter {
  final GameState state;
  final Size screenSize;

  GamePainter(this.state, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background
    drawBackground(canvas, size);

    // Translate scene
    canvas.save();
    double canvasWidth = 375; // Logic width reference
    double canvasHeight = 375; // Logic height reference (unused mostly)
    
    // JS: ctx.translate((window.innerWidth - canvasWidth) / 2 - sceneOffset, (window.innerHeight - canvasHeight) / 2);
    // But in Flutter we usually want to center vertically based on platform height?
    // The JS code centers the "game area" (375x375).
    // Let's adapt: Center horizontally, stick to bottom for platforms.
    
    double dx = (size.width - canvasWidth) / 2 - state.sceneOffset;
    double dy = (size.height - canvasHeight) / 2; 
    
    // Actually, in JS the platforms are drawn at `canvasHeight - platformHeight` (375 - 100 = 275).
    // And `heroY` is relative to that.
    // If we use the same translation as JS:
    canvas.translate(dx, dy);

    // 2. Draw Scene
    drawPlatforms(canvas);
    drawHero(canvas);
    drawSticks(canvas);

    canvas.restore();
  }

  void drawBackground(Canvas canvas, Size size) {
    // Sky
    final Rect rect = Offset.zero & size;
    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBBD691), Color(0xFFFEF1E1)],
      ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    // Hills
    // hill1: baseHeight=100, amp=10, stretch=1, color=#95C629
    drawHill(canvas, size, 100, 10, 1.0, Color(0xFF95C629));
    // hill2: baseHeight=70, amp=20, stretch=0.5, color=#659F1C
    drawHill(canvas, size, 70, 20, 0.5, Color(0xFF659F1C));

    // Trees
    for (var tree in state.trees) {
      drawTree(canvas, tree);
    }
  }

  double getHillY(double windowX, double baseHeight, double amplitude, double stretch, Size size) {
    double sineBaseY = size.height - baseHeight;
    // JS: Math.sinus((sceneOffset * backgroundSpeedMultiplier + windowX) * stretch) * amplitude + sineBaseY
    // sinus(deg) = sin(deg * pi / 180)
    double offset = state.sceneOffset * 0.2 + windowX;
    double deg = offset * stretch;
    double rad = deg * pi / 180.0;
    return sin(rad) * amplitude + sineBaseY;
  }

  void drawHill(Canvas canvas, Size size, double baseHeight, double amplitude, double stretch, Color color) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, getHillY(0, baseHeight, amplitude, stretch, size));
    
    for (double i = 0; i <= size.width; i += 10) {
      path.lineTo(i, getHillY(i, baseHeight, amplitude, stretch, size));
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void drawTree(Canvas canvas, Tree tree) {
    canvas.save();
    
    // JS: (-sceneOffset * backgroundSpeedMultiplier + x) * hill1Stretch
    // hill1Stretch is 1.
    double tx = (-state.sceneOffset * 0.2 + tree.x) * 1.0;
    
    // JS: getTreeY(x, hill1BaseHeight, hill1Amplitude)
    // hill1BaseHeight = 100, hill1Amplitude = 10
    // getTreeY uses sinus(x). 
    double rad = tree.x * pi / 180.0;
    double sineBaseY = screenSize.height - 100; // 100 is hill1BaseHeight
    double ty = sin(rad) * 10 + sineBaseY;

    canvas.translate(tx, ty);

    double treeTrunkHeight = 5;
    double treeTrunkWidth = 2;
    double treeCrownHeight = 25;
    double treeCrownWidth = 10;

    // Trunk
    canvas.drawRect(
      Rect.fromLTWH(-treeTrunkWidth / 2, -treeTrunkHeight, treeTrunkWidth, treeTrunkHeight),
      Paint()..color = Color(0xFF7D833C),
    );

    // Crown
    Path crown = Path();
    crown.moveTo(-treeCrownWidth / 2, -treeTrunkHeight);
    crown.lineTo(0, -(treeTrunkHeight + treeCrownHeight));
    crown.lineTo(treeCrownWidth / 2, -treeTrunkHeight);
    crown.close();
    
    // Parse hex color string
    Color crownColor = _parseColor(tree.color);
    canvas.drawPath(crown, Paint()..color = crownColor);

    canvas.restore();
  }

  void drawPlatforms(Canvas canvas) {
    double canvasHeight = 375;
    double platformHeight = GameConfig.platformHeight;

    for (var p in state.platforms) {
      // Draw Platform
      canvas.drawRect(
        Rect.fromLTWH(p.x, canvasHeight - platformHeight, p.w, platformHeight + 500), // +500 to cover bottom
        Paint()..color = Colors.black,
      );

      // Draw perfect area
      if (state.currentStick != null && state.currentStick!.x < p.x) {
         double center = p.x + p.w / 2;
         double size = GameConfig.perfectAreaSize;
         canvas.drawRect(
           Rect.fromLTWH(center - size / 2, canvasHeight - platformHeight, size, size),
           Paint()..color = Colors.red,
         );
      }
    }
  }

  void drawHero(Canvas canvas) {
    canvas.save();
    double canvasHeight = 375;
    double platformHeight = GameConfig.platformHeight;
    double heroWidth = GameConfig.heroWidth;
    double heroHeight = GameConfig.heroHeight;

    canvas.translate(
      state.heroX - heroWidth / 2,
      state.heroY + canvasHeight - platformHeight - heroHeight / 2
    );

    // Body (Rounded Rect)
    RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(-heroWidth/2, -heroHeight/2, heroWidth, heroHeight - 4),
      Radius.circular(5)
    );
    canvas.drawRRect(body, Paint()..color = Colors.black);

    // Legs
    double legDistance = 5;
    canvas.drawCircle(Offset(legDistance, 11.5), 3, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(-legDistance, 11.5), 3, Paint()..color = Colors.black);

    // Eye
    canvas.drawCircle(Offset(5, -7), 3, Paint()..color = Colors.white);

    // Band
    canvas.drawRect(Rect.fromLTWH(-heroWidth/2 - 1, -12, heroWidth + 2, 4.5), Paint()..color = Colors.red);
    Path band = Path();
    band.moveTo(-9, -14.5);
    band.lineTo(-17, -18.5);
    band.lineTo(-14, -8.5);
    band.close();
    canvas.drawPath(band, Paint()..color = Colors.red);
    
    Path band2 = Path();
    band2.moveTo(-10, -10.5);
    band2.lineTo(-15, -3.5);
    band2.lineTo(-5, -7);
    band2.close();
    canvas.drawPath(band2, Paint()..color = Colors.red);

    canvas.restore();
  }

  void drawSticks(Canvas canvas) {
    double canvasHeight = 375;
    double platformHeight = GameConfig.platformHeight;

    for (var stick in state.sticks) {
      canvas.save();
      canvas.translate(stick.x, canvasHeight - platformHeight);
      canvas.rotate(stick.rotation * pi / 180);
      
      canvas.drawLine(Offset(0, 0), Offset(0, -stick.length), Paint()..color = Colors.black ..strokeWidth = 2);
      
      canvas.restore();
    }
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF" + hex;
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
