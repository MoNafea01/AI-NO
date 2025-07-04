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

  /// Checks if the server process is still running
  bool isServerProcessRunning() {
    return _serverProcess != null && _isServerRunning;
  }

  /// Gets the current server process
  Process? getServerProcess() {
    return _serverProcess;
  }

  /// Runs run_server.bat in the same directory as the executable, listens to output, and waits for it to finish.
  /// Stores the process for later control. Returns the exit code.
  Future<int> runAndListenToServerScript() async {
    try {
      // Use the project root directory instead of the executable directory
      final projectRoot = Directory.current.path;
      final scriptPath = '$projectRoot\\run_server.bat';
      final scriptFile = File(scriptPath);

      print('Checking script: $scriptPath in $projectRoot');

      // Check if the script file exists
      if (!await scriptFile.exists()) {
        print('ERROR: Server script not found at: $scriptPath');
        print(
            'Please ensure run_server.bat exists in the project root directory.');
        return -2; // Special error code for missing script
      }

      print('Running script: $scriptPath in $projectRoot');

      _serverProcess = await Process.start(
        'cmd',
        ['/c', scriptPath],
        workingDirectory: projectRoot,
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

      // Check if the process started successfully by waiting a short time
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if the process is still running after a short delay
      if (_serverProcess != null) {
        try {
          // Try to get the exit code with a timeout
          int? exitCode;
          try {
            exitCode = await _serverProcess!.exitCode.timeout(
              const Duration(seconds: 2),
            );
          } catch (timeoutError) {
            // If timeout, the process is still running (good)
            exitCode = null;
          }

          // If we got an exit code, the process failed quickly
          if (exitCode != null && exitCode != 0) {
            print('ERROR: Server script failed with exit code: $exitCode');
            _isServerRunning = false;
            _serverProcess = null;
            return exitCode;
          }
        } catch (e) {
          // If we can't get the exit code, the process might still be running
          print('Process status check: $e');
        }
      }

      // Don't wait for the process to exit, just start it and return
      // The process will continue running in the background
      print('Server script started successfully');
      return 0;
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

  /// Gets a user-friendly error message based on the exit code
  String getErrorMessage(int exitCode) {
    switch (exitCode) {
      case -2:
        return "Server script not found. Please ensure 'run_server.bat' exists in the project directory.";
      case -1:
        return "Failed to start server script. Please check your system configuration.";
      case 1:
        return "Server script failed to execute. Please check if Python and Django are properly installed.";
      case 2:
        return "Server script failed due to missing dependencies. Please check your backend setup.";
      case 9009:
        return "Command not found. Please ensure Python is installed and added to your system PATH.";
      case 127:
        return "Command not found. Please check if the required executables are available.";
      default:
        return "Server script failed with error code: $exitCode. Please check the console for details.";
    }
  }

  /// Gets detailed error information for debugging
  String getDetailedErrorInfo(int exitCode) {
    String baseMessage = getErrorMessage(exitCode);
    String additionalInfo = "";

    switch (exitCode) {
      case -2:
        additionalInfo = "\n\nTroubleshooting:\n"
            "1. Make sure 'run_server.bat' exists in the project root directory\n"
            "2. Check if the file path contains special characters\n"
            "3. Verify file permissions";
        break;
      case 9009:
        additionalInfo = "\n\nTroubleshooting:\n"
            "1. Install Python from https://python.org\n"
            "2. Add Python to your system PATH\n"
            "3. Restart your terminal/IDE after installation";
        break;
      case 1:
        additionalInfo = "\n\nTroubleshooting:\n"
            "1. Check if Django is installed: pip install django\n"
            "2. Verify your virtual environment is activated\n"
            "3. Check if all dependencies are installed";
        break;
    }

    return baseMessage + additionalInfo;
  }
}
