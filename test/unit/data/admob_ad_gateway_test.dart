import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shortigo/core/env/env.dart';
import 'package:shortigo/data/ads/admob_ad_gateway.dart';

void main() {
  test('debug builds use Google rewarded test units even with prod env', () {
    final env = Env.fromValues(
      flavor: AppFlavor.prod,
      adMobRewardedUnitIdAndroid: 'ca-app-pub-real/android',
      adMobRewardedUnitIdIos: 'ca-app-pub-real/ios',
    );

    expect(
      rewardedUnitIdFor(
        env: env,
        platform: TargetPlatform.android,
        forceTestAds: true,
      ),
      googleTestRewardedUnitIdAndroid,
    );
  });

  test('release prod builds use configured production rewarded units', () {
    final env = Env.fromValues(
      flavor: AppFlavor.prod,
      adMobRewardedUnitIdAndroid: 'ca-app-pub-real/android',
      adMobRewardedUnitIdIos: 'ca-app-pub-real/ios',
    );

    expect(
      rewardedUnitIdFor(
        env: env,
        platform: TargetPlatform.android,
        forceTestAds: false,
      ),
      'ca-app-pub-real/android',
    );
  });
}
