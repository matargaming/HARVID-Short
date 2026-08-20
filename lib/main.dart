import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, kIsWeb;
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

  // Lock orientation early
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load environment
  env = Env.fromDefines();
  if (env.hasReleaseBlockingIssues) {
    debugPrint(
      'ShortiGo release blockers:\n'
      '${env.releaseBlockingIssues.map((issue) => '- $issue').join('\n')}',
    );
  }

  // Make a single startup function we can run either inside Sentry or directly.
  Future<void> appStartup() async {
    // Initialize Firebase (non-fatal — app can continue if it fails)
    try {
      await FirebaseBootstrap.initialize();
      // Enable performance only in release builds (avoid noise in debug/profile)
      if (kReleaseMode) {
        try {
          await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
        } catch (e, st) {
          debugPrint('Firebase Performance enable failed: $e\n$st');
        }
      }
    } catch (e, st) {
      debugPrint('Firebase init failed, continuing without Firebase: $e');
      debugPrint('$st');
    }

    // System memory pressure handler (keeps your existing behavior)
    SystemChannels.system.setMessageHandler((message) async {
      if (message == 'memoryPressure') {
        debugPrint('Memory pressure warning received');
      }
      return null;
    });

    // Auth state listener. Keep it app-global; no cancellation necessary here.
    fb.FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);

    // Run the app inside ProviderScope as before
    runApp(
      ProviderScope(
        child: ShortiGoApp(router: buildRouter(requireAuth: false)),
      ),
    );

    // Post-frame work: initialize RevenueCat only on mobile platforms
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final androidKey = env.revenueCatApiKeyAndroid;
        final iosKey = env.revenueCatApiKeyIos;

        final hasKeys = (androidKey.isNotEmpty && androidKey != 'dummy' && androidKey.length > 10)
            || (iosKey.isNotEmpty && iosKey != 'dummy' && iosKey.length > 10);

        final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

        if (isMobile && hasKeys) {
          final iap = RevenueCatIapGateway();
          await iap.initialize(appleApiKey: iosKey, googleApiKey: androidKey);
        } else {
          debugPrint('Skipping RevenueCat init: mobile=$isMobile hasKeys=$hasKeys');
        }
      } catch (e, st) {
        debugPrint('RevenueCat init failed: $e\n$st');
      }
    });
  }

  // If a Sentry DSN exists in env, run app inside Sentry so errors are captured.
  if (env.sentryDsn != null && env.sentryDsn!.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = env.sentryDsn;
        options.environment = env.environmentName;
        // Adjust tracesSampleRate or enable profiling according to your needs:
        // options.tracesSampleRate = 0.1;
      },
      appRunner: () async {
        await appStartup();
      },
    );
  } else {
    await appStartup();
  }
}

void _onAuthStateChanged(fb.User? user) {
  // TODO: handle user changes (e.g., analytics, routing, state bootstrapping)
}
