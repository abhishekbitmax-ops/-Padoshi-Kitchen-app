import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/widgets/Customloader.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController controller = Get.find<AuthController>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Obx(() {
        final user = controller.user;

        if (controller.isLoading.value && user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: topPadding + 30, bottom: 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.background],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Top-right back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    /// PROFILE IMAGE
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        /// 🔝 HEADER
                        GetBuilder<AuthController>(
                          builder: (c) {
                            return CircleAvatar(
                              radius: 42,
                              backgroundImage: c.profileImage != null
                                  ? FileImage(c.profileImage!)
                                  : NetworkImage(
                                          user?.profileImage ??
                                              "https://i.pravatar.cc/150?img=3",
                                        )
                                        as ImageProvider,
                            );
                          },
                        ),

                        InkWell(
                          onTap: () {
                            _openImagePickerSheet();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Edit Profile",
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              /// 🧾 FORM CARD
              Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 34),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 26,
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _field(
                      controller: nameCtrl,
                      hint: user?.fullName ?? "Full Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    _field(
                      controller: phoneCtrl,
                      hint: user?.mobile != null
                          ? "+91 ${user!.mobile}"
                          : "Mobile Number",
                      icon: Icons.phone_android,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    _field(
                      controller: emailCtrl,
                      hint: user?.email ?? "Email Address",
                      icon: Icons.email_outlined,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 30),

                    /// 💾 SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: width * 0.13,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                await controller.saveProfile(
                                  fullName: nameCtrl.text.isNotEmpty
                                      ? nameCtrl.text
                                      : user?.fullName ?? "",
                                  email: emailCtrl.text.isNotEmpty
                                      ? emailCtrl.text
                                      : user?.email ?? "",
                                  address: {
                                    "label": user?.defaultAddress?.label ?? "",
                                    "fullAddress":
                                        user?.defaultAddress?.addressLine ?? "",
                                    "city": "",
                                    "state": "",
                                    "pincode": "",
                                    "geoLocation": {
                                      "coordinates":
                                          user
                                              ?.defaultAddress
                                              ?.geoLocation
                                              ?.coordinates ??
                                          [0, 0],
                                    },
                                  },
                                );

                                controller.fetchProfile();
                                Get.offAll(
                                  () => const RestaurantBottomNav(
                                    initialIndex: 3,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.background],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 75);

    if (picked != null) {
      controller.setImage(File(picked.path));
    }
  }

  void _openImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
