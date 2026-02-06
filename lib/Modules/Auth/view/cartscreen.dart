import 'package:flutter/material.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/OrderInvoiceScreen.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/widgets/GetAddress.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Addressmodel.dart';
import 'package:padoshi_kitchen/widgets/Customloader.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  final AuthController controller = Get.find<AuthController>();

  int deliveryMethod = 0; // 0 rider,1 third party,2 pickup
  int paymentMethod = 0; // 0 online,1 cod

  Address? selectedAddress;

  int get itemTotal => controller.itemTotal;

  int get grandTotal {
    if (controller.cartItems.isEmpty) {
      return 0;
    }
    return itemTotal;
  }

  Future<void> openAddressBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddressBottomSheet(),
    );

    if (result != null) {
      setState(() {
        selectedAddress = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // Fetch cart when screen initializes (post-frame to avoid rebuild conflicts)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCart();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _checkoutButton(),

      body: Stack(
        children: [
          Column(
            children: [
          /// 🔝 HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            width: double.infinity,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Checkout 🛒",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// 🗑️ CLEAR CART BUTTON
                Obx(() {
                  final isEmpty = controller.cartItems.isEmpty;

                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEmpty ? Colors.grey : Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isEmpty
                        ? null
                        : () {
                            controller.ClearCart(menuItemId: '');
                          },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Clear Cart",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🎞️ CONTENT
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = controller.cartItems;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (items.isEmpty)
                        _emptyCartView()
                      else ...[
                        ...items.map((e) => _cartItem(e)).toList(),
                        const SizedBox(height: 16),
                        _deliveryAddress(),
                        const SizedBox(height: 16),
                        _deliveryMethod(),
                        const SizedBox(height: 16),
                        _paymentMethod(),
                        const SizedBox(height: 20),
                        _billingDetails(),
                        const SizedBox(height: 120),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ),
            ],
          ),
          Obx(
            () => controller.isCheckingOut.value
                ? const CustomLoader(text: "Checking out...")
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 🟢 PREMIUM CHECKOUT BAR
  Widget _checkoutButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 💰 AMOUNT (LEFT)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Grand Total",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  "₹${grandTotal}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          /// 🟢 CHECKOUT BUTTON (RIGHT)
          SizedBox(
            height: 48,
            child: Obx(() {
              final isEmpty = controller.cartItems.isEmpty;
              final isCheckingOut = controller.isCheckingOut.value;

                return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEmpty ? Colors.grey : AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isEmpty
                    ? null
                    : () async {
                        final mode = deliveryMethod == 0
                            ? "KITCHEN_RIDER"
                            : deliveryMethod == 1
                            ? "THIRD_PARTY"
                            : "SELF_PICKUP";

                        if (mode != "SELF_PICKUP" &&
                            (selectedAddress?.id == null ||
                                selectedAddress!.id!.isEmpty)) {
                          Get.snackbar(
                            "Address Required",
                            "Please select delivery address",
                          );
                          return;
                        }

                        final ok = await controller.checkout(
                          deliveryMode: mode,
                          addressId: selectedAddress?.id,
                        );

                        if (ok) {
                          Get.to(
                            () => OrderInvoiceScreen(),
                            arguments: {
                              "address": selectedAddress,
                              "mode": mode,
                              "paymentMode": paymentMethod == 0
                                  ? "ONLINE"
                                  : "COD",
                            },
                          );
                        }
                      },
                child: const Row(
                  children: [
                    Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 🧾 BILLING DETAILS
  Widget _billingDetails() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Billing Details",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _billRow("Item Total", "₹$itemTotal", isTotal: true),
        ],
      ),
    );
  }

  Widget _billRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 🧾 CART ITEM
  Widget _cartItem(item) {
    final qty = item.quantity ?? 1;
    final price = item.variant?.price ?? 0;
    final itemTotal = item.itemTotal ?? (price * qty);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D4D4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/demo_one.jpg',
              height: 66,
              width: 66,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          /// ITEM INFO + QTY
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? "Item",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "₹$price",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _qtyControl(item),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// RIGHT SIDE (DELETE + TOTAL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(() {
                final removing =
                    (item.menuItemId != null &&
                    controller.removingItems.contains(item.menuItemId));

                return InkWell(
                  onTap: removing
                      ? null
                      : () {
                          if (item.menuItemId != null) {
                            controller.deleteCartItem(
                              menuItemId: item.menuItemId!,
                            );
                          } else {
                            Get.snackbar("Error", "Item id missing");
                          }
                        },
                  child: removing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                );
              }),
              const SizedBox(height: 22),
              Text(
                "₹$itemTotal",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B0000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyCartView() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 90,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Looks like you haven’t added anything yet",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // go back to menu
            },
            child: const Text(
              "Browse Menu",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ➕➖ QTY
  Widget _qtyControl(item) {
    final currentQty = item.quantity ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8C9C9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (currentQty > 1 && item.menuItemId != null) {
                controller.updateQuantity(item.menuItemId!, currentQty - 1);
              }
            },
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDADA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, size: 16, color: Colors.red),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "$currentQty",
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              if (item.menuItemId != null) {
                controller.updateQuantity(item.menuItemId!, currentQty + 1);
              }
            },
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFDFF5E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  /// 📍 ADDRESS
  Widget _deliveryAddress() {
    return _card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: deliveryMethod == 2
            ? null
            : () => openAddressBottomSheet(context),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.background,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Deliver To",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  if (deliveryMethod == 2) ...[
                    const Text(
                      "Self Pickup Selected",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "You will pick up the order from the kitchen.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ] else ...[
                    Text(
                      (selectedAddress?.label ?? "Select Address")
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedAddress == null
                          ? "Tap to choose delivery address"
                          : _fullAddress(selectedAddress!),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.edit_location_alt_outlined,
              color: AppColors.background,
            ),
          ],
        ),
      ),
    );
  }

  /// 🚴 DELIVERY METHOD
  Widget _deliveryMethod() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Delivery Method",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _method("Kitchen Rider", 0),
              const SizedBox(width: 8),
              _method("Third Party", 1),
              const SizedBox(width: 8),
              _method("Self Pickup", 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _method(String title, int index) {
    final selected = deliveryMethod == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => deliveryMethod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.background : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
            color: selected
                ? AppColors.background.withOpacity(0.1)
                : Colors.white,
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.background : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 💳 PAYMENT
  Widget _paymentMethod() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payment", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _paymentTile("Online", "GPay, Cards", 0),
          const SizedBox(height: 8),
          _paymentTile("Cash on Delivery", "Pay on arrival", 1),
        ],
      ),
    );
  }

  Widget _paymentTile(String title, String subtitle, int index) {
    final selected = paymentMethod == index;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => paymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.background : Colors.grey.shade300,
          ),
          color: selected
              ? AppColors.background.withOpacity(0.08)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.payment,
              color: selected ? AppColors.background : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: AppColors.background,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 CARD DECORATION
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  String _fullAddress(Address addr) {
    final parts = <String>[addr.addressLine ?? "", addr.societyName ?? ""];
    return parts.where((e) => e.trim().isNotEmpty).join(", ");
  }
}
