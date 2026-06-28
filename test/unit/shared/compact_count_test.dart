import 'package:flutter_test/flutter_test.dart';
import 'package:shortigo/shared/format/compact_count.dart';

void main() {
  group('compactCount', () {
    test('formats small counts plainly', () {
      expect(compactCount(0), '0');
      expect(compactCount(999), '999');
    });

    test('formats thousands and millions like social apps', () {
      expect(compactCount(1200), '1.2K');
      expect(compactCount(45000), '45K');
      expect(compactCount(2100000), '2.1M');
    });
  });
}
