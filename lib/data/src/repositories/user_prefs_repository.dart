import 'package:shared_preferences/shared_preferences.dart';

const _keyUserName = 'user_name';
const _keyCookedCount = 'cooked_count';
const _keySavedCount = 'saved_count';
const _defaultUserName = 'Славе';

/// Abstraction for user preferences persistence.
///
/// Uses [SharedPreferences] under the hood. All getters are
/// synchronous after the initial [SharedPreferences] instance
/// is created during app startup.
class UserPrefsRepository {
  UserPrefsRepository({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  /// Returns the user's display name.
  String getUserName() {
    return _prefs.getString(_keyUserName) ?? _defaultUserName;
  }

  /// Returns the total number of completed recipes.
  int getCookedCount() {
    return _prefs.getInt(_keyCookedCount) ?? 0;
  }

  /// Increments the cooked recipe counter by one.
  Future<void> incrementCookedCount() async {
    final current = getCookedCount();
    await _prefs.setInt(_keyCookedCount, current + 1);
  }

  /// Returns the number of saved/bookmarked recipes.
  int getSavedCount() {
    return _prefs.getInt(_keySavedCount) ?? 0;
  }
}
