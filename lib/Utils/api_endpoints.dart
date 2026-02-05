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
  static const String GetCart = "/cart";
  static const String Getprofile = "/profile/me";
  static const String cartItemdelete = "/cart";

  static const String Checkout = "/cart/checkout/preview";

  //  Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }
}
