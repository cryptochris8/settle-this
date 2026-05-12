import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../app/constants.dart';
import '../../auth/data/auth_repository.dart';

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.isPlus,
    required this.willRenew,
    required this.expirationDate,
    required this.activeProductIdentifier,
  });

  final bool isPlus;
  final bool willRenew;
  final DateTime? expirationDate;
  final String? activeProductIdentifier;

  static const SubscriptionStatus free = SubscriptionStatus(
    isPlus: false,
    willRenew: false,
    expirationDate: null,
    activeProductIdentifier: null,
  );
}

class SubscriptionRepository {
  bool _configured = false;
  bool _attemptedConfigure = false;

  static const String _apiKey = AppConstants.revenueCatApiKey;

  Future<bool> _ensureConfigured() async {
    if (_configured) return true;
    if (_attemptedConfigure) return false;
    _attemptedConfigure = true;

    if (_apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'RevenueCat API key not set. Pass --dart-define=REVENUECAT_API_KEY=...',
        );
      }
      return false;
    }
    try {
      await Purchases.setLogLevel(LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      _configured = true;
      return true;
    } catch (error) {
      if (kDebugMode) debugPrint('RevenueCat configure failed: $error');
      return false;
    }
  }

  Future<void> identify(String? uid) async {
    if (!await _ensureConfigured()) return;
    if (uid == null) return;
    try {
      await Purchases.logIn(uid);
    } catch (error) {
      if (kDebugMode) debugPrint('RevenueCat logIn failed: $error');
    }
  }

  Future<SubscriptionStatus> currentStatus() async {
    if (!await _ensureConfigured()) return SubscriptionStatus.free;
    try {
      final info = await Purchases.getCustomerInfo();
      return _statusFromCustomerInfo(info);
    } catch (error) {
      if (kDebugMode) debugPrint('getCustomerInfo failed: $error');
      return SubscriptionStatus.free;
    }
  }

  Stream<SubscriptionStatus> watchStatus() {
    if (!_configured && _apiKey.isEmpty) {
      return Stream.value(SubscriptionStatus.free);
    }
    final controller = StreamController<SubscriptionStatus>.broadcast();
    void listener(CustomerInfo info) {
      controller.add(_statusFromCustomerInfo(info));
    }

    _ensureConfigured().then((ok) async {
      if (!ok) {
        controller.add(SubscriptionStatus.free);
        return;
      }
      Purchases.addCustomerInfoUpdateListener(listener);
      try {
        controller.add(_statusFromCustomerInfo(await Purchases.getCustomerInfo()));
      } catch (_) {
        controller.add(SubscriptionStatus.free);
      }
    });

    controller.onCancel = () {
      Purchases.removeCustomerInfoUpdateListener(listener);
      controller.close();
    };

    return controller.stream;
  }

  Future<Offering?> currentOffering() async {
    if (!await _ensureConfigured()) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current ??
          offerings.all[AppConstants.revenueCatOfferingDefault];
    } catch (error) {
      if (kDebugMode) debugPrint('getOfferings failed: $error');
      return null;
    }
  }

  Future<SubscriptionStatus> purchase(Package package) async {
    if (!await _ensureConfigured()) {
      throw const SubscriptionException('RevenueCat not configured.');
    }
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _statusFromCustomerInfo(result.customerInfo);
    } on PurchasesErrorCode catch (code) {
      throw SubscriptionException(code.toString());
    } catch (error) {
      throw SubscriptionException(error.toString());
    }
  }

  Future<SubscriptionStatus> restore() async {
    if (!await _ensureConfigured()) return SubscriptionStatus.free;
    try {
      final info = await Purchases.restorePurchases();
      return _statusFromCustomerInfo(info);
    } catch (error) {
      if (kDebugMode) debugPrint('restorePurchases failed: $error');
      return SubscriptionStatus.free;
    }
  }

  SubscriptionStatus _statusFromCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.active[AppConstants.entitlementSettlePlus];
    if (entitlement == null) return SubscriptionStatus.free;
    return SubscriptionStatus(
      isPlus: entitlement.isActive,
      willRenew: entitlement.willRenew,
      expirationDate: DateTime.tryParse(entitlement.expirationDate ?? ''),
      activeProductIdentifier: entitlement.productIdentifier,
    );
  }
}

class SubscriptionException implements Exception {
  const SubscriptionException(this.message);
  final String message;
  @override
  String toString() => 'SubscriptionException: $message';
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final repo = SubscriptionRepository();
  ref.listen(authStateProvider, (_, next) {
    final uid = next.value?.uid;
    repo.identify(uid);
  });
  return repo;
});

final subscriptionStatusProvider =
    StreamProvider<SubscriptionStatus>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchStatus();
});
