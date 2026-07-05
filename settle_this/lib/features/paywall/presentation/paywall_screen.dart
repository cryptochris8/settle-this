import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/services/analytics_service.dart';
import '../data/subscription_repository.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Future<Offering?>? _offeringFuture;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _offeringFuture = ref.read(subscriptionRepositoryProvider).currentOffering();
    unawaited(ref.read(analyticsServiceProvider).paywallViewed());
  }

  Future<void> _purchase(Package package) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final analytics = ref.read(analyticsServiceProvider);
    unawaited(analytics.purchaseStarted());
    try {
      final status =
          await ref.read(subscriptionRepositoryProvider).purchase(package);
      if (!mounted) return;
      if (status.isPlus) {
        unawaited(analytics.purchaseCompleted());
        context.go(AppRoutes.home);
      } else {
        setState(() => _error = 'Purchase did not activate Plus.');
      }
    } on SubscriptionException catch (e) {
      if (!mounted) return;
      // User backed out of the purchase sheet — not an error to surface.
      if (e.cancelled) return;
      unawaited(analytics.purchaseFailed(e.message));
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    unawaited(ref.read(analyticsServiceProvider).restorePurchaseTapped());
    final status =
        await ref.read(subscriptionRepositoryProvider).restore();
    if (!mounted) return;
    setState(() => _busy = false);
    if (status.isPlus) {
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active Plus entitlement found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settle This Plus')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Settle more tiny disasters.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 12),
              const _BenefitsList(),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<Offering?>(
                  future: _offeringFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final offering = snapshot.data;
                    if (offering == null) {
                      return _OfferingUnavailable(theme: theme);
                    }
                    return _PackagesList(
                      offering: offering,
                      busy: _busy,
                      onPurchase: _purchase,
                    );
                  },
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SettleThisColors.blocked,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : _restore,
                child: const Text('Restore purchases'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitsList extends StatelessWidget {
  const _BenefitsList();

  static const List<String> _benefits = [
    'Unlimited verdicts',
    'No ads',
    'Save unlimited history',
    'Try every tone',
    'Create share cards',
    'Get deeper practical advice',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _benefits
          .map(
            (b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: SettleThisColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PackagesList extends StatelessWidget {
  const _PackagesList({
    required this.offering,
    required this.busy,
    required this.onPurchase,
  });

  final Offering offering;
  final bool busy;
  final void Function(Package) onPurchase;

  @override
  Widget build(BuildContext context) {
    final packages = offering.availablePackages;
    return ListView.separated(
      itemCount: packages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final package = packages[i];
        final product = package.storeProduct;
        return Card(
          child: InkWell(
            onTap: busy ? null : () => onPurchase(package),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: SettleThisColors.inkSoft,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    product.priceString,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: SettleThisColors.navyDeep,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OfferingUnavailable extends StatelessWidget {
  const _OfferingUnavailable({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_grocery_store_outlined,
            size: 56,
            color: SettleThisColors.inkSoft,
          ),
          const SizedBox(height: 12),
          Text(
            'Plans are loading or RevenueCat is not configured.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: SettleThisColors.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pass --dart-define=REVENUECAT_API_KEY=… and add an offering called "default" in the RevenueCat dashboard.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SettleThisColors.inkSoft,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
