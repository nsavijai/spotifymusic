import 'package:flutter/material.dart';
import 'package:vmusic/core/theme/app_theme.dart';
import 'package:vmusic/routers/app_routers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'VMusic',
    );
  }
}
