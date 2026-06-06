# ⚔️ IKO — Gamified Life Reminder App

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-brightgreen?style=for-the-badge&logo=android" />
  <img src="https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/Backend-Python-3776AB?style=for-the-badge&logo=python" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?style=for-the-badge&logo=sqlite" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" />
</p>

<p align="center">
  <strong>Turn your daily tasks into epic quests. Level up your real life.</strong>
</p>

---

## 🧠 What is IKO?

**IKO** is a mobile productivity app that transforms real-life habits and tasks into a role-playing game (RPG). Instead of a boring to-do list, your tasks become **Quests**. Complete them to earn **XP**, **Coins**, and **Achievement Badges** — and watch your character grow as your productivity does.

Whether you're going to the gym, studying for exams, staying hydrated, or sleeping on time — IKO makes every habit feel like a game worth playing.

---

## ✨ Features

### ⚔️ Quest System
Create, edit, and complete quests based on your real-life goals. Every quest has a difficulty tier, XP/coin reward, due time, and optional repeat schedule.

| Difficulty | XP Reward | Coin Reward |
|------------|-----------|-------------|
| Easy       | 20 XP     | 10 Coins    |
| Medium     | 50 XP     | 25 Coins    |
| Hard       | 100 XP    | 50 Coins    |
| Epic       | 250 XP    | 100 Coins   |

### 🧑‍🎮 User Profile & Leveling
- Customizable username and avatar
- XP bar with automatic level-up system
- Coin balance, current streak, and total quests completed

### 🔥 Streak System
Build momentum with consecutive completions. Longer streaks earn bonus XP and coins.

- 3-Day Streak
- 7-Day Streak
- 30-Day Streak
- 100-Day Streak

### 🐉 Boss Battle Mode
Turn your worst habits into monsters and fight them with productivity.

| Quest Completed | Damage Dealt |
|-----------------|--------------|
| Gym Quest       | 50 Damage    |
| Study Quest     | 40 Damage    |
| Reading Quest   | 20 Damage    |

Defeat bosses like the **Laziness Dragon**, **Procrastination King**, and **Sleep Demon** to earn rare rewards.

### 🏆 Achievement System
Unlock badges that celebrate your consistency and dedication.

- 🎯 First Quest Completed
- 💪 Gym Warrior
- 📚 Study Master
- 🌅 Early Bird
- 🏅 Productivity Legend

### 🎯 Daily Challenges
Receive randomly generated daily missions to keep things fresh. Complete them for bonus XP, coins, and achievement progress.

### 🔗 Quest Chains
Group multiple quests into a single larger mission. Completing all sub-quests earns a bonus reward.

**Example — Mission: Become Fit**
1. Go to Gym
2. Drink 3L Water
3. Walk 10,000 Steps
4. Sleep Before 11 PM

### 📊 Statistics Dashboard
Track your growth over time:
- Total XP earned
- Quests completed
- Weekly / monthly progress
- Habit consistency graphs
- Level history

### 🛍️ Rewards Shop
Spend coins on cosmetic upgrades:
- Character skins and avatars
- App themes
- Pets
- Custom icons

### 🔔 Reminder System
- Push notifications for upcoming quests
- Daily reminders
- Missed-task alerts
- Custom reminder times

---

## 🗂️ Quest Categories

Users can organize quests into built-in or custom categories:

`Fitness` · `Study` · `Work` · `Health` · `Personal Growth` · `Finance` · `Relationships` · `Hobbies` · `Custom`

---

## 🏗️ Architecture

```
IKO/
├── frontend/          # Flutter (Dart) mobile app
│   ├── lib/
│   │   ├── screens/   # UI screens (home, quests, profile, shop)
│   │   ├── models/    # Data models (Quest, User, Achievement)
│   │   ├── services/  # API calls, notifications
│   │   └── widgets/   # Reusable UI components
│   └── pubspec.yaml
│
└── backend/           # Python REST API
    ├── auth/          # Authentication module
    ├── quests/        # Quest management
    ├── xp_engine/     # XP calculation and leveling
    ├── achievements/  # Achievement tracking
    ├── notifications/ # Push notification service
    ├── stats/         # Statistics module
    └── db/            # SQLite database layer
```

---

## 🛠️ Tech Stack

| Layer        | Technology          |
|--------------|---------------------|
| Frontend     | Flutter (Dart)      |
| Backend      | Python              |
| Database     | SQLite              |
| Notifications| Local Push (Flutter)|
| Platform     | Android             |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (≥ 3.x)
- Python 3.10+
- Android Studio or a physical Android device

### 1. Clone the repository

```bash
git clone https://github.com/Jack26-bit/IKO.git
cd IKO
```

### 2. Set up the backend

```bash
cd backend
pip install -r requirements.txt
python main.py
```

### 3. Set up the frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## 📸 UI Style

- 🌑 Dark mode by default
- 🎮 RPG-inspired visuals and iconography
- ✨ Animated XP bar and achievement popups
- 📱 Clean, intuitive mobile navigation
- 🎨 Smooth transitions throughout

---

## 🗺️ Roadmap

- [x] Quest system (create, edit, delete, complete)
- [x] XP engine and leveling
- [x] Streak tracking
- [ ] Boss Battle Mode
- [ ] Daily Challenges
- [ ] Rewards Shop
- [ ] Statistics Dashboard
- [ ] Quest Chains
- [ ] Cloud sync / multi-device support
- [ ] iOS support

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

1. Fork the repo
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a pull request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

Copyright © 2026 Neeraj Kiran Janakula

---

<p align="center">
  Made with ❤️ and too many unfinished quests.
</p>
