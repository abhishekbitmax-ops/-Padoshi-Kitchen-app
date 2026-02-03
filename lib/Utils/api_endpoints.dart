class ApiEndpoint {
  //  Base API URL (for all API requests)
  static const String baseUrl =
      "https://padoshi-kitchen-b.onrender.com/api/v1/user";

  //  AUTHENTICATION ENDPOINTS

  static const String login = "/auth/send-otp";
  static const String verifyOtp = "/auth/verify-otp";
  static const String userDetails = "/profile/me";
  static const String autoSelectKitchen = "/kitchen/recomend";
  static const String AddtoCart = "/cart";

  //  Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }
}
