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
  static const String Addaddress = "/address";
  static const String Getaddress = "/address";
  static const String UpdateAddress = "/address";
  static const String DeleteAddress = "/address";
  static const String PlaceOrder = "/cart/checkout";
  static const String Ordertacking = "/orders/active";
  static const String OrderHistory = "/orders/history";
  static const String Searchsociaties = "/kitchens/society-nearby";
  static const String GetNotification = "/notification";
  static const String MarkNotificationRead = "/notification/read-all";

  //  Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }
}
