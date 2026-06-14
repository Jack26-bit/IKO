import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notification_service.dart';
import '../../core/theme.dart';
import '../../models/quest.dart';
import '../../providers/quest_provider.dart';

/// Editorial bottom sheet for creating OR editing a quest.
///
/// Usage:
///   QuestComposerSheet.show(context);               // create
///   QuestComposerSheet.show(context, quest: q);     // edit
class QuestComposerSheet extends ConsumerStatefulWidget {
  final Quest? quest;
  const QuestComposerSheet({super.key, this.quest});

  static Future<void> show(BuildContext context, {Quest? quest}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: IkoTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => QuestComposerSheet(quest: quest),
    );
  }

  @override
  ConsumerState<QuestComposerSheet> createState() => _QuestComposerSheetState();
}

class _QuestComposerSheetState extends ConsumerState<QuestComposerSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  String _category = 'Focus';
  String _difficulty = 'medium';
  int _xp = 50;
  int _coins = 10;
  bool _recurring = false;
  String _schedule = 'daily';
  DateTime? _remindAt;
  bool _submitting = false;

  static const Map<String, int> _xpByDifficulty = {
    'easy': 25,
    'medium': 50,
    'hard': 100,
    'epic': 250,
  };
  static const Map<String, int> _coinsByDifficulty = {
    'easy': 10,
    'medium': 25,
    'hard': 50,
    'epic': 100,
  };

  static const List<String> _categories = [
    'Focus', 'Health', 'Growth', 'Wealth', 'Craft', 'Spirit', 'General'
  ];
  static const List<String> _difficulties = ['easy', 'medium', 'hard', 'epic'];

  bool get _isEdit => widget.quest != null;

  @override
  void initState() {
    super.initState();
    final q = widget.quest;
    _titleCtrl = TextEditingController(text: q?.title ?? '');
    _descCtrl = TextEditingController(text: q?.description ?? '');
    if (q != null) {
      _category = q.category;
      _difficulty = q.difficulty.toLowerCase();
      _xp = q.xpReward;
      _coins = q.coinReward;
      _recurring = q.isRecurring;
      _schedule = q.recurringSchedule ?? 'daily';
      _remindAt = q.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyDifficultyDefaults(String d) {
    setState(() {
      _difficulty = d;
      _xp = _xpByDifficulty[d] ?? _xp;
      _coins = _coinsByDifficulty[d] ?? _coins;
    });
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _remindAt ?? now.add(const Duration(hours: 2)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_remindAt ?? now.add(const Duration(hours: 2))),
    );
    if (time == null) return;
    setState(() {
      _remindAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _submitting) return;
    setState(() => _submitting = true);

    final payload = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'category': _category,
      'difficulty': _difficulty,
      'xp_reward': _xp,
      'coin_reward': _coins,
      'is_recurring': _recurring,
      'recurring_schedule': _recurring ? _schedule : null,
      'due_date': _remindAt?.toUtc().toIso8601String(),
    };

    try {
      Quest saved;
      if (_isEdit) {
        saved = await ref.read(questProvider.notifier).updateQuest(widget.quest!.id, payload);
      } else {
        saved = await ref.read(questProvider.notifier).createQuest(payload);
      }

      if (_remindAt != null) {
        await NotificationService.instance.requestPermission();
        await NotificationService.instance.scheduleQuestReminder(
          questId: saved.id,
          title: saved.title,
          body: 'Reminder · ${saved.category} · +${saved.xpReward} XP',
          when: _remindAt!,
        );
      } else {
        await NotificationService.instance.cancelForQuest(saved.id);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save quest: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: IkoTheme.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(_isEdit ? 'EDIT QUEST' : 'NEW QUEST',
                      style: IkoTheme.mono(letterSpacing: 2.4)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: IkoTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_isEdit ? 'Refine the contract.' : 'Forge a new contract with yourself.',
                  style: IkoTheme.display(size: 32)),
              const SizedBox(height: 24),

              _Label('TITLE'),
              const SizedBox(height: 8),
              _textField(controller: _titleCtrl, hint: 'e.g. Deep work — 90 minutes'),
              const SizedBox(height: 20),

              _Label('NOTES (optional)'),
              const SizedBox(height: 8),
              _textField(controller: _descCtrl, hint: 'Why this matters…', maxLines: 3),
              const SizedBox(height: 24),

              _Label('CATEGORY'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _categories.map((c) => _chip(c, _category == c, () => setState(() => _category = c))).toList(),
              ),
              const SizedBox(height: 24),

              _Label('DIFFICULTY'),
              const SizedBox(height: 10),
              Row(
                children: _difficulties.map((d) {
                  final selected = _difficulty == d;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: d == _difficulties.last ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => _applyDifficultyDefaults(d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected ? IkoTheme.primary : Colors.transparent,
                            border: Border.all(color: selected ? IkoTheme.primary : IkoTheme.hairline),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            d.toUpperCase(),
                            style: IkoTheme.mono(
                              color: selected ? Colors.white : IkoTheme.textSecondary,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _stepper('XP REWARD', _xp, 5, 1000, 5, (v) => setState(() => _xp = v))),
                  const SizedBox(width: 16),
                  Expanded(child: _stepper('COINS', _coins, 0, 500, 5, (v) => setState(() => _coins = v))),
                ],
              ),
              const SizedBox(height: 24),

              _Label('RECURRENCE'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _chip('One-time', !_recurring, () => setState(() => _recurring = false))),
                  const SizedBox(width: 8),
                  Expanded(child: _chip('Daily', _recurring && _schedule == 'daily', () => setState(() { _recurring = true; _schedule = 'daily'; }))),
                  const SizedBox(width: 8),
                  Expanded(child: _chip('Weekly', _recurring && _schedule == 'weekly', () => setState(() { _recurring = true; _schedule = 'weekly'; }))),
                ],
              ),
              const SizedBox(height: 24),

              _Label('REMINDER'),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickReminder,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: IkoTheme.hairline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm_outlined, size: 18, color: IkoTheme.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _remindAt == null
                              ? 'No reminder · tap to schedule'
                              : _formatRemindAt(_remindAt!),
                          style: IkoTheme.body(size: 14, color: _remindAt == null ? IkoTheme.textSecondary : IkoTheme.primary),
                        ),
                      ),
                      if (_remindAt != null)
                        GestureDetector(
                          onTap: () => setState(() => _remindAt = null),
                          child: const Icon(Icons.close, size: 18, color: IkoTheme.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IkoTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: IkoTheme.primary.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEdit ? 'SAVE CHANGES' : 'COMMIT QUEST · +$_xp XP',
                          style: IkoTheme.mono(color: Colors.white, letterSpacing: 1.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRemindAt(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hh = dt.hour.toString().padLeft(2,'0');
    final mm = dt.minute.toString().padLeft(2,'0');
    return '${months[dt.month - 1]} ${dt.day} · $hh:$mm';
  }

  Widget _textField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: IkoTheme.body(size: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: IkoTheme.body(size: 16, color: IkoTheme.textTertiary),
        filled: true,
        fillColor: IkoTheme.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: IkoTheme.hairline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: IkoTheme.hairline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: IkoTheme.primary, width: 1.4)),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? IkoTheme.primary : Colors.transparent,
          border: Border.all(color: selected ? IkoTheme.primary : IkoTheme.hairline),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: IkoTheme.body(
            size: 13,
            weight: FontWeight.w500,
            color: selected ? Colors.white : IkoTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _stepper(String label, int value, int min, int max, int step, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: IkoTheme.hairline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _stepBtn(Icons.remove, () { if (value - step >= min) onChanged(value - step); }),
              Expanded(
                child: Center(
                  child: Text(value.toString(),
                      style: IkoTheme.display(size: 22, weight: FontWeight.w600, letterSpacing: 0)),
                ),
              ),
              _stepBtn(Icons.add, () { if (value + step <= max) onChanged(value + step); }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: IkoTheme.primary),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: IkoTheme.mono(letterSpacing: 1.8));
}
