# flutter-particle-animations
demo for particle animations for mobile app

# 🎆 Flutter Particle Animations

A high-performance particle demo project featuring physics-based fireworks and optimized confetti bursts. This repo is designed to be a reference for integrating pyrotechnic visuals into existing Flutter projects.

---

## 🚀 Features

* **Enhanced Confetti for 250**: Optimized "one-shot" confetti burst with patriotic colors (Red, White, Blue) and faster gravity (0.8).
* **Advanced Physics-Based Fireworks**: Real-time calculated trajectories including:
    * **Multi-Layer Rocket Trail**: Enhanced "comet-style" rising fuse with deep color glow and realistic flame rendering.
    * **Star-Shaped Glow Embers**: 8-pointed crystalline particles with intense white core and enhanced blur aura.
    * **Optimized Physics**: Faster gravity (0.25), quicker fade (0.018), and enhanced visual effects.
    * **Color Variety**: 70% main color, 15% lighter shades, 15% white particles for visual interest.
    * **Offset Launch Positions**: Red fires from left, Blue fires from right for dynamic spread.

---

## 🛠 Integration Guide for Developers

### 1. Dependencies
Add the following to your `pubspec.yaml`:

dependencies:
  confetti: ^0.7.0  # For the standard confetti bursts
  flutter/services: ^0.18.0  # For clipboard functionality (optional)

### 2. Logic & Physics Tuning

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
**FireworkParticle:** Data model for position, velocity, color, size, and lifetime.

**FireworkPainter:** Enhanced Canvas engine featuring:
- Multi-layer rocket flame rendering
- Star-shaped particle system
- Deep color glow with reduced white blending (30% vs 60%)
- Enhanced blur effects (+4 radius vs +1)
- Larger glow radius (2.5x vs 2.0x)

**FireworkShowcase:** Main UI with:
- 250th text with superscript and gold flash effect
- Offset firework launch positions
- Instant confetti response
- Enhanced color system

### ⚙️ Development
Clone the repo: git clone https://github.com/alexkemas/flutter-particle-animations

Get packages: flutter pub get

Run: flutter run

## 🎨 Visual Enhancements

**Deep Color Glow:** Reduced white blending from 60% to 30% for richer, more saturated colors while maintaining brightness.

**Crystalline Particles:** 8-pointed stars create sharp, crystalline appearance vs soft circles.

**Dynamic Launch:** Red fireworks launch from 10% left of center, Blue from 10% right for visual variety.

**Enhanced Confetti:** Faster gravity (0.8) and instant response for snappier user feedback.

**Gold Flash Effect:** 250th text flashes gold (#FFD700) when confetti button is clicked.

Casual Note: The background is set to a deep black (0xFF020205) to maximize the contrast of the enhanced glow particles. The deeper colors and enhanced effects work best against dark backgrounds. For light themes, consider increasing particle opacity or adding a dark overlay.
