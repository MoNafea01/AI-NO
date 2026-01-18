// import 'package:ai_gen/core/data/cache/cache_helper.dart';
// import 'package:ai_gen/core/data/cache/cahch_keys.dart';

// Future<void> _saveTokens(String access, String refresh) async {
//   if (rememberMe) {
//     await CacheHelper.saveData(
//       key: CacheKeys.accessToken,
//       value: access,
//     );
//     await CacheHelper.saveData(
//       key: CacheKeys.refreshToken,
//       value: refresh,
//     );
//     await CacheHelper.saveData(
//       key: CacheKeys.rememberMe,
//       value: true,
//     );
//     // Save tokens permanently if remember me is checked
//     // await _storage.write(key: 'accessToken', value: access);
//     // await _storage.write(key: 'refreshToken', value: refresh);
//     // await _storage.write(key: 'rememberMe', value: 'true');
//   } else {
//     // Save tokens temporarily (only in memory or with session flag)
//     await CacheHelper.saveData(
//       key: CacheKeys.accessToken,
//       value: access,
//     );
//     await CacheHelper.saveData(
//       key: CacheKeys.refreshToken,
//       value: refresh,
//     );
//     await CacheHelper.saveData(
//       key: CacheKeys.rememberMe,
//       value: true,
//     );
//     // await _storage.write(key: 'sessionAccessToken', value: access);
//     // await _storage.write(key: 'sessionRefreshToken', value: refresh);
//     //await _storage.write(key: 'rememberMe', value: 'false');
//   }
// }
