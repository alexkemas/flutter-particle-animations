import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

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
  
  // We use a custom engine for the fireworks to get that 'glow' and 'drop'
  late AnimationController _animationController;
  
  // Particle and Rocket states
  List<FireworkParticle> _particles = [];
  List<Offset> _rocketTrail = []; 
  Offset? _rocketPosition;
  Color _currentFireworkColor = Colors.redAccent;
  bool _isRocketFlying = false;

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
  void _updatePhysics() {
    setState(() {
      // 1. Handle the Rising Rocket (The Fuse)
      if (_isRocketFlying && _rocketPosition != null) {
        // We move the rocket up by 10px per frame (adjustable for speed)
        _rocketPosition = Offset(_rocketPosition!.dx, _rocketPosition!.dy - 10);
        
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
        particle.velocity += const Offset(0, 0.12); // GRAVITY: makes them drop
        particle.velocity *= 0.97; // DRAG: makes them slow down into a 'flower' shape
        particle.position += particle.velocity;
        particle.lifetime -= 0.012; // FADE: how fast the spark dies out
      }
      
      // Cleanup dead particles to keep the app fast
      _particles.removeWhere((p) => p.lifetime <= 0);
    });
  }

  // Starts the rocket launch sequence
  void _launchFirework(Color color) {
    final size = MediaQuery.of(context).size;
    _currentFireworkColor = color;
    _rocketPosition = Offset(size.width / 2, size.height);
    _rocketTrail = [];
    _isRocketFlying = true;
    _animationController.repeat(); // Starts the physics loop
  }

  // Generates the initial burst of particles at the peak
  void _explode(Offset position) {
    final random = Random();
    _particles = List.generate(100, (_) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = random.nextDouble() * 5 + 2; // Initial blast velocity
      return FireworkParticle(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: _currentFireworkColor,
        size: random.nextDouble() * 2.5 + 1.0,
        lifetime: 1.0, // Starts at 100% opacity
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020205), // Dark mode background
      body: Stack(
        children: [
          // LAYER 1: Standard Confetti
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 40,
              maximumSize: const Size(8, 4), // Tiny fetti pieces
              minimumSize: const Size(4, 2),
              colors: const [Colors.red, Colors.white, Colors.blue],
            ),
          ),

          // LAYER 2: Custom Fireworks (Drawn on the Canvas)
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: FireworkPainter(
              particles: _particles,
              rocketTrail: _rocketTrail,
              mainColor: _currentFireworkColor,
            ),
          ),

          // LAYER 3: User Interface
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildBtn("confetti for 250 button", Colors.grey.shade900, () {
                  // Instant reset logic: stop then play
                  _confettiController.stop(); 
                  _confettiController.play();
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildBtn("RED FIREWORK", const Color(0xFFD32F2F), () => _launchFirework(Colors.redAccent))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildBtn("BLUE FIREWORK", const Color(0xFF1976D2), () => _launchFirework(Colors.lightBlueAccent))),
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
class FireworkPainter extends CustomPainter {
  final List<FireworkParticle> particles;
  final List<Offset> rocketTrail;
  final Color mainColor;

  FireworkPainter({required this.particles, required this.rocketTrail, required this.mainColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Draw the Rocket Fuse Trail
    for (int i = 0; i < rocketTrail.length; i++) {
      double opacity = i / rocketTrail.length;
      paint.color = Color.lerp(mainColor, Colors.white, 0.4)!.withOpacity(opacity);
      // Blur filter creates the 'glow'
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, (12 - i).toDouble() + 1);
      canvas.drawCircle(rocketTrail[i], 2.5 + (i * 0.2), paint);
    }

    // 2. Draw the Explosion Sparks
    for (final p in particles) {
      // Glow/Bloom Layer
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      paint.color = p.color.withOpacity(p.lifetime * 0.7);
      canvas.drawCircle(p.position, p.size * 2, paint);
      
      // Solid Hot Core Layer
      paint.maskFilter = null;
      paint.color = Color.lerp(p.color, Colors.white, 0.5)!.withOpacity(p.lifetime);
      canvas.drawCircle(p.position, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}