import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class ServerManager {
  Process? _serverProcess;
  bool _isServerRunning = false;
  final Dio _dio = GetIt.instance<Dio>();

  Future<void> startServer() async {
    if (_isServerRunning) return;

    String projectPath = Directory.current.path;
    String backendPath = Directory.current.path;
    // String backendPath = '${projectPath.replaceAll('\\ai_gen', '')}\\backend';
    try {
      print('Starting server from path: $backendPath');
      await _killExistingServers();

      // Change to the backend directory first
      Directory.current = backendPath;

      // Start the server process
      _serverProcess = await Process.start('cmd', ['/c', 'run_server.bat']);
      _isServerRunning = true;

      _serverProcess!.stdout.listen((data) {
        String output = String.fromCharCodes(data);
        // Only print if it's not a standard Django request log
        if (!output.contains('"GET /api/') && !output.contains('"POST /api/')) {
          print('Server output: $output');
        }
      });

      _serverProcess!.stderr.listen((data) {
        String error = String.fromCharCodes(data);
        // Only print if it's not a standard Django request log
        if (!error.contains('"GET /api/') && !error.contains('"POST /api/')) {
          print('Server error: $error');
        }
      });

      _serverProcess!.exitCode.then((exitCode) {
        print('Server process exited with code: $exitCode');
        _isServerRunning = false;
        _serverProcess = null;
      });

      // Wait and verify server is running with increased timeout and retries
      await _waitForServerToStart();
    } catch (e) {
      print('Failed to start backend server: $e');
      _isServerRunning = false;
    } finally {
      // Restore the original directory
      Directory.current = projectPath;
    }
  }

  Future<void> _waitForServerToStart() async {
    const int maxAttempts = 10;
    const Duration waitBetweenAttempts = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print(
            'Attempting to connect to server (attempt $attempt of $maxAttempts)...');

        // First try the base URL with increased timeout
        final response = await _dio.get('http://127.0.0.1:8000/api/projects/',
            options: Options(
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              validateStatus: (status) =>
                  status != null && (status >= 200 || status <= 301),
              followRedirects: true,
            ));

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! <= 301) {
          print('Server is up and running successfully');
          return;
        }
        print('Server responded with status code: ${response.statusCode}');
      } catch (e) {
        print('Connection attempt $attempt failed: $e');
        if (e is DioException) {
          print('DioError type: ${e.type}');
          print('DioError message: ${e.message}');
        }
      }

      if (attempt < maxAttempts) {
        print(
            'Waiting ${waitBetweenAttempts.inSeconds} seconds before next attempt...');
        await Future.delayed(waitBetweenAttempts);
      }
    }
    print(
        'Failed to start server after $maxAttempts attempts. Please check if the backend server is properly configured and running.');
  }

  Future<void> _killExistingServers() async {
    try {
      print('Attempting to kill existing servers...');
      // Kill all Python processes and processes on port 8000
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/F', '/IM', 'python.exe']);
        await Process.run('cmd', [
          '/c',
          'for /f "tokens=5" %a in (\'netstat -ano ^| findstr :8000\') do taskkill /PID %a /F'
        ]);
        print('Successfully killed existing servers');
      } else {
        await Process.run('pkill', ['-f', 'python']);
        await Process.run('fuser', ['-k', '8000/tcp']);
        print('Successfully killed existing servers');
      }
    } catch (e) {
      print('Error killing existing servers: $e');
      // Don't rethrow here, as we want to continue even if killing fails
    }
  }

  /// Checks if the server is already running by making a test request.
  Future<bool> isServerRunning() async {
    try {
      final response = await _dio.get(
        'http://127.0.0.1:8000/api/projects/',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 400;
    } catch (_) {
      return false;
    }
  }

  /// Runs run_server.bat in the same directory as the executable, listens to output, and waits for it to finish.
  /// Stores the process for later control. Returns the exit code.
  Future<int> runAndListenToServerScript() async {
    try {
      final exeDir = File(Platform.resolvedExecutable).parent;
      final scriptPath = exeDir.uri.resolve('run_server.bat').toFilePath();

      print('Running script: $scriptPath in $exeDir');

      _serverProcess = await Process.start(
        'cmd',
        ['/c', scriptPath],
        workingDirectory: exeDir.path,
        runInShell: true,
      );
      _isServerRunning = true;

      _serverProcess!.stdout.transform(SystemEncoding().decoder).listen((data) {
        print('Script stdout: $data');
        // You can parse output and make decisions here
      });

      print('Server process: ${_serverProcess?.runtimeType}');

      _serverProcess!.stderr.transform(SystemEncoding().decoder).listen((data) {
        print('Script stderr: $data');
        // You can parse errors and make decisions here
      });

      final exitCode = await _serverProcess!.exitCode;
      print('Script exited with code: $exitCode');
      _isServerRunning = false;
      _serverProcess = null;
      return exitCode;
    } catch (e) {
      print('Error running server script: $e');
      _isServerRunning = false;
      _serverProcess = null;
      return -1;
    }
  }

  @override
  Future<void> stopServer() async {
    if (_serverProcess != null) {
      print('Stopping server...');
      _serverProcess!.kill(ProcessSignal.sigterm);
      await _killExistingServers();
      _isServerRunning = false;
      _serverProcess = null;
      print('Server stopped');
    }
  }
}
