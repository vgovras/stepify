import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class StepifyApp extends StatelessWidget {
  const StepifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stepify',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
