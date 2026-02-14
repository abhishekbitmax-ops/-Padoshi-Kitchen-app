import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/OrdertrackinController.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Addressmodel.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final OrdertrackinController ctrl = Get.put(OrdertrackinController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ctrl.fetchNotifications();
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
          "Notifications",
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ctrl.markNotificationsRead();
            },
            child: Text(
              "Mark all read",
              style: GoogleFonts.poppins(
                color: AppColors.background,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.background,
        onRefresh: () => ctrl.fetchNotifications(),
        child: Obx(() {
          if (ctrl.isNotificationLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.background),
            );
          }

          if (ctrl.notificationError.value.isNotEmpty) {
            return ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(
                      ctrl.notificationError.value,
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  ),
                ),
              ],
            );
          }

          final list = ctrl.notifications;
          if (list.isEmpty) {
            return ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(
                      "No notifications yet",
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final NotificationItem item = list[index];
              return _notificationCard(item);
            },
          );
        }),
      ),
    );
  }

  Widget _notificationCard(NotificationItem item) {
    final isRead = item.isRead == true;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await ctrl.markSingleNotificationRead(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? Colors.grey.withOpacity(0.25)
                : AppColors.background.withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead ? Colors.grey : AppColors.background,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? "Notification",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isRead ? Colors.black54 : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isRead ? Colors.black45 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(item.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isRead ? Colors.black38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "--";
    try {
      return DateFormat(
        "dd MMM yyyy, hh:mm a",
      ).format(DateTime.parse(rawDate).toLocal());
    } catch (_) {
      return rawDate;
    }
  }
}
