import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'bootstrap/firebase_bootstrap.dart';
import 'core/env/env.dart';
import 'core/router/app_router.dart';
import 'data/iap/revenuecat_iap_gateway.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  env = Env.fromDefines();
  if (env.hasReleaseBlockingIssues) {
    debugPrint(
      'ShortiGo release blockers:\n'
      '${env.releaseBlockingIssues.map((issue) => '- $issue').join('\n')}',
    );
  }
  try {
    await FirebaseBootstrap.initialize();
  } catch (e) {
    debugPrint('Firebase init failed, continue without Firebase: $e');
  }
  unawaited(
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true),
  );
  SystemChannels.system.setMessageHandler((message) async {
    if (message == 'memoryPressure') {
      debugPrint('Memory pressure warning received');
    }
    return null;
  });
  fb.FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  runApp(
    ProviderScope(
      child: ShortiGoApp(router: buildRouter(requireAuth: true)),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      // RevenueCat - aman walaupun key dummy, tidak akan crash
      final androidKey = env.revenueCatApiKeyAndroid;
      final iosKey = env.revenueCatApiKeyIos;
      if (androidKey.isNotEmpty && androidKey != 'dummy' && androidKey.length > 10) {
        final iap = RevenueCatIapGateway();
        await iap.initialize(
          appleApiKey: iosKey,
          googleApiKey: androidKey,
        );
        debugPrint('RevenueCat initialized');
      } else {
        debugPrint('RevenueCat skipped (dummy/empty key)');
      }
    } catch (e, stack) {
      debugPrint('RevenueCat init failed but app continues: $e');
      debugPrint('$stack');
    }
  });
}

void _onAuthStateChanged(fb.User? user) {
  // keep your existing logic here if any
}
