import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
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
                        style: const TextStyle(
                          fontFamily: 'Geist',
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
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      // TODO: Navigate to Edit Profile if implemented
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
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
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
