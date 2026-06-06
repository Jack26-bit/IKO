import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/quest_provider.dart';

class _RecentActivity {
  final String title;
  final IconData icon;
  final String category;
  final String duration;
  const _RecentActivity({required this.title, required this.icon, required this.category, required this.duration});
}

enum ActivityModalMode { logActivity, createQuest }

class LogActivityModal extends ConsumerStatefulWidget {
  final ActivityModalMode mode;

  const LogActivityModal({super.key, this.mode = ActivityModalMode.logActivity});

  static void show(
    BuildContext context, {
    ActivityModalMode mode = ActivityModalMode.logActivity,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => LogActivityModal(mode: mode),
    );
  }

  @override
  ConsumerState<LogActivityModal> createState() => _LogActivityModalState();
}

class _LogActivityModalState extends ConsumerState<LogActivityModal> {
  String selectedCategory = 'Focus';
  String selectedDuration = '45m';
  double xpValue = 100;
  int selectedRecentIndex = -1;
  bool _isSaving = false;

  final _titleController = TextEditingController();
  final _writeUpController = TextEditingController();

  final List<_RecentActivity> _recents = const [
    _RecentActivity(title: 'Deep Work', icon: Icons.center_focus_strong, category: 'Focus', duration: '1h'),
    _RecentActivity(title: 'Mobility', icon: Icons.self_improvement, category: 'Health', duration: '30m'),
    _RecentActivity(title: 'Review', icon: Icons.analytics_outlined, category: 'Growth', duration: '15m'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _writeUpController.dispose();
    super.dispose();
  }

  String _resolveQuestTitle() {
    final typed = _titleController.text.trim();
    if (typed.isNotEmpty) return typed;
    if (selectedRecentIndex >= 0 && selectedRecentIndex < _recents.length) {
      return _recents[selectedRecentIndex].title;
    }
    return 'Logged Activity';
  }

  @override
  Widget build(BuildContext context) {
    final questTitle = _resolveQuestTitle();
    final isCreateQuest = widget.mode == ActivityModalMode.createQuest;
    final saveLabel = isCreateQuest
        ? 'CREATE QUEST  ·  $questTitle'
        : 'SAVE  ·  $questTitle  ·  +${xpValue.round()} XP';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCreateQuest ? 'New Quest' : 'Log Activity',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
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

              const Text(
                'QUEST TITLE',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Name your activity or quest...',
                  hintStyle: const TextStyle(color: IkoTheme.textSecondary),
                  filled: true,
                  fillColor: IkoTheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: IkoTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'RECENTS',
                style: TextStyle(
                  fontFamily: 'Geist',
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
                            _titleController.text = _recents[i].title;
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
                              color: isSelected ? IkoTheme.primary : const Color(0xFFE2E2E2),
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
                                  fontFamily: 'Playfair Display',
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

              const Text(
                'CATEGORY',
                style: TextStyle(
                  fontFamily: 'Geist',
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DURATION',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: IkoTheme.textSecondary,
                    ),
                  ),
                  Text(
                    selectedDuration,
                    style: const TextStyle(
                      fontFamily: 'Inter',
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
                            fontFamily: 'Inter',
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'XP REWARD',
                    style: TextStyle(
                      fontFamily: 'Geist',
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
                      style: const TextStyle(
                        fontFamily: 'Geist',
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
                  value: xpValue.clamp(0, 500),
                  min: 0,
                  max: 500,
                  onChanged: (v) => setState(() => xpValue = v.roundToDouble()),
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

              const Text(
                'WRITE-UP',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _writeUpController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Brief reflections or outcomes...',
                  hintStyle: const TextStyle(color: IkoTheme.textSecondary),
                  filled: true,
                  fillColor: IkoTheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: IkoTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          try {
                            final title = _resolveQuestTitle();
                            final description = _writeUpController.text.trim().isEmpty
                                ? null
                                : _writeUpController.text.trim();

                            if (isCreateQuest) {
                              await ref.read(questProvider.notifier).createQuest({
                                'title': title,
                                'description': description,
                                'category': selectedCategory,
                                'difficulty': 'medium',
                                'xp_reward': xpValue.toInt(),
                              });
                            } else {
                              await ref.read(questProvider.notifier).logActivity(
                                title: title,
                                description: description,
                                category: selectedCategory,
                                xpReward: xpValue.toInt(),
                              );
                            }
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to save activity: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IkoTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          saveLabel,
                          style: const TextStyle(
                            fontFamily: 'Geist',
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
            color: isSelected ? IkoTheme.primary : const Color(0xFFE2E2E2),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? Colors.white : IkoTheme.primary,
          ),
        ),
      ),
    );
  }
}
