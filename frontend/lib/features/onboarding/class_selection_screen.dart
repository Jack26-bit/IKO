import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme.dart';

class ClassSelectionScreen extends StatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _classes = [
    {
      'title': 'Scholar',
      'desc': 'Focus on deep learning, research, and expanding your knowledge vault.',
      'icon': Icons.menu_book,
      'bonus': 'Intellect +5'
    },
    {
      'title': 'Warrior',
      'desc': 'Prioritize physical fitness, discipline, and tackling difficult quests head-on.',
      'icon': Icons.fitness_center, // using fitness_center instead of swords for standard Material Icons
      'bonus': 'Strength +5'
    },
    {
      'title': 'Strategist',
      'desc': 'Master planning, resource management, and optimizing daily routines.',
      'icon': Icons.account_tree, // chess alternative
      'bonus': 'Focus +5'
    },
    {
      'title': 'Monk',
      'desc': 'Cultivate mindfulness, emotional intelligence, and inner peace.',
      'icon': Icons.self_improvement,
      'bonus': 'Spirit +5'
    },
    {
      'title': 'Creator',
      'desc': 'Harness inspiration to build, design, and express. Turn your workspace into a studio.',
      'icon': Icons.palette,
      'bonus': 'Craft +5'
    },
  ];

  void _onClassSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Simulate API call and redirect to dashboard
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IkoTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'ARCHETYPE SELECTION',
                    style: TextStyle(
                      fontFamily: IkoTheme.monoFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: IkoTheme.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Choose Your Path',
                    style: TextStyle(
                      fontFamily: IkoTheme.serifFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: IkoTheme.primary,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 800.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Select the class that best aligns with your current life focus.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: IkoTheme.sansFamily,
                      fontSize: 16,
                      color: IkoTheme.textSecondary,
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 800.ms),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final cls = _classes[index];
                  final isSelected = _selectedIndex == index;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () => _onClassSelected(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: IkoTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? IkoTheme.primary : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.04),
                              blurRadius: isSelected ? 40 : 20,
                              offset: Offset(0, isSelected ? 12 : 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? IkoTheme.primary : IkoTheme.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cls['icon'],
                                color: isSelected ? Colors.white : IkoTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              cls['title'],
                              style: TextStyle(
                                fontFamily: IkoTheme.serifFamily,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: IkoTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cls['desc'],
                              style: TextStyle(
                                fontFamily: IkoTheme.sansFamily,
                                fontSize: 14,
                                color: IkoTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cls['bonus'],
                                  style: TextStyle(
                                    fontFamily: IkoTheme.monoFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: IkoTheme.textSecondary,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, color: IkoTheme.primary, size: 20)
                                else
                                  const Icon(Icons.arrow_forward, color: IkoTheme.textSecondary, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: Duration(milliseconds: 400 + (index * 100))).fadeIn().slideY(begin: 0.2, end: 0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
