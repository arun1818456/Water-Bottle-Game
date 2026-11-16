/// Utility for formatting game numbers (coins, stars, scores, points).
/// Numbers >= 10,000 are formatted using compact abbreviations:
/// - 10,000 to 999,999 -> 'K' (e.g. 10.5K, 250K)
/// - 1,000,000 to 999,999,999 -> 'M' (e.g. 1.2M, 50M)
/// - 1,000,000,000+ -> 'B' (e.g. 2.5B)
/// Numbers below 10,000 are displayed with full precision (e.g. 9,999 or 540).
class NumberFormatter {
  NumberFormatter._();

  /// Formats an integer or num value compactly if >= 10,000.
  static String format(num value) {
    final abs = value.abs();

    if (abs < 10000) {
      return value.toInt().toString();
    }

    final sign = value < 0 ? '-' : '';

    if (abs >= 1000000000) {
      final formatted = (abs / 1000000000);
      return '$sign${_trimTrailingZeros(formatted)}B';
    }

    if (abs >= 1000000) {
      final formatted = (abs / 1000000);
      return '$sign${_trimTrailingZeros(formatted)}M';
    }

    // Between 10,000 and 999,999
    final formatted = (abs / 1000);
    return '$sign${_trimTrailingZeros(formatted)}K';
  }

  static String _trimTrailingZeros(double value) {
    // If value has a fractional part, format to 1 decimal place (e.g. 10.5K, 1.2M)
    // If >= 100 in the tier, omit decimal (e.g. 250K, 100M)
    if (value >= 100) {
      return value.toInt().toString();
    }
    final str = value.toStringAsFixed(1);
    if (str.endsWith('.0')) {
      return str.substring(0, str.length - 2);
    }
    return str;
  }
}

/// Convenient extension on [num] and [int] for inline formatting: `stars.formatCompact()`
extension NumberCompactFormatter on num {
  String get formatCompact => NumberFormatter.format(this);
}
