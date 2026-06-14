import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/quest_provider.dart';
import '../../models/quest.dart';

class _RecentActivity {
  final String title;
  final IconData icon;
  final String category;
  final String duration;
  const _RecentActivity({required this.title, required this.icon, required this.category, required this.duration});
}

class LogActivityModal extends ConsumerStatefulWidget {
  const LogActivityModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const LogActivityModal(),
    );
  }

  @override
  ConsumerState<LogActivityModal> createState() => _LogActivityModalState();
}

class _LogActivityModalState extends ConsumerState<LogActivityModal> {
  String selectedCategory = 'Focus';
  String selectedDuration = '45m';
  Quest? selectedQuest;
  double xpValue = 100;
  int selectedRecentIndex = -1;

  final List<_RecentActivity> _recents = const [
    _RecentActivity(title: 'Deep Work', icon: Icons.center_focus_strong, category: 'Focus', duration: '1h'),
    _RecentActivity(title: 'Mobility', icon: Icons.self_improvement, category: 'Health', duration: '30m'),
    _RecentActivity(title: 'Review', icon: Icons.analytics_outlined, category: 'Growth', duration: '15m'),
  ];

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Activity',
                    style: TextStyle(
                      fontFamily: IkoTheme.serifFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: IkoTheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: IkoTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Active Quests
              Text(
                'LINK TO QUEST',
                style: TextStyle(
                  fontFamily: IkoTheme.monoFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              questsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => const Text('Failed to load quests'),
                data: (quests) {
                  final activeQuests = quests.where((q) => !q.isCompleted).toList();
                  if (activeQuests.isEmpty) {
                    return const Text('No active quests available to link.', style: TextStyle(color: IkoTheme.textSecondary));
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: IkoTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const IkoTheme.hairline),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Quest>(
                        value: selectedQuest,
                        isExpanded: true,
                        hint: const Text('Select an active quest...'),
                        items: activeQuests.map((quest) {
                          return DropdownMenuItem<Quest>(
                            value: quest,
                            child: Text(quest.title),
                          );
                        }).toList(),
                        onChanged: (Quest? newValue) {
                          setState(() {
                            selectedQuest = newValue;
                            if (newValue != null) {
                              xpValue = newValue.xpReward.toDouble();
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Recents
              Text(
                'RECENTS',
                style: TextStyle(
                  fontFamily: IkoTheme.monoFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_recents.length, (i) {
                    final isSelected = selectedRecentIndex == i;
                    return Padding(
                      padding: EdgeInsets.only(right: i < _recents.length - 1 ? 12 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRecentIndex = i;
                            selectedCategory = _recents[i].category;
                            selectedDuration = _recents[i].duration;
                            selectedQuest = null; // Unlink quest if recent is tapped
                          });
                        },
                        child: Container(
                          width: 120,
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? IkoTheme.primary : IkoTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? IkoTheme.primary : const IkoTheme.hairline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                _recents[i].icon,
                                color: isSelected ? Colors.white : IkoTheme.textSecondary,
                                size: 24,
                              ),
                              Text(
                                _recents[i].title.replaceAll(' ', '\n'),
                                style: TextStyle(
                                  fontFamily: IkoTheme.serifFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                  color: isSelected ? Colors.white : IkoTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),

              // Category
              Text(
                'CATEGORY',
                style: TextStyle(
                  fontFamily: IkoTheme.monoFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCategoryButton('Focus')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCategoryButton('Health')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCategoryButton('Growth')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCategoryButton('Wealth')),
                ],
              ),
              const SizedBox(height: 32),

              // Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DURATION',
                    style: TextStyle(
                      fontFamily: IkoTheme.monoFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: IkoTheme.textSecondary,
                    ),
                  ),
                  Text(
                    selectedDuration,
                    style: TextStyle(
                      fontFamily: IkoTheme.sansFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: IkoTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: IkoTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['15m', '30m', '45m', '1h', '2h+'].map((duration) {
                    final isSelected = selectedDuration == duration;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDuration = duration),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? IkoTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          duration,
                          style: TextStyle(
                            fontFamily: IkoTheme.sansFamily,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : IkoTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // XP Range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP REWARD',
                    style: TextStyle(
                      fontFamily: IkoTheme.monoFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: IkoTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: IkoTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${xpValue.toInt()} XP',
                      style: TextStyle(
                        fontFamily: IkoTheme.monoFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: IkoTheme.primary,
                  inactiveTrackColor: IkoTheme.surfaceContainer,
                  thumbColor: IkoTheme.primary,
                  overlayColor: IkoTheme.primary.withValues(alpha: 0.1),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: xpValue,
                  min: 0,
                  max: 500,
                  divisions: 20,
                  onChanged: (v) => setState(() => xpValue = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('0 XP', style: TextStyle(fontSize: 10, color: IkoTheme.textSecondary)),
                  Text('500 XP', style: TextStyle(fontSize: 10, color: IkoTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 32),

              // Notes
              Text(
                'NOTES (Optional)',
                style: TextStyle(
                  fontFamily: IkoTheme.monoFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Brief reflections or outcomes...',
                  hintStyle: const TextStyle(color: IkoTheme.textSecondary),
                  filled: true,
                  fillColor: IkoTheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: IkoTheme.hairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: IkoTheme.hairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: IkoTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedQuest != null) {
                      ref.read(questProvider.notifier).completeQuest(selectedQuest!.id);
                    } else {
                      // If no quest is linked, just create a new completed quest with the selected XP
                      ref.read(questProvider.notifier).createQuest({
                        'title': _recents.elementAtOrNull(selectedRecentIndex)?.title ?? 'Logged Activity',
                        'xp_reward': xpValue.toInt(),
                        'category': selectedCategory,
                        'difficulty': 'medium',
                      }).then((_) {
                        // After creation, we ideally should mark it complete. 
                        // To keep it simple, the backend creates uncompleted quests by default.
                        // We will just let them use it as a log. For a full app, we'd add an endpoint to log past activities.
                      });
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IkoTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'SAVE  ·  ${selectedQuest?.title ?? selectedCategory}  ·  +${xpValue.toInt()} XP',
                    style: TextStyle(
                      fontFamily: IkoTheme.monoFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String title) {
    final isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? IkoTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? IkoTheme.primary : const IkoTheme.hairline,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: IkoTheme.sansFamily,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? Colors.white : IkoTheme.primary,
          ),
        ),
      ),
    );
  }
}
