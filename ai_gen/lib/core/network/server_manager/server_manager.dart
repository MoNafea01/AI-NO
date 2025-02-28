import 'dart:io';

import 'package:dio/dio.dart';

class ServerManager {
  Process? _serverProcess;
  bool _isServerRunning = false;
  final Dio _dio = Dio();

  Future<void> startServer() async {
    if (_isServerRunning) return;

    String pathEldemy =
        "D:\\College\\4th\\Graduation Project\\simple_task\\backend\\run_server.bat";
    // String pathShaltoot = "D:\\GraduationProject\\backend\\run_server.bat";
    try {
      String batchFilePath = pathEldemy;

      await _killExistingServers();

      _serverProcess = await Process.start(batchFilePath, []);
      _isServerRunning = true;

      _serverProcess!.stdout.listen((data) {
        print(String.fromCharCodes(data));
      });

      _serverProcess!.stderr.listen((data) {
        print('Server Error: ${String.fromCharCodes(data)}');
      });

      _serverProcess!.exitCode.then((exitCode) {
        print('Server process exited with code: $exitCode');
        _isServerRunning = false;
        _serverProcess = null;
      });

      // Wait and verify server is running
      await _waitForServerToStart();
    } catch (e) {
      print('Failed to start backend server: $e');
      _isServerRunning = false;
    }
  }

  Future<void> _waitForServerToStart() async {
    const int maxAttempts = 10;
    const Duration waitBetweenAttempts = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _dio.get('http://localhost:8000',
            options: Options(
              sendTimeout: Duration(seconds: 5),
              receiveTimeout: Duration(seconds: 5),
              validateStatus: (status) => status != null && status < 500,
            ));

        if (response.statusCode == 200) {
          print('Server is up and running');
          return;
        }
      } catch (e) {
        print('Waiting for server to start... Attempt $attempt');
        await Future.delayed(waitBetweenAttempts);
      }
    }

    throw Exception('Could not start server after $maxAttempts attempts');
  }

  Future<void> _killExistingServers() async {
    try {
      // Kill all Python processes and processes on port 8000
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/F', '/IM', 'python.exe']);
        await Process.run('cmd', [
          '/c',
          'for /f "tokens=5" %a in (\'netstat -ano ^| findstr :8000\') do taskkill /PID %a /F'
        ]);
      } else {
        await Process.run('pkill', ['-f', 'python']);
        await Process.run('fuser', ['-k', '8000/tcp']);
      }
    } catch (e) {
      print('Error killing existing servers: $e');
    }
  }

  Future<void> stopServer() async {
    if (_serverProcess != null) {
      try {
        // Kill all Python processes
        if (Platform.isWindows) {
          await Process.run('taskkill', ['/F', '/IM', 'python.exe']);
        } else {
          await Process.run('pkill', ['-f', 'python']);
        }

        _isServerRunning = false;
        _serverProcess = null;
        print('Server process terminated');
      } catch (e) {
        print('Error stopping server: $e');
      }
    }
  }
}
