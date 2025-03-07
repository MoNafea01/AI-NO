import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/di/getit_intialize.dart';
import 'core/network/server_manager/server_manager.dart';
import 'features/node_view/presentation/grid_loader.dart';

void main() async {
  // Create ServerManager
  initializeGetIt();
  ServerManager serverManager = GetIt.I.get<ServerManager>();

  // Stop any existing servers
  // await serverManager.stopServer();

  // Start server and wait for it to be fully operational
  // if (true) {
  //   await serverManager.startServer();
  // }

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
        scaffoldBackgroundColor: const Color.fromARGB(255, 46, 46, 46),
      ),
      home: const Scaffold(backgroundColor: Colors.white, body: GridLoader()),
    );
  }
}
