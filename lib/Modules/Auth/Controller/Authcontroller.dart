import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:padoshi_kitchen/Modules/Auth/Model/Model.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Addressmodel.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Userbasicdetails.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Verifyotp.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/Sharedpre.dart';
import 'package:padoshi_kitchen/Utils/api_endpoints.dart';
import 'package:padoshi_kitchen/Utils/socket_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class AuthController extends GetxController {
  final isLoading = false.obs;
  final isAddressLoading = false.obs;
  final isPlacingOrder = false.obs;
  final RxString selectedCategoryId = "".obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchNearbyKitchens();
  // }

  /// 🔐 SEND OTP (LOGIN)
  /// 🔐 SEND OTP (LOGIN)
  Future<void> sendOtp({
    required String mobile,
    required Null Function() onSuccess,
  }) async {
    if (mobile.length != 10) {
      Get.snackbar("Invalid Number", "Please enter valid 10 digit number");
      return;
    }

    try {
      isLoading.value = true;

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.login));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobile": mobile}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Sent OTP to $data");

        /// ✅ PASS OTP ALSO (FOR TESTING)
        Get.to(
          () => const VerifyOtpScreen(),
          arguments: {
            "mobile": mobile,
            "otp": data["otp"]?.toString(), // 👈 auto fill
          },
        );

        Get.snackbar("OTP Sent", data["message"] ?? "OTP sent successfully");
      } else {
        Get.snackbar("Error", data["message"] ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Network Error", "Please check your internet");
    } finally {
      isLoading.value = false;
    }
  }

  // ---- verify OTP function can be added here ----

  /// ✅ VERIFY OTP
  /// ✅ VERIFY OTP
  Future<void> verifyOtp({required String mobile, required String otp}) async {
    if (otp.length != 6) {
      Get.snackbar("Invalid OTP", "Please enter 6 digit OTP");
      return;
    }

    try {
      isLoading.value = true;

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.verifyOtp));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobile": mobile, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("OTP Verified: $data");

        /// 🔐 SAVE TOKENS (IMPORTANT)
        await TokenStorage.saveTokens(
          accessToken: data["accessToken"],
          refreshToken: data["refreshToken"],
        );
        SocketService.connect(data["accessToken"]);
        SocketService.bindOrderNotifications();

        final bool profileCompleted = data["profileCompleted"] ?? false;

        /// 🚦 NAVIGATION
        if (profileCompleted) {
          Get.offAll(() => const RestaurantBottomNav());
        } else {
          Get.offAll(() => const UserBasicDetailsScreen());
        }

        Get.snackbar("Success", "Login successful");
      } else {
        Get.snackbar("Verification Failed", data["message"] ?? "Invalid OTP");
      }
    } catch (e) {
      Get.snackbar("Network Error", "Please check your internet");
    } finally {
      isLoading.value = false;
    }
  }

  // user basic details function can be added here

  File? profileImage;

  void setImage(File img) {
    profileImage = img;
    update();
  }

  Future<bool> saveProfile({
    required String fullName,
    required String email,
    required Map<String, dynamic> address,
  }) async {
    try {
      isLoading.value = true;

      final uri = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.userDetails));
      final request = http.MultipartRequest("PUT", uri);

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        return false;
      }

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Accept"] = "application/json";

      request.fields["fullName"] = fullName;
      request.fields["email"] = email;

      request.fields["address[label]"] = address["label"] ?? "";
      request.fields["address[fullAddress]"] = address["fullAddress"] ?? "";
      request.fields["address[city]"] = address["city"] ?? "";
      request.fields["address[state]"] = address["state"] ?? "";
      request.fields["address[pincode]"] = address["pincode"] ?? "";

      request.fields["address[geoLocation][type]"] = "Point";
      request.fields["address[geoLocation][coordinates][0]"] =
          address["geoLocation"]["coordinates"][0].toString();
      request.fields["address[geoLocation][coordinates][1]"] =
          address["geoLocation"]["coordinates"][1].toString();

      if (profileImage != null) {
        final ext = path.extension(profileImage!.path).toLowerCase();
        final mime = (ext == ".png") ? "png" : "jpeg";

        request.files.add(
          await http.MultipartFile.fromPath(
            "profileImage",
            profileImage!.path,
            contentType: MediaType("image", mime),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", data["message"] ?? "Profile updated");
        return true;
      } else {
        Get.snackbar("Error", data["message"] ?? "Profile update failed");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // kiten fetch current location model can be added here

  final errorMessage = "".obs;

  /// ⏳ LOADING

  /// 🍽️ NEARBY KITCHENS (LIST)
  final kitchens = <Kitchen>[].obs;

  /// 📡 NEARBY KITCHENS API
  ///
  /// This method now retries a few times if the auth token isn't available
  /// immediately (handles small race conditions during first app open).
  Future<void> fetchNearbyKitchens({int retries = 3}) async {
    try {
      // mark loading immediately but update observable values after the frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = true;
        errorMessage.value = "";
      });

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        if (retries > 0) {
          debugPrint(
            "fetchNearbyKitchens: token not ready, retrying in 500ms (retries left: $retries)",
          );
          await Future.delayed(const Duration(milliseconds: 500));
          return fetchNearbyKitchens(retries: retries - 1);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          errorMessage.value = "Unauthorized user";
        });
        return;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.autoSelectKitchen));

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final KitchenResponse kitchenResponse = KitchenResponse.fromJson(data);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          kitchens.assignAll(kitchenResponse.kitchens ?? []);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          errorMessage.value = "Failed to load kitchens";
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        errorMessage.value = "Something went wrong";
      });
      debugPrint("KITCHEN API ERROR: $e");
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  // -- menu fetch model can be added here --

  final Rx<MenuResponse?> menuResponse = Rx<MenuResponse?>(null);

  /// 🗂️ EXPOSED LISTS
  List<Category> get categories => menuResponse.value?.categories ?? [];
  List<Item> get items => menuResponse.value?.items ?? [];

  /// 🚀 FETCH MENU
  Future<void> fetchMenu({required String kitchenId}) async {
    try {
      isLoading.value = true;
      menuResponse.value = null;
      selectedCategoryId.value = ""; // ✅ reset

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("Unauthorized");
      }

      final url =
          "https://padoshi-kitchen-b.onrender.com/api/v1/user/kitchen/$kitchenId/menu";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final parsed = MenuResponse.fromJson(decoded);

        menuResponse.value = parsed;

        /// ✅ SET DEFAULT CATEGORY HERE (SAFE PLACE)
        if (parsed.categories != null && parsed.categories!.isNotEmpty) {
          selectedCategoryId.value = parsed.categories!.first.id ?? "";
        }
      } else {
        throw Exception("Failed to load menu");
      }
    } catch (e) {
      debugPrint("MENU API ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //-- Add to cart api

  final isAdding = false.obs;

  /// 🛒 ADD TO CART API
  Future<void> addToCart({
    required String kitchenId,
    required String menuItemId,
    required String variantLabel,
    required int quantity,
    required List<String> addonNames,
    Map<String, dynamic>? customization,
  }) async {
    try {
      isAdding.value = true;

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("Unauthorized user");
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.AddtoCart));

      /// 🔥 REQUEST BODY (MATCHES YOUR API)
      final body = {
        "kitchenId": kitchenId,
        "menuItemId": menuItemId,
        "variantLabel": variantLabel,
        "quantity": quantity,
        "addons": addonNames.map((e) => {"name": e}).toList(),
        "customization":
            customization ??
            {"spiceLevel": "Medium", "isJain": false, "notes": ""},
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("ADD TO CART SUCCESS: $data");
        Get.snackbar("Added to Cart", data["message"] ?? "Item added");

        // Refresh cart so UI updates immediately
        await fetchCart();
      } else {
        Get.snackbar("Cart Error", data["message"] ?? "Failed to add item");
        debugPrint("ADD TO CART FAILED: $data");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
      debugPrint("ADD TO CART ERROR: $e");
    } finally {
      isAdding.value = false;
    }
  }

  //-----  Get Cart API

  /// 🛒 CART RESPONSE
  final Rx<CartResponse?> cartResponse = Rx<CartResponse?>(null);

  /// 🧾 CART ITEMS (SAFE GETTER)
  List<CartItem> get cartItems => cartResponse.value?.cart?.items ?? [];

  /// 💰 TOTAL CALCULATIONS
  int get itemTotal => cartItems.fold(0, (sum, e) => sum + (e.itemTotal ?? 0));

  /// 📦 FETCH CART API
  Future<void> fetchCart() async {
    try {
      // Schedule state updates after current frame to avoid marking widgets dirty
      // while the framework is building (prevents "setState() called during build" errors).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = true;
        errorMessage.value = "";
      });

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          errorMessage.value = "Unauthorized user";
        });
        return;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.GetCart));

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cartResponse.value = CartResponse.fromJson(decoded);
          // 💾 SAVE CART DATA TO PERSISTENT STORAGE
          TokenStorage.saveCart(jsonEncode(decoded));
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          errorMessage.value = "Failed to load cart";
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        errorMessage.value = "Something went wrong";
      });
      debugPrint("GET CART ERROR: $e");
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  /// 📥 LOAD CART FROM PERSISTENT STORAGE
  Future<void> loadCachedCart() async {
    try {
      final cachedCartJson = TokenStorage.getCart();
      if (cachedCartJson != null && cachedCartJson.isNotEmpty) {
        final decoded = jsonDecode(cachedCartJson);
        cartResponse.value = CartResponse.fromJson(decoded);
        debugPrint("Cart loaded from cache");
      }
    } catch (e) {
      debugPrint("ERROR LOADING CACHED CART: $e");
    }
  }

  ///  REMOVE ITEM (LOCAL ONLY – UI SMOOTHNESS)
  void removeItem(String menuItemId) {
    final current = cartResponse.value;
    if (current == null || current.cart?.items == null) return;

    final updatedItems = current.cart!.items!
        .where((e) => e.menuItemId != menuItemId)
        .toList();

    cartResponse.value = CartResponse(
      success: current.success,
      cart: CartData(
        userId: current.cart!.userId,
        kitchenId: current.cart!.kitchenId,
        updatedAt: current.cart!.updatedAt,
        items: updatedItems,
      ),
    );
  }

  /// ➕➖ UPDATE QTY (LOCAL ONLY)
  void updateQuantity(String menuItemId, int qty) {
    final current = cartResponse.value;
    if (current == null || current.cart?.items == null) return;

    final updatedItems = current.cart!.items!.map((item) {
      if (item.menuItemId == menuItemId) {
        final price = item.variant?.price ?? 0;
        return CartItem(
          menuItemId: item.menuItemId,
          name: item.name,
          variant: item.variant,
          addons: item.addons,
          quantity: qty,
          customization: item.customization,
          itemTotal:
              price * qty +
              (item.addons?.fold<int>(0, (s, a) => s + (a.price ?? 0)) ?? 0),
        );
      }
      return item;
    }).toList();

    cartResponse.value = CartResponse(
      success: current.success,
      cart: CartData(
        userId: current.cart!.userId,
        kitchenId: current.cart!.kitchenId,
        updatedAt: current.cart!.updatedAt,
        items: updatedItems,
      ),
    );
  }

  // -- DELETE CART ITEM (API)
  final RxList<String> removingItems = <String>[].obs;

  Future<void> deleteCartItem({required String menuItemId}) async {
    final kitchenId = cartResponse.value?.cart?.kitchenId;
    if (kitchenId == null) {
      Get.snackbar("Error", "Kitchen ID missing");
      return;
    }

    try {
      removingItems.add(menuItemId);

      final item = cartResponse.value?.cart?.items?.firstWhere(
        (e) => e.menuItemId == menuItemId,
        orElse: () => CartItem(),
      );

      final variantLabel = item?.variant?.label ?? "Standard";
      final addons = item?.addons?.map((a) => a.name ?? "").toList() ?? [];

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.cartItemdelete));

      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer ${TokenStorage.getAccessToken()}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "kitchenId": kitchenId,
          "menuItemId": menuItemId,
          "variantLabel": variantLabel,
          "addons": addons,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update UI immediately by removing the item locally
        removeItem(menuItemId);

        // Also refresh from server in background to ensure sync
        fetchCart();

        Get.snackbar("Removed", "Item removed from cart");
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", data["message"] ?? "Failed to remove item");
      }
    } catch (e) {
      debugPrint("DELETE CART ITEM ERROR: $e");
      Get.snackbar("Error", "Failed to remove item");
    } finally {
      removingItems.remove(menuItemId);
    }
  }

  //// -- get profile api

  /// 👤 Profile Response
  final Rx<UserProfileResponse?> profileResponse = Rx<UserProfileResponse?>(
    null,
  );

  /// 👤 Shortcut getter
  UserData? get user => profileResponse.value?.user;

  /// 📡 FETCH PROFILE
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "Unauthorized user";
        return;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.Getprofile));

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        profileResponse.value = UserProfileResponse.fromJson(decoded);

        debugPrint(" PROFILE LOADED");
      } else {
        errorMessage.value = "Failed to load profile";
        debugPrint(" PROFILE API ERROR: ${response.body}");
      }
    } catch (e) {
      errorMessage.value = "Something went wrong";
      debugPrint(" PROFILE EXCEPTION: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔁 CLEAR PROFILE (OPTIONAL)
  void clearProfile() {
    profileResponse.value = null;
  }

  /// 🧹 CLEAR CART DATA (OPTIONAL)

  // Clear  cart data (optional, can be used on logout)

  //final RxList<String> removingItems = <String>[].obs;

  Future<void> ClearCart({required String menuItemId}) async {
    try {
      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.cartItemdelete));

      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer ${TokenStorage.getAccessToken()}"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update UI immediately by removing the item locally
        removeItem(menuItemId);

        // Also refresh from server in background to ensure sync
        fetchCart();

        Get.snackbar("Removed", "Item removed from cart");
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", data["message"] ?? "Failed to remove item");
      }
    } catch (e) {
      debugPrint("DELETE CART ITEM ERROR: $e");
      Get.snackbar("Error", "Failed to remove item");
    } finally {
      removingItems.remove(menuItemId);
    }
  }

  /// 🧹 CLEAR CART LOCALLY (UI ONLY)
  void clearCartLocal() {
    cartResponse.value = CartResponse(
      success: true,
      cart: CartData(
        userId: cartResponse.value?.cart?.userId,
        kitchenId: cartResponse.value?.cart?.kitchenId,
        updatedAt: DateTime.now().toIso8601String(),
        items: [],
      ),
    );
    TokenStorage.clearCart();
  }

  // ========== 🛍️ CHECKOUT API ==========

  final Rx<CheckoutResponse?> checkoutResponse = Rx<CheckoutResponse?>(null);
  final isCheckingOut = false.obs;

  /// 🛒 CHECKOUT API (POST)
  /// Sends delivery mode and gets pricing + delivery info
  Future<bool> checkout({
    required String deliveryMode, // SELF_PICKUP, KITCHEN_RIDER, THIRD_PARTY
    String? addressId,
  }) async {
    try {
      isCheckingOut.value = true;

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        return false;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.Checkout));

      /// 🔥 REQUEST BODY (MATCHES YOUR API)
      final delivery = {
        "mode": deliveryMode, // SELF_PICKUP, KITCHEN_RIDER, THIRD_PARTY
      };
      if (deliveryMode != "SELF_PICKUP" &&
          addressId != null &&
          addressId.isNotEmpty) {
        delivery["addressId"] = addressId;
      }

      final body = {"delivery": delivery};

      debugPrint("CHECKOUT REQUEST: $body");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      debugPrint("CHECKOUT RESPONSE: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse and store response
        checkoutResponse.value = CheckoutResponse.fromJson(data);

        Get.snackbar("Success", data["message"] ?? "Checkout successful");

        return true;
      } else {
        Get.snackbar("Checkout Error", data["message"] ?? "Failed to checkout");
        return false;
      }
    } catch (e) {
      debugPrint("CHECKOUT ERROR: $e");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isCheckingOut.value = false;
    }
  }

  // ========== 📍 ADD ADDRESS API ==========
  Future<bool> addAddress({
    required String label,
    required String addressLine,
    required String societyName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      isLoading.value = true;

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        return false;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.Addaddress));

      final body = {
        "label": label,
        "addressLine": addressLine,
        "societyName": societyName,
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "isDefault": isDefault,
      };

      debugPrint("ADD ADDRESS REQUEST: $body");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", data["message"] ?? "Address saved");
        return true;
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to save address");
        return false;
      }
    } catch (e) {
      debugPrint("ADD ADDRESS ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== 📬 GET ADDRESS API ==========
  final Rx<AddressResponse?> addressResponse = Rx<AddressResponse?>(null);

  List<Address> get addresses => addressResponse.value?.addresses ?? [];

  Future<void> fetchAddresses() async {
    try {
      isAddressLoading.value = true;

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        return;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.Getaddress));

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        addressResponse.value = AddressResponse.fromJson(decoded);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", data["message"] ?? "Failed to load addresses");
      }
    } catch (e) {
      debugPrint("GET ADDRESS ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isAddressLoading.value = false;
    }
  }

  // ========== ✏️ UPDATE ADDRESS API ==========
  Future<bool> updateAddress({
    required String addressId,
    required String label,
    required String addressLine,
    required String societyName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      isLoading.value = true;

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        return false;
      }

      final url = Uri.parse(
        "${ApiEndpoint.getUrl(ApiEndpoint.UpdateAddress)}/$addressId",
      );

      final body = {
        "label": label,
        "addressLine": addressLine,
        "societyName": societyName,
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "isDefault": isDefault,
      };

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", data["message"] ?? "Address updated");
        return true;
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to update address");
        return false;
      }
    } catch (e) {
      debugPrint("UPDATE ADDRESS ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== 🗑️ DELETE ADDRESS API ==========
  Future<bool> deleteAddress({required String addressId}) async {
    try {
      isLoading.value = true;

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        return false;
      }

      final url = Uri.parse(
        "${ApiEndpoint.getUrl(ApiEndpoint.DeleteAddress)}/$addressId",
      );

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Deleted", data["message"] ?? "Address deleted");
        return true;
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to delete address");
        return false;
      }
    } catch (e) {
      debugPrint("DELETE ADDRESS ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== 🧾 PLACE ORDER API ==========
  final Rx<Map<String, dynamic>?> placeOrderResponse =
      Rx<Map<String, dynamic>?>(null);

  Future<Map<String, dynamic>?> placeOrder({
    required String deliveryMode,
    String? addressId,
    required String paymentMethod, // COD / ONLINE
  }) async {
    try {
      isPlacingOrder.value = true;

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        return null;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.PlaceOrder));

      final delivery = {"mode": deliveryMode};
      if (deliveryMode != "SELF_PICKUP" &&
          addressId != null &&
          addressId.isNotEmpty) {
        delivery["addressId"] = addressId;
      }

      final body = {
        "delivery": delivery,
        "payment": {"method": paymentMethod},
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("ORDER PLACED: $data");
        placeOrderResponse.value = data;

        return data;
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to place order");
        return null;
      }
    } catch (e) {
      debugPrint("PLACE ORDER ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
      return null;
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
