import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/getit_intialize.dart';
import 'core/network/server_manager/server_manager.dart';
import 'features/screens/splashScreen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure window manager is initialized

  await windowManager.ensureInitialized();

  // Set the minimum window size (e.g., 800x500)
  windowManager.setMinimumSize(const Size(800, 500));

  // Set the initial size to match the constraints
  windowManager.setSize(const Size(1200, 800));

  // Make the window resizable but not smaller than the minimum size
  windowManager.setResizable(true);
  // Create ServerManager
  initializeGetIt();
  ServerManager serverManager = GetIt.I.get<ServerManager>();

  // Stop any existing servers
  await serverManager.stopServer();

  // Start server and wait for it to be fully operational
  if (true) {
    await serverManager.startServer();
  }

  // print(await ApiCall().trainTestSplit([1, 2, 3, 4], testSize: 0.2, randomState: 1));
  runApp(const MyApp());
}

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
      debugShowCheckedModeBanner: false,
      title: 'AI Gen',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
