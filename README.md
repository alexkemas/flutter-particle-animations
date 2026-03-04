# flutter-particle-animations
demo for particle animations for mobile app

# 🎆 Flutter Particle Animations

A high-performance particle demo project featuring physics-based fireworks and optimized confetti bursts. This repo is designed to be a reference for integrating pyrotechnic visuals into existing Flutter projects.

---

## 🚀 Features

* **Confetti for 250**: Optimized "one-shot" confetti burst with patriotic colors (Red, White, Blue).
* **Physics-Based Fireworks**: Real-time calculated trajectories including:
    * **Rocket Trail**: A "comet-style" rising fuse that matches the explosion color.
    * **Glow Embers**: Dual-layered particles with a hot white core and a blurred color aura.
    * **Realistic Gravity**: Particles drop and fade with air resistance (drag).

---

## 🛠 Integration Guide for Developers

### 1. Dependencies
Add the following to your `pubspec.yaml`:

dependencies:
  confetti: ^0.7.0  # For the standard confetti bursts

### 2. Logic & Physics Tuning

The firework engine is decoupled from the UI. You can find the physics loop in the _updatePhysics() method.

If you need to adjust the "vibe," tweak these constants in the state:

**Gravity (0.12):** Controls the downward pull.

**Air Friction/Drag (0.97):** High values (closer to 1.0) make the explosion spread further; lower values make it feel "heavy."

**Rocket Speed (-10):** Speed of the rising fuse.

**Fade Speed (0.012):** How quickly the embers vanish (lifetime reduction).

### 3. Implementation Patterns

The "Instant" Reset

To ensure the Confetti for 250 button feels responsive when spammed, the controller is reset before being played. This prevents the "lag" of waiting for a previous animation to finish.

// Inside the button onPressed:
_confettiController.stop();
_confettiController.play();

The Glow Effect

The FireworkPainter uses MaskFilter.blur(BlurStyle.normal, 3) to create the glow. This is significantly more performance-efficient than using heavy image assets or complex shaders.

### 📂 Project Structure
**FireworkParticle:** Data model for position, velocity, and lifetime.

**FireworkPainter:** The Canvas engine that renders the glow and the rocket trail using CustomPaint.

**FireworkShowcase:** The main UI containing the Ticker animation loop and button layout.

### ⚙️ Development
Clone the repo: git clone https://github.com/alexkemas/flutter-particle-animations

Get packages: flutter pub get

Run: flutter run

Casual Note: The background is set to a deep black (0xFF020205) to maximize the contrast of the glow particles. If implementing on a light theme, consider increasing the alpha/opacity of the particles in the Painter or adding a darker overlay behind the animation.
