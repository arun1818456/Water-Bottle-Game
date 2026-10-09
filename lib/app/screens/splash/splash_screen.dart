import 'package:water_bottle_ais/exports.dart';

/// Animated Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SplashController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.startLoading(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundMid, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Logo Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryCyan, AppColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryCyan.withAlpha(120),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(AppImages.appLogo),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .shimmer(delay: 500.ms, duration: 1200.ms),

              const SizedBox(height: 28),

              // Game Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primaryCyan, Color(0xFF80D8FF), Colors.white],
                ).createShader(bounds),
                child: Text(
                  AppConstants.appName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

              const Text(
                'Pour, Sort & Relax',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: 50),
              // Loading Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: Obx(() => Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: controller.progress.value,
                            minHeight: 8,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading ${(controller.progress.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )),
              ),

              const Spacer(),
              const Text(
                'Powered by Arun innovation Studio',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
