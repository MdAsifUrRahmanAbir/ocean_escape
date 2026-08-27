import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_services.dart';
import 'screens/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final services = await AppServices.bootstrap();
  runApp(OceanEscapeApp(services: services));
}

/// Root widget (§40/§45). Offline-first: every service is bootstrapped from
/// bundled assets and local storage before the first frame, no network I/O
/// anywhere in the app.
class OceanEscapeApp extends StatelessWidget {
  const OceanEscapeApp({super.key, required this.services});
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocean Escape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E9BC7),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: MainMenuScreen(services: services),
    );
  }
}
