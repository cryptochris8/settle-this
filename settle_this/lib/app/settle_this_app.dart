import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants.dart';
import 'router.dart';
import 'theme.dart';

class SettleThisApp extends ConsumerWidget {
  const SettleThisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildSettleThisTheme(),
      routerConfig: router,
    );
  }
}
