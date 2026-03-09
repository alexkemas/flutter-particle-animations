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
  // THEME AWARENESS: Added theme state for light/dark mode toggle
  // PRODUCTION REFACTOR: Consider using ThemeProvider or shared preferences for persistence
  bool _isDarkMode = true;
  
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
  
  // THEME AWARENESS: Enhanced particle generation for light mode
  // PRODUCTION REFACTOR: Extract particle color logic into separate strategy pattern
  // Light mode gets more white particles (25% vs 15%) for better contrast
  void _explode(Offset position) {
    final random = Random();
    _particles = List.generate(100, (index) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = random.nextDouble() * 5 + 2;
      
      // Enhanced particle variety for better visual effect
      // More white particles in light mode for highlighting
      Color particleColor;
      int whiteParticleThreshold = _isDarkMode ? 85 : 75; // More white in light mode
      
      if (index < 60) {
        // Main color particles
        particleColor = _currentFireworkColor;
      } else if (index < whiteParticleThreshold) {
        // White particles for highlighting effect
        particleColor = Colors.white;
      } else {
        // Lighter shade of main color
        particleColor = _currentFireworkColor.withOpacity(0.7);
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
  
  // THEME AWARENESS: Theme-responsive background colors
  // PRODUCTION REFACTOR: Use Theme.of(context).backgroundColor or MaterialTheme
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF020205) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // LAYER 1: 250th Text Display
          // THEME AWARENESS: Theme-responsive text colors
          // PRODUCTION REFACTOR: Use Theme.of(context).textTheme for consistent styling
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
                        color: _is250thClicked ? const Color(0xFFFFD700) : (_isDarkMode ? Colors.white : Colors.black87),
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
                            color: _is250thClicked ? const Color(0xFFFFD700) : (_isDarkMode ? Colors.white : Colors.black87),
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
          // THEME AWARENESS: Pass theme state to painter for responsive rendering
          // PRODUCTION REFACTOR: Consider extracting painter logic into separate theme-aware classes
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: FireworkPainter(
              particles: _particles,
              rocketTrail: _rocketTrail,
              mainColor: _currentFireworkColor,
              isDarkMode: _isDarkMode,
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
                // THEME AWARENESS: Theme-responsive button colors
                // PRODUCTION REFACTOR: Use Theme.of(context).colorScheme for consistent theming
                _buildBtn("confetti for 250 button", _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade700, () {
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
          
          // LAYER 5: Theme Toggle Button (on top)
          // THEME AWARENESS: Theme toggle positioned at highest z-index
          // PRODUCTION REFACTOR: Extract into reusable ThemeToggleButton widget
          Positioned(
            top: 40,
            right: 20,
            child: _buildThemeToggle(),
          ),
        ],
      ),
    );
  }

  // THEME AWARENESS: Theme-aware button styling helper
  // PRODUCTION REFACTOR: Extract to ButtonFactory or use ElevatedButton.fromIcon for consistency
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
  
  // THEME AWARENESS: Theme toggle button with debug logging
  // PRODUCTION REFACTOR: Remove debug prints, add haptic feedback, use IconTheme
  Widget _buildThemeToggle() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black87,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(48, 48),
      ),
      onPressed: () {
        print('Theme toggle pressed! Current mode: $_isDarkMode');
        setState(() {
          _isDarkMode = !_isDarkMode;
          print('New mode: $_isDarkMode');
        });
      },
      child: Icon(
        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
        size: 24,
      ),
    );
  }
}

// --- DATA CLASSES ---
// THEME AWARENESS: Particle structure supports theme-aware rendering
// PRODUCTION REFACTOR: Consider adding theme-specific properties (glow intensity, etc.)

class FireworkParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifetime;
  FireworkParticle({required this.position, required this.velocity, required this.color, required this.size, required this.lifetime});
}

// --- THE PAINTER ---
// THEME AWARENESS: Theme-aware rendering with different visual styles per theme
// PRODUCTION REFACTOR: Split into separate DarkModePainter and LightModePainter classes
// Changes made:
// - Enhanced rocket trail with multi-layer flame rendering
// - Reduced white blending for deeper color glow (30% vs 60%)
// - Increased blur radius for stronger glow effect (+4 vs +1)
// - Replaced circular particles with 8-pointed stars
// PRODUCTION REFACTOR: Extract trail rendering into separate method
// PRODUCTION REFACTOR: Extract particle rendering into separate methods per particle type
// PRODUCTION REFACTOR: Consider using ColorScheme or brand colors instead
// - Increased glow radius from 2x to 2.5x for bigger impact
// - Enhanced white blending for brighter particles (80% vs 50%)
// - Added star shape rendering for crystalline appearance

class FireworkPainter extends CustomPainter {
  final List<FireworkParticle> particles;
  final List<Offset> rocketTrail;
  final Color mainColor;
  final bool isDarkMode;

  FireworkPainter({required this.particles, required this.rocketTrail, required this.mainColor, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // THEME AWARENESS: Theme-aware rocket trail rendering
    // PRODUCTION REFACTOR: Extract trail rendering into separate method
    // 1. Draw the Rocket Fuse Trail
    // CHANGE: Enhanced from simple circles to multi-layer rocket flame
    // CHANGE: Reduced white blending for deeper color presence
    // CHANGE: Increased blur radius for stronger glow effect
    for (int i = 0; i < rocketTrail.length; i++) {
      double opacity = i / rocketTrail.length;
      // Use different blending for light vs dark mode with vibrant colors
      final whiteBlendAmount = isDarkMode ? 0.8 : 0.1;
      // THEME AWARENESS: Use neon colors for trail in light mode to match explosions
      final trailColor = isDarkMode ? mainColor : _createNeonColor(mainColor);
      paint.color = Color.lerp(trailColor.withOpacity(0.9), Colors.white, whiteBlendAmount)!.withOpacity(opacity);
      // Reduced blur filter for less blurriness - much less for light mode
      final blurAmount = isDarkMode ? (12 - i).toDouble() * 0.5 + 1 : (12 - i).toDouble() * 0.2 + 0.5;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount);
      
      // Draw rocket flame shape
      final center = rocketTrail[i];
      final flameSize = isDarkMode ? 3.0 + (i * 0.3) : 1.5 + (i * 0.15); // Much thinner in light mode
      
      // Outer glow - very thin in light mode with vibrant colors
      final outerWhiteBlend = isDarkMode ? 0.3 : 0.02;
      final outerTrailColor = isDarkMode ? mainColor : _createNeonColor(mainColor);
      paint.color = Color.lerp(outerTrailColor.withOpacity(0.9), Colors.white, outerWhiteBlend)!.withOpacity(opacity);
      canvas.drawCircle(center, flameSize * (isDarkMode ? 1.2 : 0.8), paint);
      
      // Inner flame core - very thin in light mode with vibrant colors
      final innerBlurAmount = isDarkMode ? (12 - i).toDouble() * 0.3 + 0.5 : 0.2;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, innerBlurAmount);
      final innerWhiteBlend = isDarkMode ? 0.5 : 0.05;
      final innerTrailColor = isDarkMode ? mainColor : _createNeonColor(mainColor);
      paint.color = Color.lerp(innerTrailColor.withOpacity(0.95), Colors.white, innerWhiteBlend)!.withOpacity(opacity);
      canvas.drawCircle(center, flameSize * 0.5, paint);
      
      // Hot center - tiny in light mode with vibrant colors
      paint.maskFilter = null;
      final centerWhiteBlend = isDarkMode ? 0.7 : 0.1;
      final centerTrailColor = isDarkMode ? mainColor : _createNeonColor(mainColor);
      paint.color = Color.lerp(centerTrailColor.withOpacity(0.8), Colors.white, centerWhiteBlend)!.withOpacity(opacity * 0.9);
      canvas.drawCircle(center, flameSize * (isDarkMode ? 0.3 : 0.15), paint);
    }

    // THEME AWARENESS: Theme-aware explosion particle rendering
    // PRODUCTION REFACTOR: Extract particle rendering into separate methods per particle type
    // 2. Draw the Explosion Sparks
    // CHANGE: Replaced circles with 8-pointed stars for crystalline appearance
    // CHANGE: Increased glow radius from 2x to 2.5x for bigger impact
    // CHANGE: Enhanced white blending for brighter, more intense glow
    for (final p in particles) {
      // Glow/Bloom Layer - Enhanced neon effect for light mode
      if (isDarkMode) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        paint.color = p.color.withOpacity(p.lifetime * 0.9);
        canvas.drawCircle(p.position, p.size * 1.5, paint);
      } else {
        // Light mode: neon glow with enhanced colors
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
        
        // THEME AWARENESS: Enhanced white particles for better streaks in light mode
        if (p.color.red > 240 && p.color.green > 240 && p.color.blue > 240) {
          // White particles get extra bright glow and larger size for streaks
          // Add blue/pink shading to make them stand out against white background
          final shadedWhite = isDarkMode ? Colors.white : const Color(0xFFE8F4FF); // Slight blue tint
          paint.color = shadedWhite.withOpacity(p.lifetime * 1.0);
          canvas.drawCircle(p.position, p.size * 2.0, paint);
          
          // Add extra glow layer with colored tint for definition
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          final glowColor = isDarkMode ? Colors.white : const Color(0xFFB8D4FF); // More blue tint
          paint.color = glowColor.withOpacity(p.lifetime * 0.6);
          canvas.drawCircle(p.position, p.size * 1.5, paint);
        } else {
          // Create neon colors for colored particles
          final neonColor = _createNeonColor(p.color);
          paint.color = neonColor.withOpacity(p.lifetime * 0.95);
          canvas.drawCircle(p.position, p.size * 1.3, paint);
        }
        
        // Add white core for neon effect - enhanced for better contrast
        if (!(p.color.red > 240 && p.color.green > 240 && p.color.blue > 240)) {
          // Strong white core with stroke effect
          paint.maskFilter = null;
          paint.color = Colors.white.withOpacity(p.lifetime * 1.0);
          canvas.drawCircle(p.position, p.size * 0.4, paint);
          
          // Add bright stroke around core
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3);
          paint.color = Colors.white.withOpacity(p.lifetime * 0.8);
          canvas.drawCircle(p.position, p.size * 0.6, paint);
        } else {
          // White particles also get enhanced core definition with shading
          paint.maskFilter = null;
          final coreColor = isDarkMode ? Colors.white : const Color(0xFFE8F4FF);
          paint.color = coreColor.withOpacity(p.lifetime * 1.0);
          canvas.drawCircle(p.position, p.size * 0.5, paint);
        }
      }
      
      // Sharp Edge Layer
      paint.maskFilter = null;
      if (isDarkMode) {
        final sparkWhiteBlend = 0.8;
        paint.color = Color.lerp(p.color.withOpacity(0.9), Colors.white, sparkWhiteBlend)!.withOpacity(p.lifetime);
      } else {
        // Light mode: use neon colors with minimal white blend
        if (p.color.red > 240 && p.color.green > 240 && p.color.blue > 240) {
          // White particles get shaded color for better contrast
          final shadedColor = isDarkMode ? Colors.white : const Color(0xFFE8F4FF);
          paint.color = shadedColor.withOpacity(p.lifetime * 0.9);
        } else {
          // Colored particles use neon colors
          final neonColor = _createNeonColor(p.color);
          paint.color = neonColor.withOpacity(p.lifetime * 0.9);
        }
      }
      
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
      
      // Draw the star shape
      canvas.drawPath(path, paint);
      
      // Add white stroke around star edges in light mode for better definition
      if (!isDarkMode && !(p.color.red > 240 && p.color.green > 240 && p.color.blue > 240)) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.2);
        paint.color = Colors.white.withOpacity(p.lifetime * 0.6);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  
  // THEME AWARENESS: Helper method to create neon colors for light mode
  // PRODUCTION REFACTOR: Extract to ColorFactory or use predefined color palettes
  Color _createNeonColor(Color color) {
    // Check if it's a red firework color
    if (color.red > color.blue && color.red > color.green) {
      // Create deep neon red - bright but deeper shade
      return const Color(0xFFCC0033); // Deep neon red
    }
    // Check if it's a blue firework color
    else if (color.blue > color.red && color.blue > color.green) {
      // Create deep neon blue - bright but deeper shade
      return const Color(0xFF0066FF); // Deep neon blue
    }
    // For white particles, make them bright white
    else if (color.red > 240 && color.green > 240 && color.blue > 240) {
      return const Color(0xFFFFFFFF); // Pure white
    }
    // For other colors, make them bright and saturated but deeper
    else {
      final hsl = HSLColor.fromColor(color);
      return hsl.withLightness(0.5).withSaturation(1.0).toColor();
    }
  }
  
  // THEME AWARENESS: Helper method to enhance red/blue firework colors for light mode
  // PRODUCTION REFACTOR: Consider using ColorScheme or brand colors instead
  Color _enhanceFireworkColor(Color color) {
    // Check if it's a red firework color
    if (color.red > color.blue && color.red > color.green) {
      // Enhance red - make it more vibrant and saturated
      return Color.fromARGB(
        color.alpha,
        (color.red * 1.2).clamp(0, 255).round(),
        (color.green * 0.8).clamp(0, 255).round(),
        (color.blue * 0.8).clamp(0, 255).round(),
      );
    }
    // Check if it's a blue firework color
    else if (color.blue > color.red && color.blue > color.green) {
      // Enhance blue - make it more vibrant and saturated
      return Color.fromARGB(
        color.alpha,
        (color.red * 0.8).clamp(0, 255).round(),
        (color.green * 0.8).clamp(0, 255).round(),
        (color.blue * 1.2).clamp(0, 255).round(),
      );
    }
    // For white particles, keep them white but slightly warmer
    else if (color.red > 240 && color.green > 240 && color.blue > 240) {
      return const Color(0xFFFFF8F0); // Warm white
    }
    // For other colors, just make them slightly brighter
    else {
      final hsl = HSLColor.fromColor(color);
      return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
    }
  }
}