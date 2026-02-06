import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late Map<String, dynamic> order;

  @override
  void initState() {
    super.initState();

    order = (Get.arguments as Map<String, dynamic>?) ?? {};

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = order["orderId"]?.toString() ?? "N/A";
    final price =
        (order["grandTotal"] ??
                order["finalAmount"] ??
                order["pricing"]?["finalAmount"] ??
                order["pricing"]?["grandTotalWithoutDelivery"] ??
                order["pricing"]?["foodTotal"] ??
                0)
            .toString();

    final rawType = (order["payment"]?["type"] ?? "")
        .toString()
        .toUpperCase();
    final rawMethod = (order["payment"]?["method"] ?? "")
        .toString()
        .toUpperCase();
    final rawStatus = (order["paymentStatus"] ?? "")
        .toString()
        .toUpperCase();
    final directMethod =
        (order["paymentMethod"] ?? "").toString().toUpperCase();

    final paymentMethod =
        (directMethod == "COD" ||
                rawStatus.contains("COD") ||
                rawType == "COD" ||
                rawMethod == "COD" ||
                rawMethod == "CASH")
            ? "Cash on Delivery"
            : "Online Payment";

    final paymentStatus = rawStatus == "PAID"
        ? "Paid"
        : (directMethod == "COD" || rawStatus.contains("COD") || rawType == "COD")
            ? "Pay on Delivery"
            : "Pending";

    final address = order["deliveryAddress"];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background.withOpacity(0.15),
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 70,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Order Placed Successfully",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Thank you for ordering with us",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 22),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row("Order ID", orderId),
                      _row("Payment Method", paymentMethod),
                      _row("Payment Status", paymentStatus),
                      _row("Total Amount", "₹$price"),
                      const Divider(height: 26),
                      if (address != null &&
                          address["addressLine"] != null) ...[
                        _row("Name", address["name"] ?? "-"),
                        _row("Mobile", address["phone"] ?? "-"),
                        _row(
                          "Address",
                          "${address["addressLine"]}, "
                          "${address["city"] ?? ""} "
                          "${address["pincode"] ?? ""}",
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.snackbar("Tracking", "Tracking screen not wired yet");
                  },
                  child: const Text(
                    "Track Order",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  final ctrl = Get.find<AuthController>();
                  ctrl.fetchCart(); // refresh cart state
                  Get.offAll(() => const RestaurantBottomNav(initialIndex: 0));
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
