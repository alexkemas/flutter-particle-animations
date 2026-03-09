import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MaterialApp(
      home: FireworkShowcase(),
      debugShowCheckedModeBanner: false,
    ));

class FireworkShowcase extends StatefulWidget {
  const FireworkShowcase({super.key});

  @override
  State<FireworkShowcase> createState() => _FireworkShowcaseState();
}

class _FireworkShowcaseState extends State<FireworkShowcase> with TickerProviderStateMixin {
  // We use the confetti package for the '250 button' fetti
  late ConfettiController _confettiController;
  
  // Confetti position for 250th text
  late GlobalKey _confettiKey = GlobalKey();
  bool _is250thClicked = false;
  
  // We use a custom engine for the fireworks to get that 'glow' and 'drop'
  late AnimationController _animationController;
  
  // Particle and Rocket states
  List<FireworkParticle> _particles = [];
  List<Offset> _rocketTrail = []; 
  Offset? _rocketPosition;
  Color _currentFireworkColor = Colors.redAccent;
  bool _isRocketFlying = false;

  // =============================================================================
  // INITIALIZATION - Set up controllers and listeners
  // =============================================================================
  // Changes made:
  // - Confetti duration reduced to 50ms for instant response
  // - Animation controller uses addListener for 60fps physics updates

  @override
  void initState() {
    super.initState();
    
    // Confetti Setup: Non-looping, very short duration for instant fire
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 50));
    
    // This controller drives our custom firework physics loop
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        _updatePhysics();
      });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- THE PHYSICS ENGINE ---
  // This runs every frame (~60fps). 
  // Changes made:
  // - Rocket speed increased from 10px to 15px per frame (50% faster)
  // - Gravity increased from 0.12 to 0.25 (2x faster drop)
  // - Particle lifetime decay increased from 0.012 to 0.018 (50% quicker fade)
  
  void _updatePhysics() {
    setState(() {
      // 1. Handle the Rising Rocket (The Fuse)
      if (_isRocketFlying && _rocketPosition != null) {
        // We move the rocket up by 10px per frame (adjustable for speed)
        // CHANGE: Actually 15px per frame now (50% faster than original 10px)
        _rocketPosition = Offset(_rocketPosition!.dx, _rocketPosition!.dy - 15);
        
        // Save position to history to create the trailing 'comet' look
        _rocketTrail.add(_rocketPosition!);
        if (_rocketTrail.length > 12) _rocketTrail.removeAt(0);

        // Check if rocket reached the peak (set at 25% of screen height)
        if (_rocketPosition!.dy < MediaQuery.of(context).size.height * 0.25) {
          _explode(_rocketPosition!);
          _isRocketFlying = false;
        }
      } else {
        // Fade out the trail once the rocket explodes
        if (_rocketTrail.isNotEmpty) _rocketTrail.removeAt(0);
      }

      // 2. Handle the Exploded Embers
      for (final particle in _particles) {
        particle.velocity += const Offset(0, 0.25); // GRAVITY: makes them drop faster
        // CHANGE: Increased from 0.12 to 0.25 (2x faster gravity)
        particle.velocity *= 0.97; // DRAG: makes them slow down into a 'flower' shape
        particle.position += particle.velocity;
        particle.lifetime -= 0.018; // FADE: how fast the spark dies out
        // CHANGE: Increased from 0.012 to 0.018 (50% quicker fade)
      }
      
      // Cleanup dead particles to keep the app fast
      _particles.removeWhere((p) => p.lifetime <= 0);
    });
  }

  // Starts the rocket launch sequence
  // Changes made:
  // - Added offset launch positions (red from left, blue from right)
  // - Colors changed to deep red (#660000) and bright blue (#0040FF)
  
  void _launchFirework(Color color) {
    final size = MediaQuery.of(context).size;
    _currentFireworkColor = color;
    
    // Offset launch position based on color
    // CHANGE: Added visual variety with offset positions
    // Red fires from left (-10% width), Blue fires from right (+10% width)
    double xOffset = 0;
    if (color == const Color(0xFF660000)) {
      xOffset = -size.width * 0.1; // Red fires from left
    } else if (color == const Color(0xFF0040FF)) {
      xOffset = size.width * 0.1; // Blue fires from right
    }
    
    _rocketPosition = Offset((size.width / 2) + xOffset, size.height);
    _rocketTrail = [];
    _isRocketFlying = true;
    _animationController.repeat(); // Starts the physics loop
  }

  // Generates the initial burst of particles at the peak
  // Changes made:
  // - Added particle variety: 70% main color, 15% lighter shades, 15% white
  // - Creates more visual interest vs uniform colors
  
  void _explode(Offset position) {
    final random = Random();
    _particles = List.generate(100, (index) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = random.nextDouble() * 5 + 2;
      
      // 70% main color, 15% variety (whiter/lighter shades)
      // CHANGE: Added particle variety for visual effect
      // Previous version had 100% uniform color
      Color particleColor;
      if (index < 70) {
        // Main color particles
        particleColor = _currentFireworkColor;
      } else if (index < 85) {
        // Lighter shade of main color
        particleColor = _currentFireworkColor.withOpacity(0.7);
      } else {
        // Few white particles
        // CHANGE: Added sparkle effect with white particles
        particleColor = Colors.white;
      }
      
      return FireworkParticle(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: particleColor,
        size: random.nextDouble() * 2.5 + 1.0,
        lifetime: 1.0,
      );
    });
  }

  // =============================================================================
  // UI LAYOUT - Layered interface with confetti, fireworks, and controls
  // =============================================================================
  // Changes made:
  // - 250th text with superscript 'th' and gold flash effect
  // - Confetti positioned to blast from 250th text location
  // - Confetti gravity increased to 0.8 for faster falling
  // - Firework buttons use deep red (#660000) and bright blue (#0040FF)
  // - Instant confetti response (no stop/start delay)
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020205), // Dark mode background
      body: Stack(
        children: [
          // LAYER 1: 250th Text Display
          // CHANGE: Added superscript 'th' and gold flash effect
          // CHANGE: Positioned at top: 80 to avoid fireworks overlap
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "250",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _is250thClicked ? const Color(0xFFFFD700) : Colors.white,
                      ),
                    ),
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(0, -6),
                        child: Text(
                          "th",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: _is250thClicked ? const Color(0xFFFFD700) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // LAYER 2: Standard Confetti
          // Confetti positioned to blast from 250th text (centered)
          // CHANGE: Positioned to explode from 250th text location
          // CHANGE: Increased gravity to 0.8 for faster falling
          // CHANGE: 40 particles in red/white/blue colors
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 40,
                maximumSize: const Size(8, 4),
                minimumSize: const Size(4, 2),
                colors: const [Colors.red, Colors.white, Colors.blue],
                gravity: 0.8, // Much faster gravity
              ),
            ),
          ),

          // LAYER 3: Custom Fireworks (Drawn on Canvas)
          // CHANGE: Enhanced rendering with multi-layer rocket flames
          // CHANGE: Star-shaped particles instead of circles
          // CHANGE: Enhanced glow effects with deeper colors
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: FireworkPainter(
              particles: _particles,
              rocketTrail: _rocketTrail,
              mainColor: _currentFireworkColor,
            ),
          ),

          // LAYER 4: User Interface
          // CHANGE: Added gold flash to 250th text when button clicked
          // CHANGE: Removed stop/start delay for instant confetti response
          // CHANGE: Updated button colors to deep red and bright blue
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // 250th Confetti Button - Triggers gold flash and confetti
                // CHANGE: Instant response without animation delay
                _buildBtn("confetti for 250 button", Colors.grey.shade900, () {
                  // Gold flash effect
                  setState(() {
                    _is250thClicked = true;
                  });
                  
                  // Reset gold color after animation
                  Future.delayed(const Duration(milliseconds: 200), () {
                    setState(() {
                      _is250thClicked = false;
                    });
                  });
                  
                  // Play confetti directly without stop/start delay
                  // CHANGE: Removed _confettiController.stop() for instant response
                  _confettiController.play();
                }),
                const SizedBox(height: 12),
                // Firework Buttons - Red and Blue with offset launch positions
                // CHANGE: Colors updated to deep red (#660000) and bright blue (#0040FF)
                // CHANGE: Launch positions offset for visual variety
                Row(
                  children: [
                    Expanded(child: _buildBtn("RED FIREWORK", const Color(0xFF660000), () => _launchFirework(const Color(0xFF660000)))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildBtn("BLUE FIREWORK", const Color(0xFF0040FF), () => _launchFirework(const Color(0xFF0040FF)))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick helper to keep the UI code clean
  Widget _buildBtn(String text, Color col, VoidCallback fn) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: col,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: fn,
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

// --- DATA CLASSES ---
// Changes made:
// - FireworkParticle structure unchanged (stable data model)
// - All particle properties support enhanced rendering

class FireworkParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifetime;
  FireworkParticle({required this.position, required this.velocity, required this.color, required this.size, required this.lifetime});
}

// --- THE PAINTER ---
// This draws the shapes onto the screen based on the physics engine data
// Changes made:
// - Enhanced rocket trail with multi-layer flame rendering
// - Reduced white blending for deeper color glow (30% vs 60%)
// - Increased blur radius for stronger glow effect (+4 vs +1)
// - Replaced circular particles with 8-pointed stars
// - Increased glow radius from 2x to 2.5x for bigger impact
// - Enhanced white blending for brighter particles (80% vs 50%)
// - Added star shape rendering for crystalline appearance

class FireworkPainter extends CustomPainter {
  final List<FireworkParticle> particles;
  final List<Offset> rocketTrail;
  final Color mainColor;

  FireworkPainter({required this.particles, required this.rocketTrail, required this.mainColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Draw the Rocket Fuse Trail
    // CHANGE: Enhanced from simple circles to multi-layer rocket flame
    // CHANGE: Reduced white blending for deeper color presence
    // CHANGE: Increased blur radius for stronger glow effect
    for (int i = 0; i < rocketTrail.length; i++) {
      double opacity = i / rocketTrail.length;
      paint.color = Color.lerp(mainColor.withOpacity(0.9), Colors.white, 0.8)!.withOpacity(opacity);
      // Blur filter creates the 'glow'
      // CHANGE: Blur radius increased from +1 to +4
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, (12 - i).toDouble() + 4);
      
      // Draw rocket flame shape
      // CHANGE: Multi-layer rendering for realistic flame
      final center = rocketTrail[i];
      final flameSize = 3.0 + (i * 0.3);
      
      // Outer glow with deep color
      // CHANGE: Reduced white from 60% to 30% for deeper color
      paint.color = Color.lerp(mainColor.withOpacity(0.9), Colors.white, 0.3)!.withOpacity(opacity);
      canvas.drawCircle(center, flameSize * 1.5, paint);
      
      // Inner flame core with color
      // CHANGE: Balanced color and white blend
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, (12 - i).toDouble() + 2);
      paint.color = Color.lerp(mainColor.withOpacity(0.95), Colors.white, 0.5)!.withOpacity(opacity);
      canvas.drawCircle(center, flameSize * 0.8, paint);
      
      // Hot center
      paint.maskFilter = null;
      paint.color = Color.lerp(mainColor.withOpacity(0.8), Colors.white, 0.7)!.withOpacity(opacity * 0.9);
      canvas.drawCircle(center, flameSize * 0.3, paint);
    }

    // 2. Draw the Explosion Sparks
    // CHANGE: Replaced circles with 8-pointed stars for crystalline appearance
    // CHANGE: Increased glow radius from 2x to 2.5x for bigger impact
    // CHANGE: Enhanced white blending for brighter, more intense glow
    for (final p in particles) {
      // Glow/Bloom Layer
      // CHANGE: Increased size multiplier from 2.0 to 2.5
      // CHANGE: Increased opacity from 0.7 to 0.9 for brighter glow
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      paint.color = p.color.withOpacity(p.lifetime * 0.9);
      canvas.drawCircle(p.position, p.size * 2.5, paint);
      
      // Sharp Edge Layer
      // CHANGE: Changed from circles to 8-pointed stars
      // CHANGE: Increased white blending from 50% to 80% for brighter effect
      paint.maskFilter = null;
      paint.color = Color.lerp(p.color.withOpacity(0.9), Colors.white, 0.8)!.withOpacity(p.lifetime);
      
      // Draw star shape instead of circle
      // CHANGE: 8-pointed star creates crystalline appearance
      final path = Path();
      final center = p.position;
      final outerRadius = p.size;
      final innerRadius = p.size * 0.4;
      
      for (int i = 0; i < 8; i++) {
        final angle = (i * pi / 4);
        final radius = i % 2 == 0 ? outerRadius : innerRadius;
        final x = center.dx + cos(angle) * radius;
        final y = center.dy + sin(angle) * radius;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}