import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

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

  // 1. Env amanin dulu
  try {
    env = Env.fromDefines();
    if (env.hasReleaseBlockingIssues) {
      debugPrint('ShortiGo release blockers:\n${env.releaseBlockingIssues.map((e) => '- $e').join('\n')}');
    }
  } catch (e) {
    debugPrint('Env load gagal, pakai default: $e');
    env = Env.fromDefines(); // biarin tetap jalan
  }

  // 2. Firebase init - HARUS berhasil dulu sebelum panggil Auth
  bool firebaseOk = false;
  try {
    await FirebaseBootstrap.initialize();
    firebaseOk = true;
    unawaited(
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true),
    );
  } catch (e, stack) {
    debugPrint('Firebase init failed, continue without Firebase: $e');
    debugPrint('$stack');
  }

  // 3. Auth listener HANYA kalau Firebase berhasil
  if (firebaseOk) {
    try {
      fb.FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    } catch (e) {
      debugPrint('Auth listener gagal: $e');
    }
  }

  // 4. HAPUS SystemChannels.memoryPressure - itu penyebab crash di Android 14/Xiaomi
  // SystemChannels.system.setMessageHandler <- JANGAN DIPAKAI LAGI

  runApp(
    ProviderScope(
      child: ShortiGoApp(router: buildRouter(requireAuth: false)),
    ),
  );

  // 5. RevenueCat jalan belakangan, jangan blokir UI
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final androidKey = env.revenueCatApiKeyAndroid;
      final iosKey = env.revenueCatApiKeyIos;
      if (androidKey.isNotEmpty && androidKey != 'dummy' && androidKey.length > 10) {
        final iap = RevenueCatIapGateway();
        await iap.initialize(
          appleApiKey: iosKey,
          googleApiKey: androidKey,
        );
      }
    } catch (e, stack) {
      debugPrint('RevenueCat init failed: $e');
      debugPrint('$stack');
    }
  });
}

void _onAuthStateChanged(fb.User? user) {
  debugPrint('Auth state: ${user?.uid}');
}
