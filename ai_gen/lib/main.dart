import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/settings_screen/cubits/theme_cubit/theme_cubit.dart';
import 'package:ai_gen/features/settings_screen/cubits/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/get_it_initialize.dart';
import 'core/models/project_model.dart';
import 'core/network/server_manager/server_manager.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await GetIt.I.get<ServerManager>().stopServer();
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            title: 'AI Gen',
            theme: ThemeData(scaffoldBackgroundColor: Colors.white),
            // theme:
            //           state.isDarkMode ? ThemeCubit.darkTheme : ThemeCubit.lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
