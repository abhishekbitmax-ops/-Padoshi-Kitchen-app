import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameCtrl =
      TextEditingController(text: "Abhishek");
  final TextEditingController phoneCtrl =
      TextEditingController(text: "9876543210");
  final TextEditingController emailCtrl =
      TextEditingController(text: "abhishek@email.com");
  final TextEditingController dobCtrl = TextEditingController();

  DateTime? selectedDob;

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔝 HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: topPadding + 30,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.background,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  /// PROFILE IMAGE
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=3",
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // TODO: pick image
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
                    hint: "Full Name",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  _field(
                    controller: phoneCtrl,
                    hint: "Mobile Number",
                    icon: Icons.phone_android,
                    enabled: false,
                  ),

                  const SizedBox(height: 16),

                  _field(
                    controller: emailCtrl,
                    hint: "Email Address",
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  /// DOB
                  TextField(
                    controller: dobCtrl,
                    readOnly: true,
                    onTap: _pickDob,
                    decoration: _decoration(
                      hint: "Date of Birth",
                      icon: Icons.cake_outlined,
                      suffix: Icons.calendar_month,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 💾 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: width * 0.13,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        // TODO: Save profile API
                        Navigator.pop(context);
                      },
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.background,
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: const Center(
                          child: Text(
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
      ),
    );
  }

  /// 📅 DOB PICKER
  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDob = picked;
      dobCtrl.text = DateFormat("dd MMM yyyy").format(picked);
    }
  }

  /// 🧱 INPUT FIELD
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
      decoration: _decoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    IconData? suffix,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black45),
      suffixIcon: suffix != null ? Icon(suffix) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
