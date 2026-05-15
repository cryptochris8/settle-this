import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper around Firebase Remote Config. Falls back to compiled-in
/// defaults when Remote Config is unavailable (no Firebase, offline first
/// launch, fetch failure) so callers never block on it.
class RemoteConfigService {
  static const String _shareCardDomainKey = 'share_card_domain';
  static const String _defaultShareCardDomain = 'settlethis.app';

  static const Map<String, dynamic> _defaults = {
    _shareCardDomainKey: _defaultShareCardDomain,
  };

  FirebaseRemoteConfig? _resolve() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseRemoteConfig.instance;
    } on FirebaseException {
      return null;
    }
  }

  Future<void> initialize() async {
    final rc = _resolve();
    if (rc == null) return;
    try {
      await rc.setDefaults(_defaults);
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await rc.fetchAndActivate();
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        debugPrint('Remote Config init failed (${error.code}).');
      }
    }
  }

  String get shareCardDomain {
    final rc = _resolve();
    if (rc == null) return _defaultShareCardDomain;
    final value = rc.getString(_shareCardDomainKey);
    return value.isNotEmpty ? value : _defaultShareCardDomain;
  }
}

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});
