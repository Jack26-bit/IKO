class User {
  final int id;
  final String email;
  final String username;
  final int level;
  final int xp;
  final int coins;
  final String rpgClass;
  final int currentStreak;
  final int longestStreak;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.level,
    required this.xp,
    required this.coins,
    required this.rpgClass,
    required this.currentStreak,
    required this.longestStreak,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      level: json['level'],
      xp: json['xp'],
      coins: json['coins'],
      rpgClass: json['rpg_class'],
      currentStreak: json['current_streak'],
      longestStreak: json['longest_streak'],
      avatarUrl: json['avatar_url'],
    );
  }

  int get xpNeededForNextLevel => level * 100;
  double get xpProgress {
    final needed = xpNeededForNextLevel;
    if (needed <= 0) return 0;
    return (xp / needed).clamp(0.0, 1.0);
  }
}
