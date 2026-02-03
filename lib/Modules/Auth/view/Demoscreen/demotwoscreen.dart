import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Demoscreen/demothree.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/login.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class Demotwoscreen extends StatelessWidget {
  const Demotwoscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// 🔥 FULL SCREEN IMAGE
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              "assets/images/demo_two.jpg", // 👈 your image path
              fit: BoxFit.cover,
            ),
          ),

          /// 🔥 DARK GRADIENT OVERLAY (for readability)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.45),
                ],
              ),
            ),
          ),

          /// ⏭️ SKIP BUTTON (TOP RIGHT)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: TextButton(
              onPressed: () {
                // 👉 Navigate to Home / Login
              },
              child: InkWell(
                onTap: () => Get.to(LoginScreen()),
                child: Text(
                  "Skip",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFE082), // soft gold
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          /// 🔽 NEXT BUTTON (BOTTOM - IMAGE MATCHED)
          Positioned(
            left: 20,
            right: 20,
            bottom: 50,
            child: GestureDetector(
              onTap: () {
                Get.to(Demothreescreen());
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD4AF37), // gold
                      Color(0xFFB8962E), // deep gold
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD4AF37).withOpacity(0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Next",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
