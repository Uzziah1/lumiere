import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'router.dart';
import 'theme/lumiere_theme.dart';

class LumiereApp extends StatefulWidget {
  const LumiereApp({super.key});

  @override
  State<LumiereApp> createState() => _LumiereAppState();
}

class _LumiereAppState extends State<LumiereApp> {
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumière',
      debugShowCheckedModeBanner: false,
      theme: buildLumiereTheme(),
      locale: const Locale('fr'),
      routerConfig: _router,
    );
  }
}
