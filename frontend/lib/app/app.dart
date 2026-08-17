import 'package:flutter/material.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../shared/services/settings_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsManager.instance,
      builder: (context, child) {
        ThemeData theme;
        if (SettingsManager.instance.themeMode == "Light") {
          theme = AppTheme.lightTheme;
        } else {
          theme = AppTheme.darkTheme;
        }

        return MaterialApp.router(
          title: AppStrings.appFullName,
          debugShowCheckedModeBanner: false,
          theme: theme,
          routerConfig: appRouter,
        );
      },
    );
  }
}
