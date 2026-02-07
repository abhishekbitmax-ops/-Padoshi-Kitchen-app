import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/OrdertrackinController.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/ordertrackingmodel.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrdertrackinController ctrl = Get.put(OrdertrackinController());

  static const List<String> steps = [
    "PLACED",
    "ACCEPTED",
    "PREPARING",
    "READY",
    "PICKED_UP",
    "DELIVERED",
  ];

  static const List<String> labels = [
    "Order Placed",
    "Accepted",
    "Preparing",
    "Ready",
    "Picked Up",
    "Delivered",
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ctrl.fetchOrderTracking(widget.orderId);
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<OrdertrackinController>()) {
      Get.delete<OrdertrackinController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Track Order",
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
              color: AppColors.primary,
              size: 26,
            ),
            onPressed: () {
              Get.offAll(() => const RestaurantBottomNav(initialIndex: 0));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.background,
        onRefresh: () => ctrl.fetchOrderTracking(widget.orderId),
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.background),
            );
          }

          final Order? order = ctrl.order.value;
          if (order == null) {
            final msg = ctrl.errorMessage.value.isNotEmpty
                ? ctrl.errorMessage.value
                : "Fetching order details...";
            return Center(
              child: Text(msg, style: const TextStyle(color: Colors.black54)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _orderSummary(order),
              const SizedBox(height: 16),
              _itemsList(order),
              const SizedBox(height: 16),
              _deliveryInfo(order),
              const SizedBox(height: 16),
              _paymentInfo(order),
              const SizedBox(height: 16),
              _timeline(order.status),
              const SizedBox(height: 16),
              _lastUpdated(order.updatedAt ?? order.createdAt),
            ],
          );
        }),
      ),
    );
  }

  Widget _orderSummary(Order order) {
    final total =
        order.pricing?.finalGrandTotal ??
        order.pricing?.grandTotalWithoutDelivery ??
        order.pricing?.itemTotal ??
        0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order ID: ${order.id ?? "--"}",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rs $total",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              _statusChip(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemsList(Order order) {
    final items = order.items ?? [];
    if (items.isEmpty) return const SizedBox();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Items",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name ?? "Item",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  Text(
                    "x${item.quantity ?? 1}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Rs ${item.itemTotal ?? 0}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryInfo(Order order) {
    final address = order.delivery?.address;
    if (address == null) return const SizedBox();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              address.addressLine,
              address.societyName,
            ].where((e) => e != null && e!.isNotEmpty).join(", "),
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _paymentInfo(Order order) {
    final method = order.payment?.method ?? "COD";
    final status = order.payment?.status ?? "--";
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _infoRow("Method", method),
          _infoRow("Status", status),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statusChip(String? status) {
    final normalized = status?.toUpperCase().trim() ?? "--";
    final isCancelled = normalized == "CANCELLED";
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: (isCancelled ? Colors.red : AppColors.primary)
              .withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          normalized,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isCancelled ? Colors.red : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _timeline(String? status) {
    final currentStatus = status?.toUpperCase().trim() ?? "";
    int activeIndex = steps.indexOf(currentStatus);
    if (activeIndex < 0) activeIndex = 0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          "Order Timeline",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(steps.length, (i) {
              final isCompleted = i < activeIndex;
              final isActive = i == activeIndex;
              final activeColor = Colors.green;
              final dotColor = (isCompleted || isActive)
                  ? activeColor
                  : Colors.grey.shade400;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i != steps.length - 1)
                          Container(
                            width: 2,
                            height: 28,
                            color: isCompleted
                                ? activeColor
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        labels[i],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: (isCompleted || isActive)
                              ? Colors.black87
                              : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _lastUpdated(String? timeValue) {
    String time = "--";

    if (timeValue != null && timeValue.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(timeValue).toLocal();
        time = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
      } catch (_) {
        time = timeValue;
      }
    }

    return Center(
      child: Text(
        "Last updated: $time\nPull down to refresh",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
