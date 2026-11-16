import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_ais/core/utils/number_formatter.dart';

void main() {
  group('NumberFormatter Unit Tests (K, M, B formatting for values >= 10,000)', () {
    test('Values under 10,000 are displayed without abbreviation', () {
      expect(NumberFormatter.format(0), equals('0'));
      expect(NumberFormatter.format(450), equals('450'));
      expect(NumberFormatter.format(9999), equals('9999'));
      expect(950.formatCompact, equals('950'));
    });

    test('Values >= 10,000 and < 1,000,000 are formatted with K', () {
      expect(NumberFormatter.format(10000), equals('10K'));
      expect(NumberFormatter.format(10500), equals('10.5K'));
      expect(NumberFormatter.format(25000), equals('25K'));
      expect(NumberFormatter.format(150000), equals('150K'));
      expect(NumberFormatter.format(999999), equals('999K'));
      expect(12300.formatCompact, equals('12.3K'));
    });

    test('Values >= 1,000,000 and < 1,000,000,000 are formatted with M', () {
      expect(NumberFormatter.format(1000000), equals('1M'));
      expect(NumberFormatter.format(2500000), equals('2.5M'));
      expect(NumberFormatter.format(15000000), equals('15M'));
      expect(NumberFormatter.format(250000000), equals('250M'));
      expect(1500000.formatCompact, equals('1.5M'));
    });

    test('Values >= 1,000,000,000 are formatted with B', () {
      expect(NumberFormatter.format(1000000000), equals('1B'));
      expect(NumberFormatter.format(2400000000), equals('2.4B'));
      expect(NumberFormatter.format(10000000000), equals('10B'));
      expect(2500000000.formatCompact, equals('2.5B'));
    });
  });
}
