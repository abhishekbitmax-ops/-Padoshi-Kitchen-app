import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:padoshi_kitchen/Modules/Auth/Model/Model.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Userbasicdetails.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Verifyotp.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/Sharedpre.dart';
import 'package:padoshi_kitchen/Utils/api_endpoints.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class AuthController extends GetxController {
  final isLoading = false.obs;
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

  Future<void> saveProfile({
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
        return;
      }

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Accept"] = "application/json";

      /// BASIC FIELDS
      request.fields["fullName"] = fullName;
      request.fields["email"] = email;

      /// ✅ ADDRESS (SEND AS FORM FIELDS, NOT JSON)
      request.fields["address[label]"] = address["label"] ?? "";

      request.fields["address[fullAddress]"] = address["fullAddress"] ?? "";

      request.fields["address[city]"] = address["city"] ?? "";

      request.fields["address[state]"] = address["state"] ?? "";

      request.fields["address[pincode]"] = address["pincode"] ?? "";

      /// GEO LOCATION
      request.fields["address[geoLocation][type]"] = "Point";
      request.fields["address[geoLocation][coordinates][0]"] =
          address["geoLocation"]["coordinates"][0].toString();
      request.fields["address[geoLocation][coordinates][1]"] =
          address["geoLocation"]["coordinates"][1].toString();

      /// IMAGE
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

      debugPrint("PROFILE RESPONSE: $responseBody");

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", data["message"]);
        Get.offAll(() => const RestaurantBottomNav());
      } else {
        Get.snackbar("Error", data["message"] ?? "Profile update failed");
      }
    } catch (e) {
      debugPrint("SAVE PROFILE ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  // kiten fetch current location model can be added here

  /// ❌ ERROR MESSAGE
  /// ❌ ERROR MESSAGE
  final errorMessage = "".obs;

  /// ⏳ LOADING

  /// 🍽️ NEARBY KITCHENS (LIST)
  final kitchens = <Kitchen>[].obs;

  /// 📡 NEARBY KITCHENS API
  Future<void> fetchNearbyKitchens() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "Unauthorized user";
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

        kitchens.assignAll(kitchenResponse.kitchens ?? []);
      } else {
        errorMessage.value = "Failed to load kitchens";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong";
      debugPrint("KITCHEN API ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // -- menu fetch model can be added here --

  /// 📦 API DATA
  /// 📦 API DATA
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
}
