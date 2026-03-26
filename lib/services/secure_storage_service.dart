import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> read(String key) => _secure.read(key: key);
  Future<void> write(String key, String value) => _secure.write(key: key, value: value);
  Future<void> delete(String key) => _secure.delete(key: key);

  Future<String?> readWithMigration({
    required String secureKey,
    required String legacyPrefsKey,
  }) async {
    final secureValue = await read(secureKey);
    if (secureValue != null && secureValue.isNotEmpty) {
      return secureValue;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(legacyPrefsKey);
    if (legacy != null && legacy.isNotEmpty) {
      await write(secureKey, legacy);
      await prefs.remove(legacyPrefsKey);
      return legacy;
    }
    return null;
  }
}
