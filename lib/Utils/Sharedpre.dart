import 'package:get_storage/get_storage.dart';

class TokenStorage {
  /// 🔒 Storage instance
  static final GetStorage _box = GetStorage();

  /// 🔑 Keys
  static const String _accessTokenKey = "ACCESS_TOKEN";
  static const String _refreshTokenKey = "REFRESH_TOKEN";

  // ===================== SAVE =====================

  /// ✅ SAVE TOKENS
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.write(_accessTokenKey, accessToken);
    await _box.write(_refreshTokenKey, refreshToken);
  }

  // ===================== GET =====================

  /// 📥 GET ACCESS TOKEN
  static String? getAccessToken() {
    return _box.read(_accessTokenKey);
  }

  /// 📥 GET REFRESH TOKEN
  static String? getRefreshToken() {
    return _box.read(_refreshTokenKey);
  }

  /// 🧾 GET AUTH HEADER
  /// Use directly in API calls
  static Map<String, String> getAuthHeader() {
    final token = getAccessToken();
    if (token == null) return {};
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ===================== STATUS =====================

  /// 🔍 CHECK LOGIN STATUS
  static bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ===================== CLEAR =====================

  /// 🚪 LOGOUT / CLEAR ALL
  static Future<void> clearTokens() async {
    await _box.remove(_accessTokenKey);
    await _box.remove(_refreshTokenKey);
  }

  /// 🧹 FORCE CLEAR (used on 401 / token expired)
  static Future<void> forceLogout() async {
    await clearTokens();
  }

  // ===================== CART PERSISTENCE =====================

  static const String _cartKey = "CART_DATA";

  /// 💾 SAVE CART DATA
  static Future<void> saveCart(String cartJson) async {
    await _box.write(_cartKey, cartJson);
  }

  /// 📥 GET CART DATA
  static String? getCart() {
    return _box.read(_cartKey);
  }

  /// 🗑️ CLEAR CART DATA
  static Future<void> clearCart() async {
    await _box.remove(_cartKey);
  }
}
