# mathlab: The Ultimate Arithmetic & Analytics Platform 🚀

**mathlab** is a premium, high-performance mental mathematics training ecosystem built with Flutter. It merges rigorous cognitive training with advanced data analytics and a deep, neon-cyberpunk gamification layer.

---

## 🌟 Vision & Impact
In an era of digital distractions, **mathlab** transforms brain training into an addictive, rewarding experience.
- **Cognitive Optimization**: Engineered to improve subitizing, mental calculation speed, and working memory.
- **The Flow State**: Employs a proprietary **Heat Index** and **Dynamic Difficulty Adjustment (DDA)** to maintain the optimal challenge level.
- **Accessibility First**: Includes specialized **Color-Blind Modes** (Protanopia, Deuteranopia, Tritanopia) and a **Focus Mode** for distraction-free learning.

---

## 🎮 Game Modes & Features

### 1. Mastery Campaign
- **100+ Levels**: Progress through chapters with increasing complexity across Addition, Subtraction, Multiplication, and Division.
- **Star System**: Earn up to 3 stars per level based on accuracy and speed.
- **Boss Nodes**: Specialized high-stakes levels that unlock new chapters and provide massive XP boosts.

### 2. Arcade Arena
- **Time Attack**: 60-90 second sprints to maximize points.
- **Sudden Death**: One mistake and the session terminates—pure precision training.
- **Zen Mode**: Stress-free practice without timers or scoring for relaxed learning.
- **Endless Mode**: Complexity scales infinitely as long as your accuracy holds.
- **Flash Math**: Rapid-fire visual challenges focusing on number and operator recognition.

### 3. Puzzles & Logic
- **Cross Numbers**: Mathematical crossword puzzles where every intersecting equation must be balanced correctly.
- **Logic Riddles**: Lateral thinking math problems that challenge your reasoning beyond simple calculation.
- **Visual Counting**: Improving subitizing by rapidly counting shapes and patterns.

### 4. Practice Lab & Custom Mix
- **Practice Mode**: Target specific skills with adjustable number ranges and operation types.
- **Custom Mix Generator**: A procedural challenge engine. Define your own operation matrix, difficulty level, and session duration.
- **Built-in Calculator**: A comprehensive arithmetic tool featuring both Basic and Scientific modes with a persistent calculation history.

---

## 🚀 Key Systems: How It Works

### The Heat & Fever System
- **Real-Time Intensity**: The UI reacts to your performance. Correct answers increase the **Heat Index**, while idle time or errors cause it to decay.
- **Fever Mode**: Reaching maximum Heat triggers "Fever Mode," doubling points and XP, and activating explosive neon visual effects and particle systems.
- **Engine Intensity**: As the Heat Index climbs, the "Engine Intensity" shifts from Normal to Critical, providing visceral feedback on your performance.

### Intelligence Center (Analytics)
- **Neural Efficiency Index (NEI)**: A proprietary metric that analyzes the relationship between your accuracy and response speed.
- **Deep Metrics**: Track your performance trends through interactive charts, covering session history, operation mastery, and speed analytics.
- **Export Protocols**: Generate professional **PDF Progress Reports** or share high-quality **Performance Snapshots** to document your mathematical journey.

### Gamification & RPG Layer
- **Avatar Shop**: Spend "Math Points" to unlock and equip rare, epic, and legendary avatars with distinct cyberpunk designs.
- **XP & Leveling**: A full progression system where every session contributes to your global Math Level.
- **Achievement System**: 50+ unique achievements (e.g., "Speed Demon", "Math Master", "Grid Explorer") with tiered rewards.
- **Daily Missions**: Procedurally generated daily and weekly tasks to keep your training consistent.

---

## 🛠 Technical Architecture

### Tech Stack
- **Framework**: Flutter (Optimized for 60/120 FPS)
- **State Management**: Riverpod (Highly reactive, modular architecture)
- **Persistence**: SQLite (Local storage for session history, level progress, and profile data)
- **Charts**: `fl_chart` for high-performance data visualization
- **Animations**: `flutter_animate` and custom `Canvas` particle systems
- **Localization**: Full English & Swahili support with dynamic language switching

### Project Structure
```text
lib/
├── core/                   # Core utilities, theme, and shared components
│   ├── components/         # Reusable UI widgets (Glassmorphic cards, Neon buttons)
│   ├── theme/              # Neon-Cyberpunk & Solar theme configurations
│   └── utils/              # Game engines, flow optimizers, and math generators
├── features/               # Feature-based modular architecture
│   ├── arcade/             # Arcade mode logic and session handling
│   ├── campaign/           # Level progression map and milestone logic
│   ├── calculator/         # Basic & Scientific calculator implementation
│   ├── custom_mix/         # Procedural challenge generator
│   ├── home/               # Central dashboard and navigation hub
│   ├── practice/           # Focused training lab
│   ├── profile/            # User settings, avatars, and shop system
│   ├── puzzles/            # Cross-numbers and logic riddle engines
│   └── reports/            # Data analytics visualization and PDF/Image export
├── l10n/                   # Localization (ARB files)
└── main.dart               # App entry point and global providers
```

---

## 🎨 UI/UX Philosophy
- **Glassmorphism**: Premium "frosted glass" interfaces with deep blur effects and vibrant accents.
- **Haptic Engineering**: Precise tactile feedback for every keypress and milestone, creating a "mechanical" feel.
- **Dual Visual Modes**: Seamlessly switch between the **Cyber** (Neon Dark) and **Solar** (Clean Light) visual themes.

---

## 🚀 Getting Started

1.  **Environment**: Ensure you have Flutter 3.x installed.
2.  **Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Localization**: Generate the localized code before running.
    ```bash
    flutter gen-l10n
    ```
4.  **Run**:
    ```bash
    flutter run --release
    ```

---
Developed by **mathlab Team** – *Quantifying Intelligence, One Equation at a Time.*
