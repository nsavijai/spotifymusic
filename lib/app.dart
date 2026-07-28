import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'routers/app_routers.dart';

class VMusicApp extends StatelessWidget {
  const VMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return MaterialApp.router(
      title: 'VMusic',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
