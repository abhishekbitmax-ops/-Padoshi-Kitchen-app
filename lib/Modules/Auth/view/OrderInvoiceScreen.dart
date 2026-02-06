import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Addressmodel.dart';

class OrderInvoiceScreen extends StatelessWidget {
  final AuthController authCtrl = Get.find<AuthController>();

  OrderInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final address = args?["address"];
    final modeArg = args?["mode"]?.toString();
    final paymentArg = args?["paymentMode"]?.toString();
    final mode =
        modeArg ?? authCtrl.checkoutResponse.value?.delivery?.mode ?? "";
    final paymentMode = paymentArg ?? "N/A";
    final addressText = address == null
        ? "Selected Address"
        : _formatAddress(address);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          /// 🔝 HEADER
          Container(
            height: 120,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.background],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Order Invoice",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Review your order details",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    "Edit Cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 💰 TOTAL CARD
          Obx(() {
            final pricing = authCtrl.checkoutResponse.value?.pricing;
            final total =
                pricing?.finalAmount ??
                pricing?.grandTotalWithoutDelivery ??
                pricing?.foodTotal ??
                authCtrl.itemTotal;

            return Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 35),
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.background],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "₹$total",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "TOTAL TO PAY",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          }),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// 🧾 ITEMS
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Items",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Obx(() {
                          final items = authCtrl.cartItems;
                          if (items.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "No items in cart",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return Column(
                            children: items
                                .map(
                                  (item) => _itemRow(
                                    qty: item.quantity ?? 1,
                                    name: item.name ?? "Item",
                                    variant: item.variant?.label ?? "Standard",
                                    price: "₹${item.itemTotal ?? 0}",
                                  ),
                                )
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),

                  /// 📍 ADDRESS & PAYMENT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            title: "DELIVER TO",
                            value:
                                mode == "SELF_PICKUP"
                                    ? "Self Pickup Selected"
                                    : addressText,
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            title: "MODE",
                            value: mode.isEmpty ? "N/A" : mode,
                            icon: Icons.local_shipping_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _infoCard(
                      title: "PAYMENT",
                      value: paymentMode,
                      icon: Icons.payment,
                    ),
                  ),

                  /// 📊 BILL SUMMARY
                  _card(
                    child: Obx(() {
                      final pricing = authCtrl.checkoutResponse.value?.pricing;
                      final itemTotal =
                          pricing?.itemTotal ??
                          pricing?.foodTotal ??
                          authCtrl.itemTotal;
                      final gstAmount = pricing?.gstAmount;
                      final platformFee = pricing?.platformFee;
                      final deliveryFee = pricing?.deliveryCharge;
                      final grandTotal =
                          pricing?.finalAmount ??
                          pricing?.grandTotalWithoutDelivery ??
                          itemTotal;

                      return Column(
                        children: [
                          _billRow("Item Total", "₹$itemTotal"),
                          if (gstAmount != null)
                            _billRow("GST", "₹$gstAmount"),
                          if (platformFee != null)
                            _billRow("Platform Fee", "₹$platformFee"),
                          if (deliveryFee != null)
                            _billRow(
                              "Delivery Fee",
                              deliveryFee == 0 ? "FREE" : "₹$deliveryFee",
                              valueColor:
                                  deliveryFee == 0 ? Colors.green : null,
                            ),
                          const Divider(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Grand Total",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₹$grandTotal",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          /// 🟢 PAY BUTTON
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 25, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: Obx(() {
                final grandTotal = authCtrl.itemTotal;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // Payment logic will be added here
                    Get.snackbar("Success", "Payment processing...");
                  },
                  child: Text(
                    "PAY ONLINE  ₹$grandTotal  →",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧱 CARD
  static Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  /// 🍽 ITEM ROW
  static Widget _itemRow({
    required int qty,
    required String name,
    required String variant,
    required String price,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "${qty}x",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                variant,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// ℹ INFO CARD
  static Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.background),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// 💰 BILL ROW
  static Widget _billRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAddress(dynamic address) {
    if (address is Address) {
      final parts = <String>[
        address.addressLine ?? "",
        address.societyName ?? "",
      ];
      return parts.where((e) => e.trim().isNotEmpty).join(", ");
    }
    return address.toString();
  }
}
