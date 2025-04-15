
import 'package:ai_gen/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/getit_intialize.dart';
import 'core/network/server_manager/server_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeGetIt();

  // Ensure window manager is initialized
  await windowManager.ensureInitialized();

  // Set the minimum window size (e.g., 800x500)
  windowManager.setMinimumSize(const Size(800, 500));

  // Set the initial size to match the constraints
  windowManager.setSize(const Size(1200, 800));

  // Make the window resizable but not smaller than the minimum size
  windowManager.setResizable(true);
  // Create ServerManager
  ServerManager serverManager = GetIt.I.get<ServerManager>();

  // Stop any existing servers
  await serverManager.stopServer();

  // Start server and wait for it to be fully operational
  if (true) {
    await serverManager.startServer();
  }

  runApp(ChangeNotifierProvider(
      create: (context) => AuthProvider(), child: const MyApp()));
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
      title: 'AI Gen',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const SignupScreen(),

      //  const DashboardScreen()

      //const SplashScreen(),
    );
  }
}
