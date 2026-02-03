import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Userbasicdetails.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/widgets/Customloader.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController otpCtrl = TextEditingController();
  final AuthController authController = Get.put(AuthController());

  late final String mobile;

  String? autoOtp;

  @override
  void initState() {
    super.initState();

    mobile = Get.arguments?["mobile"] ?? "";
    autoOtp = Get.arguments?["otp"];

    /// ✅ AUTO FILL OTP (DEV MODE)
    if (autoOtp != null && autoOtp!.length == 6) {
      otpCtrl.text = autoOtp!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          /// 🔹 MAIN UI
          SingleChildScrollView(
            child: Column(
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: topPadding + 28, bottom: 42),
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
                        "Verify OTP",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.07,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Enter the 6-digit code sent to your phone",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.032,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// OTP CARD
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 32),
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
                      /// OTP INPUT
                      Pinput(
                        controller: otpCtrl,
                        length: 6,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                      ),

                      const SizedBox(height: 26),

                      /// VERIFY BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: width * 0.13,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            authController.verifyOtp(
                              mobile: mobile,
                              otp: otpCtrl.text.trim(),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.background,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              "Verify & Continue",
                              style: GoogleFonts.poppins(
                                fontSize: width * 0.042,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// RESEND OTP
                      TextButton(
                        onPressed: () {
                          // authController.sendOtp(mobile: mobile);
                        },
                        child: Text(
                          "Resend OTP",
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🔄 LOADER
          Obx(
            () => authController.isLoading.value
                ? const CustomLoader(text: "Verifying OTP...")
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
