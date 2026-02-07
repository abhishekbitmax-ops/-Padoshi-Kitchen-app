import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/OrdertrackinController.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/orderhistory_model.dart'
    as history;
import 'package:padoshi_kitchen/Modules/Auth/view/OrderTackingScreen.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrdertrackinController ctrl = Get.put(OrdertrackinController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Order History",
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isHistoryLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.background),
          );
        }

        if (ctrl.historyError.value.isNotEmpty) {
          return Center(
            child: Text(
              ctrl.historyError.value,
              style: const TextStyle(color: Colors.black54),
            ),
          );
        }

        final orders = ctrl.historyOrders;
        if (orders.isEmpty) {
          return const Center(
            child: Text(
              "No order history found",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final history.Order order = orders[index];
            return _orderCard(order);
          },
        );
      }),
    );
  }

  Widget _orderCard(history.Order order) {
    final total =
        order.pricing?.finalGrandTotal ??
        order.pricing?.grandTotalWithoutDelivery ??
        order.pricing?.itemTotal ??
        0;

    final itemCount = order.items?.length ?? 0;
    final status = order.status?.toUpperCase() ?? "--";
    final payment = order.payment?.method?.toUpperCase() ?? "COD";
    final deliveryMode = order.delivery?.mode?.toUpperCase() ?? "--";

    String dateText = "--";
    final rawDate = order.createdAt ?? order.updatedAt;
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawDate).toLocal();
        dateText = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (_) {
        dateText = rawDate;
      }
    }

    return InkWell(
      onTap: () {
        final orderId = order.id ?? "";
        if (orderId.isEmpty) {
          Get.snackbar("Tracking", "Order ID not found");
          return;
        }
        Get.to(() => OrderTrackingScreen(orderId: orderId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF1E8), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Order ID: ${order.id ?? '--'}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _statusChip(status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rs $total",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$itemCount item${itemCount == 1 ? '' : 's'}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _infoPill("PAY", payment),
                  const SizedBox(width: 8),
                  _infoPill("MODE", deliveryMode),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                dateText,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        "$label: $value",
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isCancelled = status == "CANCELLED";
    final color = isCancelled ? Colors.red : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
