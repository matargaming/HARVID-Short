import 'package:flutter_test/flutter_test.dart';
import 'package:shortigo/features/episode_player/presentation/episode_player_view.dart';

void main() {
  test('video playback toggle flips between paused and playing', () {
    expect(nextVideoPausedState(isPaused: false), isTrue);
    expect(nextVideoPausedState(isPaused: true), isFalse);
  });
}
