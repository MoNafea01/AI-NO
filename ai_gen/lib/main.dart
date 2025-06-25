import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/settings_screen/cubits/theme_cubit/theme_cubit.dart';
import 'package:ai_gen/features/settings_screen/cubits/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/get_it_initialize.dart';
import 'core/utils/helper/my_windows_manager.dart';
import 'features/splashScreen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeGetIt();
  await initializeWindowsManager();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    return MultiRepositoryProvider(
      providers: [
         BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context,state){
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
