import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/get_it_initialize.dart';
import 'core/models/project_model.dart';
import 'core/utils/helper/check_main_args.dart';
import 'core/utils/helper/my_windows_manager.dart';
import 'features/splashScreen/splash_screen.dart';

void main(List<String> args) async {
  // to check if the project is opened from an a project file with .ainoprj extension
  ProjectModel? initialProject = await checkArgs(args);

  WidgetsFlutterBinding.ensureInitialized();
  initializeGetIt();
  await initializeWindowsManager();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(initialProject: initialProject),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialProject});

  final ProjectModel? initialProject;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WindowListener, WidgetsBindingObserver {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  //   windowManager.addListener(this);
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  // @override
  // void onWindowClose() async {
  //   await GetIt.I.get<ServerManager>().stopServer();
  //   windowManager.removeListener(this);
  //   WidgetsBinding.instance.removeObserver(this);
  //   windowManager.destroy();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'AINO',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: SplashScreen(initialProject: widget.initialProject),
    );
  }
}
