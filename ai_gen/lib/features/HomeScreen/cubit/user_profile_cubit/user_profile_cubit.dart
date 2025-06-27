import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_state.dart';
import 'package:ai_gen/features/HomeScreen/data/user_profile.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final AuthProvider authRepository;

//   ProfileCubit(this.authRepository) : super(ProfileInitial());

//   Future<void> loadProfile() async {
//     try {
//       emit(ProfileLoading());
//       final profile = await authRepository.getProfile();
//       emit(ProfileLoaded(profile));
//     } catch (e) {
//       emit(ProfileError(e.toString()));
//     }
//   }
// }
// Enhanced ProfileCubit with better error handling and retry logic



class ProfileCubit extends Cubit<ProfileState> {
  final AuthProvider authProvider;
  int _retryCount = 0;
  static const int maxRetries = 3;

  ProfileCubit(this.authProvider) : super(ProfileInitial());

  Future<void> loadProfile({bool showLoading = true}) async {
    if (showLoading) {
      emit(ProfileLoading());
    }

    try {
      _retryCount = 0;
      final profile = await _loadProfileWithRetry();
      emit(ProfileLoaded(profile));
    } catch (e) {
      final errorMessage = _getErrorMessage(e.toString());
      emit(ProfileError(errorMessage));
    }
  }

  Future<UserProfile> _loadProfileWithRetry() async {
    while (_retryCount < maxRetries) {
      try {
        final profile = await authProvider.getProfile();
        return profile;
      } catch (e) {
        _retryCount++;

        if (_retryCount >= maxRetries) {
          rethrow;
        }

        // Wait before retry with exponential backoff
        await Future.delayed(Duration(seconds: _retryCount * 2));
      }
    }

    throw Exception('Failed to load profile after $maxRetries attempts');
  }

  String _getErrorMessage(String error) {
    if (error.contains('No internet connection') ||
        error.contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.contains('timeout') ||
        error.contains('TimeoutException')) {
      return 'Connection timeout. Please try again.';
    } else if (error.contains('Authentication failed') ||
        error.contains('Please log in again')) {
      return 'Your session has expired. Please log in again.';
    } else if (error.contains('401') || error.contains('Unauthorized')) {
      return 'Authentication error. Please try logging in again.';
    } else {
      return 'Unable to load profile. Please try again.';
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile(showLoading: false);
  }

  void retry() {
    loadProfile();
  }
}
