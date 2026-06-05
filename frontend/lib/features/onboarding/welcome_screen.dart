import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../core/theme.dart';
import '../../providers/user_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    // Load existing avatar if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userProvider);
      if (userState.hasValue && userState.value!.avatarUrl != null) {
        setState(() {
          _localImagePath = userState.value!.avatarUrl;
        });
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      try {
        if (kIsWeb) {
          // On Web, we can't use path_provider to save files to the filesystem.
          // We just use the temporary blob URL from ImagePicker.
          setState(() {
            _localImagePath = pickedFile.path;
          });
          ref.read(userProvider.notifier).updateAvatar(pickedFile.path);
        } else {
          // Save it to local app directory
          final directory = await getApplicationDocumentsDirectory();
          final fileName = path.basename(pickedFile.path);
          final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
          
          setState(() {
            _localImagePath = savedImage.path;
          });
          
          // Update backend avatar
          ref.read(userProvider.notifier).updateAvatar(savedImage.path);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
        }
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: IkoTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: IkoTheme.primary),
              title: const Text('Take Photo', style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: IkoTheme.primary),
              title: const Text('Choose from Gallery', style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IkoTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'IKO',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: IkoTheme.primary,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 48),
                const Text(
                  'Create Your Profile',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: IkoTheme.primary,
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                const Text(
                  'Welcome to your life operating system.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: IkoTheme.textSecondary,
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 48),
                
                // Avatar Picker
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: IkoTheme.surfaceContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: IkoTheme.surfaceContainer, width: 2),
                        ),
                        child: ClipOval(
                          child: _localImagePath != null
                              ? (kIsWeb 
                                  ? Image.network(_localImagePath!, fit: BoxFit.cover)
                                  : Image.file(File(_localImagePath!), fit: BoxFit.cover))
                              : const Icon(
                                  Icons.person_outline,
                                  size: 48,
                                  color: IkoTheme.textSecondary,
                                ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: IkoTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ).animate(delay: 400.ms).fadeIn(duration: 800.ms).scale(),
                ),
                
                const SizedBox(height: 48),
                
                // Form Fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FULL NAME',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: IkoTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'e.g. Jane Doe',
                        hintStyle: TextStyle(color: IkoTheme.textSecondary.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: IkoTheme.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: IkoTheme.surfaceContainer),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: IkoTheme.surfaceContainer),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: IkoTheme.primary, width: 2),
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 500.ms).fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IkoTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'ENTER THE VAULT',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
