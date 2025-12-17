import 'dart:math';

enum GamePhase { waiting, stretching, turning, walking, transitioning, falling }
enum GameMode { easy, hard }

class Platform {
  double x;
  double w;
  
  Platform({required this.x, required this.w});

  double get right => x + w;
}

class Stick {
  double x;
  double length;
  double rotation; // degrees

  Stick({required this.x, this.length = 0, this.rotation = 0});
}

class Tree {
  double x;
  String color;
  
  Tree({required this.x, required this.color});
}

class GameConfig {
  static const double platformHeight = 100;
  static const double heroDistanceFromEdge = 10;
  static const double paddingX = 100;
  static const double perfectAreaSize = 10;
  static const double heroWidth = 17;
  static const double heroHeight = 30;
  
  // Speeds (units per second)
  static const double stretchingSpeed = 250; 
  static const double turningSpeed = 250; 
  static const double walkingSpeed = 250;
  static const double transitioningSpeed = 500;
  static const double fallingSpeed = 500;
  
  // Hard mode multipliers
  static const double hardModeSpeedMultiplier = 1.5;
}

class GameState {
  GamePhase phase = GamePhase.waiting;
  
  double heroX = 0;
  double heroY = 0;
  double sceneOffset = 0;
  
  List<Platform> platforms = [];
  List<Stick> sticks = [];
  List<Tree> trees = [];
  
  int score = 0;
  bool showPerfect = false;
  
  // For animation
  double lastTimestamp = 0;
  
  final Random _rnd = Random();
  GameMode mode = GameMode.easy;
  
  // Getters for current state
  Stick? get currentStick => sticks.isNotEmpty ? sticks.last : null;
  
  void reset(GameMode gameMode) {
    mode = gameMode;
    phase = GamePhase.waiting;
    sceneOffset = 0;
    score = 0;
    showPerfect = false;
    
    // Initial platforms
    platforms = [Platform(x: 50, w: 50)];
    generatePlatform();
    generatePlatform();
    generatePlatform();
    generatePlatform();
    
    // Initial stick
    sticks = [Stick(x: platforms[0].right)];
    
    // Initial trees
    trees = [];
    for(int i=0; i<10; i++) {
      generateTree();
    }
    
    heroX = platforms[0].right - GameConfig.heroDistanceFromEdge;
    heroY = 0;
  }
  
  void generatePlatform() {
    double minGap = 40;
    double maxGap = 200;
    double minWidth = 20;
    double maxWidth = 100;
    
    if (mode == GameMode.hard) {
       minGap = 60;
       maxGap = 250;
       minWidth = 10;
       maxWidth = 60;
    }

    double lastRight = platforms.isNotEmpty ? platforms.last.right : 0;
    
    double x = lastRight + minGap + _rnd.nextDouble() * (maxGap - minGap);
    double w = minWidth + _rnd.nextDouble() * (maxWidth - minWidth);
    
    platforms.add(Platform(x: x, w: w));
  }
  
  void generateTree() {
    double minGap = 30;
    double maxGap = 150;
    
    double lastX = trees.isNotEmpty ? trees.last.x : 0;
    double x = lastX + minGap + _rnd.nextDouble() * (maxGap - minGap);
    
    final colors = ["#6D8821", "#8FAC34", "#98B333"];
    String color = colors[_rnd.nextInt(colors.length)];
    
    trees.add(Tree(x: x, color: color));
  }
  
  // Returns [Platform?, bool isPerfect]
  (Platform?, bool) thePlatformTheStickHits() {
    if (currentStick == null) return (null, false);
    if ((currentStick!.rotation - 90).abs() > 0.1) {
      // Stick must be at 90 degrees to check hit strictly, 
      // but in logic we check length against platform x
    }
    
    double stickFarX = currentStick!.x + currentStick!.length;
    
    try {
      Platform hit = platforms.firstWhere((p) => p.x < stickFarX && stickFarX < p.right);
      
      bool perfect = false;
      double center = hit.x + hit.w / 2;
      if (stickFarX > center - GameConfig.perfectAreaSize / 2 && 
          stickFarX < center + GameConfig.perfectAreaSize / 2) {
        perfect = true;
      }
      
      return (hit, perfect);
    } catch (e) {
      return (null, false);
    }
  }
  
  void update(double dt, Function onGameOver, Function onScore) {
    if (phase == GamePhase.waiting) return;
    
    double speedMult = mode == GameMode.hard ? GameConfig.hardModeSpeedMultiplier : 1.0;
    
    switch (phase) {
      case GamePhase.stretching:
        if (currentStick != null) {
          currentStick!.length += dt * GameConfig.stretchingSpeed * speedMult;
        }
        break;
        
      case GamePhase.turning:
        if (currentStick != null) {
          currentStick!.rotation += dt * GameConfig.turningSpeed * speedMult;
          if (currentStick!.rotation > 90) {
            currentStick!.rotation = 90;
            
            var (nextPlatform, perfectHit) = thePlatformTheStickHits();
            if (nextPlatform != null) {
              score += perfectHit ? 2 : 1;
              onScore(score);
              if (perfectHit) {
                showPerfect = true;
                // Auto hide perfect after 1s handled in UI
              }
              
              generatePlatform();
              generateTree();
              generateTree();
            }
            
            phase = GamePhase.walking;
          }
        }
        break;
        
      case GamePhase.walking:
        heroX += dt * GameConfig.walkingSpeed;
        
        var (nextPlatform, _) = thePlatformTheStickHits();
        if (nextPlatform != null) {
          double maxHeroX = nextPlatform.right - GameConfig.heroDistanceFromEdge;
          if (heroX > maxHeroX) {
            heroX = maxHeroX;
            phase = GamePhase.transitioning;
          }
        } else {
          // Fall
          double maxHeroX = currentStick!.x + currentStick!.length + GameConfig.heroWidth;
          if (heroX > maxHeroX) {
            heroX = maxHeroX;
            phase = GamePhase.falling;
          }
        }
        break;
        
      case GamePhase.transitioning:
        sceneOffset += dt * GameConfig.transitioningSpeed;
        
        var (nextPlatform, _) = thePlatformTheStickHits();
        if (nextPlatform != null) {
           if (sceneOffset > nextPlatform.right - GameConfig.paddingX) {
             sticks.add(Stick(x: nextPlatform.right));
             phase = GamePhase.waiting;
           }
        }
        break;
        
      case GamePhase.falling:
        if (currentStick != null && currentStick!.rotation < 180) {
          currentStick!.rotation += dt * GameConfig.turningSpeed;
        }
        heroY += dt * GameConfig.fallingSpeed;
        
        if (heroY > GameConfig.platformHeight + 100) {
          onGameOver();
        }
        break;
        
      case GamePhase.waiting:
        break;
    }
  }
}
