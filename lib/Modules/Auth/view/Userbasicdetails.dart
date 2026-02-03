import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/widgets/Customloader.dart';
import 'package:geocoding/geocoding.dart';

class UserBasicDetailsScreen extends StatefulWidget {
  const UserBasicDetailsScreen({super.key});

  @override
  State<UserBasicDetailsScreen> createState() => _UserBasicDetailsScreenState();
}

class _UserBasicDetailsScreenState extends State<UserBasicDetailsScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final AuthController controller = Get.put(AuthController());
  Future<void> _pickFrom(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (picked == null) {
        // user cancelled → DO NOTHING (no error)
        return;
      }

      controller.setImage(File(picked.path));
    } catch (e) {
      debugPrint("Image picker error: $e");
      Get.snackbar(
        "Permission Required",
        "Please allow camera/gallery permission from settings",
      );
    }
  }

  Widget _addressField() {
    return TextField(
      controller: addressCtrl,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: "Full Address",
        prefixIcon: const Icon(Icons.location_on),
        suffixIcon: IconButton(
          icon: const Icon(Icons.my_location, color: AppColors.primary),
          onPressed: _fetchCurrentAddress,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _fetchCurrentAddress() async {
    try {
      // permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";

        addressCtrl.text = address;
      }
    } catch (e) {
      Get.snackbar("Location Error", "Unable to fetch current location");
    }
  }

  /// 📷 PICK IMAGE
  Future<void> pickImage() async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Get.back();
                _pickFrom(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Get.back();
                _pickFrom(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// 🔶 HEADER
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: topPadding + 28, bottom: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.background],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Complete Your Profile",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.07,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Few more details to continue",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.032,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// 👤 PROFILE IMAGE
                GetBuilder<AuthController>(
                  builder: (_) => GestureDetector(
                    onTap: pickImage,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          backgroundImage: controller.profileImage != null
                              ? FileImage(controller.profileImage!)
                              : null,
                          child: controller.profileImage == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Upload Profile Photo",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 🔶 FORM CARD
                _formCard(width),

                const SizedBox(height: 40),
              ],
            ),
          ),

          /// 🔄 LOADER
          Obx(
            () => controller.isLoading.value
                ? const CustomLoader(text: "Saving profile...")
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  /// 🧾 FORM CARD
  Widget _formCard(double width) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.06),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(blurRadius: 26, color: Colors.black.withOpacity(0.08)),
        ],
      ),
      child: Column(
        children: [
          _field(nameCtrl, "Full Name", Icons.person),
          const SizedBox(height: 16),
          _field(emailCtrl, "Email", Icons.email),
          const SizedBox(height: 16),
          _addressField(),

          const SizedBox(height: 26),

          /// ✅ CONTINUE
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: _submitProfile,
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🚀 SUBMIT PROFILE (MATCHES API)
  void _submitProfile() {
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty) {
      Get.snackbar("Missing Info", "Please fill all fields");
      return;
    }

    controller.saveProfile(
      fullName: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      address: {
        "label": "Home",
        "fullAddress": addressCtrl.text.trim(),
        "city": "",
        "state": "",
        "pincode": "",
        "geoLocation": {
          "type": "Point",
          "coordinates": [0.0, 0.0],
        },
      },
    );
  }

  /// 🔤 INPUT FIELD
  Widget _field(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
