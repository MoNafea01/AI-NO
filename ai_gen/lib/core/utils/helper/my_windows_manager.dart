import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initializeWindowsManager() async {
  // Ensure window manager is initialized
  await windowManager.ensureInitialized();

  // Set the minimum window size (e.g., 800x500)
  windowManager.setMinimumSize(const Size(970, 650));
  windowManager.setSize(const Size(930, 650), animate: true);

  windowManager.center(animate: true);
  windowManager.setTitle("AINO");

  // // Set the initial size to match the constraints

  // windowManager.setAlwaysOnTop(true);
}
