import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

/// Interactive Profile & Direct Google Login/Signup Dialog
class ProfileAuthDialog extends StatefulWidget {
  const ProfileAuthDialog({super.key});

  @override
  State<ProfileAuthDialog> createState() => _ProfileAuthDialogState();
}

class _ProfileAuthDialogState extends State<ProfileAuthDialog> {
  final storage = StorageService.to;
  late final TextEditingController _nameController;

  String _selectedEmoji = '🎮';
  int _selectedTab = 0; // 0 = Profile Customization, 1 = Google Sign In
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _avatars = [
    '🎮', '👑', '🦁', '🦊', '🐯', '🐉', '🤖', '🧙', '🥷', '⚡', '🐬', '🌺'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: storage.getOrCreateUserName());
    _selectedEmoji = storage.getOrCreateUserAvatar();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    AudioService.to.playButtonClick();
    await storage.setUserName(newName);
    await storage.setUserAvatar(_selectedEmoji);

    if (Get.isRegistered<FirebaseService>()) {
      await FirebaseService.to.syncUserData();
    }

    Get.back();
    Get.snackbar(
      'Profile Updated',
      'Your display name and avatar have been saved!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AudioService.to.playButtonClick();

    final err = await FirebaseService.to.signInWithGoogle();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (err == null) {
      Get.back();
      Get.snackbar(
        'Welcome!',
        'Logged in with Google successfully. Your cloud data is synced!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.95),
        colorText: Colors.black,
        duration: const Duration(seconds: 3),
      );
    } else {
      setState(() => _errorMessage = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = storage.userEmail.value;
    final isLoggedIn = currentUserEmail.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0E223D), Color(0xFF071324)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              blurRadius: 24,
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_circle_rounded,
                      color: Color(0xFF00E5FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PLAYER PROFILE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Segmented Tab Bar (Profile Edit vs Google Auth)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    _buildTabButton(0, 'Edit Name & Avatar'),
                    _buildTabButton(1, isLoggedIn ? 'Google Account' : 'Google Sign In'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab 0: Edit Name & Choose Avatar
              if (_selectedTab == 0) ...[
                // Avatar Circle Picker
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F3A75),
                      border: Border.all(color: const Color(0xFF00E5FF), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 38),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Avatar Grid Selector
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _avatars.map((emoji) {
                    final isSelected = _selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedEmoji = emoji);
                        AudioService.to.playButtonClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Name Input Field
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Player Display Name',
                    labelStyle: const TextStyle(color: AppColors.primaryCyan),
                    prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primaryCyan),
                    filled: true,
                    fillColor: Colors.black38,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Save Profile CTA
                GestureDetector(
                  onTap: _saveProfile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SAVE PROFILE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Tab 1: Google Sign In / Account Status
                if (isLoggedIn) ...[
                  // Logged in Status Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 42),
                        const SizedBox(height: 10),
                        const Text(
                          'CONNECTED TO GOOGLE',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00E676),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUserEmail,
                          style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your level progress, coins & stars are backed up automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () async {
                            await FirebaseService.to.signOut();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5252).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFF5252)),
                            ),
                            child: const Text(
                              'Sign Out From Google',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF8A8A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Google Sign-In Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'ONE-TAP GOOGLE SIGN-IN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Sign in with Google to save your level progress & coins to the cloud or restore your existing account data instantly!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFFF5252), fontWeight: FontWeight.bold),
                          ),
                        ],

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: _isLoading ? null : _handleGoogleSignIn,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                                  )
                                else ...[
                                  const Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4285F4),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _errorMessage = null;
          });
          AudioService.to.playButtonClick();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.black : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
