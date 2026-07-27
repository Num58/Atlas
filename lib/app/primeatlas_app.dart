import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_theme.dart';
import 'package:primeatlas/app/navigation/app_router.dart';

class PrimeAtlasApp extends ConsumerWidget {
  const PrimeAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'PrimeAtlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
