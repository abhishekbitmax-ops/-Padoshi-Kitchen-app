import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class ZomatoCartBar extends StatelessWidget {
  final AuthController authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cartItems = authCtrl.cartItems;
      if (cartItems.isEmpty) return const SizedBox();

      int totalCount = cartItems.length;
      int itemsTotal = authCtrl.itemTotal;
      int deliveryFee = 30;
      int tax = 18;

      // Calculate grand total
      int grandTotal = itemsTotal + deliveryFee + tax;

      return Container(
        height: 62,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.background],
          ),

          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🍽 last added item icon (no image in CartItem model)
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.fastfood, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),

            // Text Section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$totalCount item${totalCount > 1 ? 's' : ''} added",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "₹$grandTotal",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // View Cart Button
            InkWell(
              onTap: () {
                authCtrl.fetchCart();
                Get.offAll(() => const RestaurantBottomNav(initialIndex: 2));
              },
              child: Text(
                "View cart ›",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
