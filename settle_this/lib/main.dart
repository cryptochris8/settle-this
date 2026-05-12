import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/profile_sync.dart';
import 'app/settle_this_app.dart';
import 'core/services/preferences_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await _initFirebase();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
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
