import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/profile_sync.dart';
import 'app/settle_this_app.dart';
import 'core/services/preferences_service.dart';
import 'core/services/remote_config_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await _initFirebase();
  final remoteConfig = RemoteConfigService();
  await remoteConfig.initialize();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        remoteConfigServiceProvider.overrideWithValue(remoteConfig),
      ],
      child: const SettleThisRoot(),
    ),
  );
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error, stack) {
    if (kDebugMode) {
      debugPrint('Firebase init failed (${error.code}).');
      debugPrintStack(stackTrace: stack);
    }
    return;
  }
  await _activateAppCheck();
}

Future<void> _activateAppCheck() async {
  // Debug providers in dev/CI (simulator + emulator); real attestation in
  // release builds. Register the printed debug token in Firebase Console →
  // App Check → Apps → Manage debug tokens, per platform.
  try {
    await FirebaseAppCheck.instance.activate(
      // ignore: deprecated_member_use
      androidProvider: kReleaseMode
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug,
      // ignore: deprecated_member_use
      appleProvider: kReleaseMode
          ? AppleProvider.appAttestWithDeviceCheckFallback
          : AppleProvider.debug,
    );
  } on FirebaseException catch (error) {
    if (kDebugMode) {
      debugPrint('App Check activation failed (${error.code}).');
    }
  }
}

class SettleThisRoot extends ConsumerWidget {
  const SettleThisRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(profileSyncProvider);
    return const SettleThisApp();
  }
}
