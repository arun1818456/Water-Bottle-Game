// Flutter & External Packages
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:get/get.dart';
export 'package:flutter_animate/flutter_animate.dart';

// App Routes & Root App
export 'package:water_bottle_ais/my_app.dart';
export 'package:water_bottle_ais/app/routes/routes.dart';
export 'package:water_bottle_ais/app/routes/pages.dart';

// Constants
export 'package:water_bottle_ais/app/constants/app_colors.dart';
export 'package:water_bottle_ais/app/constants/app_constants.dart';
export 'package:water_bottle_ais/app/constants/app_images.dart';
export 'package:water_bottle_ais/app/constants/assets_constants.dart';

// Theme & Utils
export 'package:water_bottle_ais/app/theme/app_theme.dart';
export 'package:water_bottle_ais/app/utils/haptic_feedback_helper.dart';

// Services
export 'package:water_bottle_ais/app/services/ads_service.dart';
export 'package:water_bottle_ais/app/services/audio_service.dart';
export 'package:water_bottle_ais/app/services/storage_service.dart';

// Models
export 'package:water_bottle_ais/app/models/bottle.dart';
export 'package:water_bottle_ais/app/models/game_move.dart';
export 'package:water_bottle_ais/app/models/liquid_color.dart';

// Screens & Controllers
export 'package:water_bottle_ais/app/screens/splash/splash_screen.dart';
export 'package:water_bottle_ais/app/screens/splash/splash_controller.dart';

export 'package:water_bottle_ais/app/screens/home/home_screen.dart';
export 'package:water_bottle_ais/app/screens/home/home_controller.dart';
export 'package:water_bottle_ais/app/screens/home/widgets/interactive_water_drop.dart';

export 'package:water_bottle_ais/app/screens/game/game_screen.dart';
export 'package:water_bottle_ais/app/screens/game/controllers/game_controller.dart';
export 'package:water_bottle_ais/app/screens/game/logic/level_manager.dart';
export 'package:water_bottle_ais/app/screens/game/logic/procedural_level_generator.dart';
export 'package:water_bottle_ais/app/screens/game/logic/water_sort_solver.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/bottle_widget.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/bottle_painter.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/bottle_completion_effects.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/celebration_overlay.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/defeat_dialog.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/pause_dialog.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/pour_stream_overlay.dart';
export 'package:water_bottle_ais/app/screens/game/widgets/victory_dialog.dart';

export 'package:water_bottle_ais/app/screens/levels/level_select_screen.dart';
export 'package:water_bottle_ais/app/screens/levels/level_controller.dart';

export 'package:water_bottle_ais/app/screens/shop/shop_screen.dart';
export 'package:water_bottle_ais/app/screens/shop/shop_controller.dart';

export 'package:water_bottle_ais/app/screens/daily_reward/daily_reward_screen.dart';
export 'package:water_bottle_ais/app/screens/daily_reward/daily_reward_controller.dart';

export 'package:water_bottle_ais/app/screens/settings/settings_screen.dart';
export 'package:water_bottle_ais/app/screens/settings/settings_controller.dart';
