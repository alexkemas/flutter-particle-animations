# flutter-particle-animations
demo for particle animations for mobile app

# 🎆 Flutter Particle Animations

A high-performance particle demo project featuring physics-based fireworks, optimized confetti bursts, and **theme-aware rendering**. This repo is designed to be a reference for integrating pyrotechnic visuals into existing Flutter projects with support for both light and dark themes.

---

## 🚀 Features

* **Theme-Aware Rendering**: Full light/dark mode support with optimized visual effects for each theme
* **Enhanced Confetti for 250**: Optimized "one-shot" confetti burst with patriotic colors (Red, White, Blue) and faster gravity (0.8).
* **Advanced Physics-Based Fireworks**: Real-time calculated trajectories including:
    * **Multi-Layer Rocket Trail**: Enhanced "comet-style" rising fuse with theme-aware color rendering.
    * **Star-Shaped Glow Embers**: 8-pointed crystalline particles with theme-specific glow effects.
    * **Optimized Physics**: Faster gravity (0.25), quicker fade (0.018), and enhanced visual effects.
    * **Theme-Aware Particle System**: Different particle distributions and colors for light vs dark modes.
    * **Offset Launch Positions**: Red fires from left, Blue fires from right for dynamic spread.

---

## 🌓 Theme System

### Dark Mode Features
* **Deep Color Glow**: Rich, saturated colors with strong white blending (80%)
* **Enhanced Blur Effects**: Strong glow with blur radius of 2.0
* **Original Aesthetic**: Maintains the classic firework appearance with ethereal glowing

### Light Mode Features
* **Neon Color System**: Deep neon red (#CC0033) and neon blue (#0066FF) for better contrast
* **Optimized White Particles**: Blue-tinted white particles (#E8F4FF, #B8D4FF) for visibility against light backgrounds
* **Reduced Blur**: Thinner trails and less blur for defined appearance
* **Enhanced Particle Distribution**: 25% white particles (vs 15% in dark mode) for better highlighting
* **White Core Effects**: Strong white cores and stroke effects for particle definition

### Theme Toggle
* **Position**: Top-right corner with highest z-index
* **Visual Feedback**: Sun/moon icons with theme-aware styling
* **Instant Switching**: Seamless theme transitions without app restart

---

## 🛠 Integration Guide for Developers

### 1. Dependencies
Add the following to your `pubspec.yaml`:

dependencies:
  confetti: ^0.7.0  # For the standard confetti bursts
  flutter/services: ^0.18.0  # For clipboard functionality (optional)

### 2. Theme-Aware Implementation

**Theme State Management**

Add theme state to your widget:

```dart
// Theme state for light/dark mode toggle
bool _isDarkMode = true;

// Theme toggle button
Widget _buildThemeToggle() {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      foregroundColor: _isDarkMode ? Colors.white : Colors.black87,
      shape: const CircleBorder(),
    ),
    onPressed: () {
      setState(() {
        _isDarkMode = !_isDarkMode;
      });
    },
    child: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
  );
}
```

**Theme-Aware Particle Generation**

Different particle distributions for light vs dark modes:

```dart
// Enhanced particle variety for light mode
int whiteParticleThreshold = _isDarkMode ? 85 : 75; // More white in light mode

if (index < 60) {
  particleColor = mainColor;
} else if (index < whiteParticleThreshold) {
  particleColor = Colors.white; // More white particles in light mode
} else {
  particleColor = mainColor.withOpacity(0.7);
}
```

**Theme-Aware Painter**

Pass theme state to custom painter:

```dart
CustomPaint(
  painter: FireworkPainter(
    particles: _particles,
    rocketTrail: _rocketTrail,
    mainColor: _currentFireworkColor,
    isDarkMode: _isDarkMode, // Theme parameter
  ),
)
```

**Neon Color System for Light Mode**

Create vibrant colors for light backgrounds:

```dart
Color _createNeonColor(Color color) {
  if (color.red > color.blue && color.red > color.green) {
    return const Color(0xFFCC0033); // Deep neon red
  } else if (color.blue > color.red && color.blue > color.green) {
    return const Color(0xFF0066FF); // Deep neon blue
  }
  return Colors.white;
}
```

### 3. Logic & Physics Tuning

The firework engine is decoupled from the UI. You can find the physics loop in the _updatePhysics() method.

**Enhanced Physics Constants:**

**Gravity (0.25):** Increased from 0.12 for 2x faster drop effect.

**Air Friction/Drag (0.97):** Maintained for natural "flower" spread pattern.

**Rocket Speed (-15):** Increased from -10 for 50% faster launch speed.

**Fade Speed (0.018):** Increased from 0.012 for 50% quicker particle fade.

**Confetti Gravity (0.8):** Much faster falling for snappier timing.

### 3. Implementation Patterns

**Instant Confetti Response**

The confetti controller plays directly without stop/start delay for instant response:

// Inside the button onPressed:
_confettiController.play();  // No .stop() needed

**Enhanced Glow System**

The FireworkPainter uses multi-layer rendering with enhanced blur effects:

// Rocket trail: Multi-layer flame with deep color
paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 4);  // Increased from 1

// Particle glow: Larger radius with enhanced white blending
canvas.drawCircle(p.position, p.size * 2.5, paint);  // Increased from 2.0

**Star-Shaped Particles**

Particles are rendered as 8-pointed stars instead of circles for crystalline appearance:

// Creates star path with alternating outer/inner points
for (int i = 0; i < 8; i++) {
  final radius = i % 2 == 0 ? outerRadius : innerRadius;
  // ... star path generation
}

**Color System**

Enhanced color variety creates visual interest:

// 70% main color, 15% lighter shades, 15% white particles
if (index < 70) {
  particleColor = mainColor;  // Deep red (#660000) or bright blue (#0040FF)
} else if (index < 85) {
  particleColor = mainColor.withOpacity(0.7);  // Lighter shades
} else {
  particleColor = Colors.white;  // Sparkle particles
}

### 📂 Project Structure
**FireworkParticle:** Data model for position, velocity, color, size, and lifetime with theme-aware rendering support.

**FireworkPainter:** Enhanced Canvas engine featuring:
- **Theme-Aware Rendering**: Different visual styles for light vs dark modes
- **Multi-layer rocket flame rendering** with neon colors in light mode
- **Star-shaped particle system** with enhanced white cores
- **Theme-Specific Blur Effects**: Strong blur in dark mode, reduced in light mode
- **Neon Color System**: Deep neon red (#CC0033) and blue (#0066FF) for light mode
- **Enhanced White Particles**: Blue-tinted whites (#E8F4FF, #B8D4FF) for light mode visibility

**FireworkShowcase:** Main UI with:
- **Theme Toggle Button**: Positioned in top-right corner with sun/moon icons
- **Theme-Aware Backgrounds**: Dark (#020205) and light (#F5F5F5) themes
- **250th text** with theme-responsive colors and gold flash effect
- **Offset firework launch positions** with theme-aware trail colors
- **Instant confetti response** with theme integration
- **Enhanced color system** with neon colors for light mode

### ⚙️ Development
Clone the repo: git clone https://github.com/alexkemas/flutter-particle-animations

Get packages: flutter pub get

Run: flutter run

## 🎨 Visual Enhancements

### Theme-Aware Visual System
**Dark Mode Enhancements:**
- **Deep Color Glow**: Rich, saturated colors with strong white blending (80%)
- **Enhanced Blur Effects**: Strong glow with blur radius of 2.0 for ethereal appearance
- **Classic Aesthetic**: Maintains original firework appearance with beautiful glowing

**Light Mode Optimizations:**
- **Neon Color Palette**: Deep neon red (#CC0033) and neon blue (#0066FF) for contrast
- **Optimized White Particles**: Blue-tinted shading for visibility against light backgrounds
- **Reduced Blur Effects**: Thinner trails and defined appearance (blur radius 1.8)
- **Enhanced Particle Definition**: White cores and stroke effects for better contrast
- **Vibrant Trail Colors**: Rocket trails use neon colors to match explosion particles

**Cross-Theme Features:**
- **Crystalline Particles**: 8-pointed stars create sharp, crystalline appearance
- **Dynamic Launch**: Red fireworks from left, Blue from right for visual variety
- **Enhanced Confetti**: Faster gravity (0.8) and instant response
- **Gold Flash Effect**: 250th text flashes gold (#FFD700) with theme integration

**Technical Notes:**
- **Background Optimization**: Deep black (0xFF020205) for dark mode, light gray (#F5F5F5) for light mode
- **Particle Distribution**: 60% main color, 25% white (light mode) or 15% white (dark mode), 15% lighter shades
- **Performance**: Theme switching is instant without app restart
- **Contrast Optimization**: Each theme optimized for maximum visual impact
