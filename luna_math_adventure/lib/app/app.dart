import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class LunaMathAdventureApp extends StatelessWidget {
  const LunaMathAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luna Math Adventure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
