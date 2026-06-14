import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/notification_service.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';

class SidebarDrawer extends ConsumerWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Drawer(
      backgroundColor: IkoTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: IkoTheme.surfaceContainer)),
              ),
              child: userAsync.when(
                data: (user) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: IkoTheme.surfaceContainerLowest,
                        border: Border.all(color: IkoTheme.primary, width: 2),
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? Image.network(user.avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 32, color: IkoTheme.textSecondary))
                            : const Icon(Icons.person, size: 32, color: IkoTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username,
                      style: TextStyle(
                        fontFamily: IkoTheme.serifFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: IkoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: IkoTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: IkoTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                    ),
                      child: Text(
                        'LVL ${user.level}',
                        style: TextStyle(
                          fontFamily: IkoTheme.monoFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Text('Failed to load profile'),
              ),
            ),
            
            // Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Focus',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.sports_esports_outlined,
                    title: 'Quests',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/quests');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.shield_outlined,
                    title: 'Vault',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/vault');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.insights_outlined,
                    title: 'Growth',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/growth');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.emoji_events_outlined,
                    title: 'Achievements',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/achievements');
                    },
                  ),
                  const Divider(color: IkoTheme.hairline, height: 32, indent: 16, endIndent: 16),
                  _buildDrawerItem(
                    icon: Icons.notifications_active_outlined,
                    title: 'Daily reflection · 8 PM',
                    onTap: () async {
                      Navigator.pop(context);
                      await NotificationService.instance.requestPermission();
                      await NotificationService.instance.scheduleDailyReflection(hour: 20, minute: 0);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Daily reflection scheduled for 20:00')),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Logout
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  context.go('/'); // Return to welcome screen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = IkoTheme.primary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: IkoTheme.sansFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
