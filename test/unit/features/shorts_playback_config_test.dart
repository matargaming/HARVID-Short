import 'package:flutter_test/flutter_test.dart';
import 'package:shortigo/features/shorts/presentation/shorts_page.dart';

void main() {
  test('shorts player loops the active video until the user swipes', () {
    final config = shortsPlayerConfiguration();

    expect(config.looping, isTrue);
  });
}
