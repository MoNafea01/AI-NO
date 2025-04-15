import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/screens/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/di/get_it_initialize.dart';
import 'core/helper/my_windows_manager.dart';
import 'core/network/server_manager/server_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeGetIt();
  await initializeWindowsManager();

  // Create ServerManager
  // ServerManager serverManager = GetIt.I.get<ServerManager>();

  // Stop any existing servers
  // await serverManager.stopServer();

  // Start server and wait for it to be fully operational
  // if (true) {
  //   await serverManager.startServer();
  // }

  runApp(const MyApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ServerManager _serverManager = GetIt.I.get<ServerManager>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Stop the server when the app is closing
    _serverManager.stopServer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Restart server if it's not running
        // _serverManager.startServer();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // _serverManager.stopServer();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Do nothing or handle as needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: "AI Gen",
      theme: ThemeData(scaffoldBackgroundColor: AppColors.appBackgroundColor),
      home: const SplashScreen(),
    );
  }
}
