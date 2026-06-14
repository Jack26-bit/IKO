import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/notification_service.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  String? _localImagePath;
  final TextEditingController _nameCtrl = TextEditingController();
  bool _entering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userProvider);
      if (userState.hasValue) {
        final u = userState.value!;
        if (u.avatarUrl != null) setState(() => _localImagePath = u.avatarUrl);
        if (u.username.isNotEmpty) _nameCtrl.text = u.username;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;
    try {
      if (kIsWeb) {
        setState(() => _localImagePath = pickedFile.path);
        ref.read(userProvider.notifier).updateAvatar(pickedFile.path);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final name = path.basename(pickedFile.path);
        final saved = await File(pickedFile.path).copy('${dir.path}/$name');
        setState(() => _localImagePath = saved.path);
        ref.read(userProvider.notifier).updateAvatar(saved.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: IkoTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: IkoTheme.hairline, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: IkoTheme.primary),
              title: Text('Take Photo', style: IkoTheme.body(size: 15)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: IkoTheme.primary),
              title: Text('Choose from Library', style: IkoTheme.body(size: 15)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _enter() async {
    if (_entering) return;
    setState(() => _entering = true);
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      try { await ref.read(userProvider.notifier).updateUsername(name); } catch (_) {}
    }
    // Best-effort: ask for notifications upfront so reminders work later.
    try { await NotificationService.instance.requestPermission(); } catch (_) {}
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IkoTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editorial masthead
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ISSUE Nº 001', style: IkoTheme.mono(letterSpacing: 2.4)),
                  Text(_today(), style: IkoTheme.mono(letterSpacing: 2.4)),
                ],
              ).animate().fadeIn(duration: 700.ms),
              const SizedBox(height: 56),

              // Wordmark (large)
              Center(
                child: Column(
                  children: [
                    Text('IKO',
                        style: IkoTheme.display(size: 88, weight: FontWeight.w700, letterSpacing: 0.04)),
                    const SizedBox(height: 4),
                    Container(width: 24, height: 1, color: IkoTheme.primary),
                    const SizedBox(height: 14),
                    Text('MASTER PATH',
                        style: IkoTheme.mono(color: IkoTheme.primary, letterSpacing: 4)),
                  ],
                ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.08, end: 0, duration: 900.ms),
              ),
              const SizedBox(height: 56),

              Text(
                'A quiet operating\nsystem for your life.',
                style: IkoTheme.display(size: 38, weight: FontWeight.w600, height: 1.05),
              ).animate(delay: 220.ms).fadeIn(duration: 700.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: 12),
              Text(
                'Turn daily habits and goals into quests. '
                'Earn XP. Hold streaks. Build the version of you '
                'that compounds — one repetition at a time.',
                style: IkoTheme.body(size: 15, color: IkoTheme.textSecondary, height: 1.6),
              ).animate(delay: 320.ms).fadeIn(duration: 700.ms),

              const SizedBox(height: 40),
              Container(height: 1, color: IkoTheme.hairline),
              const SizedBox(height: 32),

              Text('CHAPTER I — IDENTITY', style: IkoTheme.mono(letterSpacing: 2.4)),
              const SizedBox(height: 12),
              Text('Compose your protagonist.',
                  style: IkoTheme.serif(size: 22, weight: FontWeight.w600)),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            color: IkoTheme.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: Border.all(color: IkoTheme.hairline, width: 1),
                          ),
                          child: ClipOval(
                            child: _localImagePath != null
                                ? (kIsWeb
                                    ? Image.network(_localImagePath!, fit: BoxFit.cover)
                                    : Image.file(File(_localImagePath!), fit: BoxFit.cover))
                                : const Icon(Icons.person_outline, size: 36, color: IkoTheme.textSecondary),
                          ),
                        ),
                        Container(
                          width: 28, height: 28,
                          decoration: const BoxDecoration(color: IkoTheme.primary, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NAME', style: IkoTheme.mono(letterSpacing: 1.8)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameCtrl,
                          style: IkoTheme.body(size: 16),
                          decoration: InputDecoration(
                            hintText: 'e.g. Solène Marlowe',
                            hintStyle: IkoTheme.body(size: 16, color: IkoTheme.textTertiary),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            filled: true,
                            fillColor: IkoTheme.surfaceContainerLowest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: IkoTheme.hairline)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: IkoTheme.hairline)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: IkoTheme.primary, width: 1.4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate(delay: 420.ms).fadeIn(duration: 700.ms).slideY(begin: 0.06, end: 0),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 58,
                child: ElevatedButton(
                  onPressed: _entering ? null : _enter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IkoTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _entering
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('ENTER THE VAULT  →',
                          style: IkoTheme.mono(color: Colors.white, letterSpacing: 2.4)),
                ),
              ).animate(delay: 520.ms).fadeIn(duration: 700.ms).slideY(begin: 0.06, end: 0),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'No accounts. No noise. Your data lives on this device.',
                  style: IkoTheme.body(size: 12, color: IkoTheme.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _today() {
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    final n = DateTime.now();
    return '${months[n.month - 1]} ${n.day}, ${n.year}';
  }
}
