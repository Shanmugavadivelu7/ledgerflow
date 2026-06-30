import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'main_shell.dart';

class LedgerFlowApp extends StatelessWidget {
  const LedgerFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LedgerFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}