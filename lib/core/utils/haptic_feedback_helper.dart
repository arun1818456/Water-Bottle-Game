import 'package:flutter/services.dart';
import '../services/storage_service.dart';

/// Helper for tactical vibration feedback across gameplay
class HapticFeedbackHelper {
  HapticFeedbackHelper._();

  static void lightImpact() {
    if (StorageService.to.vibrationEnabled.value) {
      HapticFeedback.lightImpact();
    }
  }

  static void mediumImpact() {
    if (StorageService.to.vibrationEnabled.value) {
      HapticFeedback.mediumImpact();
    }
  }

  static void heavyImpact() {
    if (StorageService.to.vibrationEnabled.value) {
      HapticFeedback.heavyImpact();
    }
  }

  static void selectionClick() {
    if (StorageService.to.vibrationEnabled.value) {
      HapticFeedback.selectionClick();
    }
  }

  static void winVibration() {
    if (StorageService.to.vibrationEnabled.value) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 150), () {
        HapticFeedback.heavyImpact();
      });
    }
  }
}
