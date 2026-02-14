import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:padoshi_kitchen/Modules/Auth/Model/Addressmodel.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Model.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/ordertrackingmodel.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/orderhistory_model.dart'
    as history;
import 'package:padoshi_kitchen/Utils/Sharedpre.dart';
import 'package:padoshi_kitchen/Utils/api_endpoints.dart';
import 'package:padoshi_kitchen/Utils/socket_service.dart';

class OrdertrackinController extends GetxController {
  final isLoading = false.obs;
  final Rx<Order?> order = Rx<Order?>(null);
  final RxList<Order> orders = <Order>[].obs;
  final RxString errorMessage = "".obs;
  final RxList<history.Order> historyOrders = <history.Order>[].obs;
  final isHistoryLoading = false.obs;
  final RxString historyError = "".obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final isNotificationLoading = false.obs;
  final RxString notificationError = "".obs;
  final RxList<Kitchen> nearbyKitchens = <Kitchen>[].obs;
  final RxList<Kitchen> searchedKitchens = <Kitchen>[].obs;
  final isKitchenSearchLoading = false.obs;
  final RxString kitchenSearchError = "".obs;

  static const List<String> statusSteps = [
    "PLACED",
    "ACCEPTED",
    "PREPARING",
    "READY",
    "PICKED_UP",
    "DELIVERED",
    "COMPLETED",
    "CANCELLED",
  ];

  bool _listenersBound = false;
  String? _listeningOrderId;

  @override
  void onClose() {
    _unbindSocketListeners();
    super.onClose();
  }

  Future<void> fetchOrderTracking(String orderId) async {
    if (orderId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "Session expired. Please login again.";
        return;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.Ordertacking));

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final OrdersResponse parsed = OrdersResponse.fromJson(decoded);
        final list = parsed.orders ?? <Order>[];

        orders.assignAll(list);

        Order? match;
        for (final item in list) {
          if (item.id == orderId) {
            match = item;
            break;
          }
        }

        order.value = match;
        if (match == null) {
          final historyOrder = await _fetchHistoryOrderById(orderId);
          if (historyOrder != null) {
            try {
              order.value = Order.fromJson(historyOrder.toJson());
            } catch (_) {
              order.value = null;
            }
          }
        }
        if (order.value == null) {
          errorMessage.value = "Order not found";
        }
        _listeningOrderId = orderId;
        _ensureSocketConnected(token);
        _bindSocketListeners();
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data["message"] ?? "Failed to load order";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderHistory() async {
    try {
      isHistoryLoading.value = true;
      historyError.value = "";

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        historyError.value = "Session expired. Please login again.";
        return;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.OrderHistory));

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final parsed = history.OrdershistoryResponse.fromJson(decoded);
        historyOrders.assignAll(parsed.orders ?? <history.Order>[]);
      } else {
        final data = jsonDecode(response.body);
        historyError.value = data["message"] ?? "Failed to load order history";
      }
    } catch (e) {
      historyError.value = "Something went wrong";
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> fetchNotifications() async {
    try {
      isNotificationLoading.value = true;
      notificationError.value = "";

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        notificationError.value = "Session expired. Please login again.";
        return;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.GetNotification));

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final parsed = NotificationsResponse.fromJson(decoded);
        notifications.assignAll(parsed.notifications ?? <NotificationItem>[]);
      } else {
        final data = jsonDecode(response.body);
        notificationError.value =
            data["message"] ?? "Failed to load notifications";
      }
    } catch (_) {
      notificationError.value = "Something went wrong";
    } finally {
      isNotificationLoading.value = false;
    }
  }

  Future<void> fetchNearbyKitchensByLocation({
    required double lat,
    required double lng,
    int radius = 3000,
  }) async {
    try {
      isKitchenSearchLoading.value = true;
      kitchenSearchError.value = "";

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        kitchenSearchError.value = "Session expired. Please login again.";
        return;
      }

      final url = Uri.parse(
        "${ApiEndpoint.baseUrl}/kitchens?lat=$lat&lng=$lng&radius=$radius",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final kitchens = _extractKitchenList(decoded);
        nearbyKitchens.assignAll(kitchens);
        searchedKitchens.assignAll(kitchens);
      } else {
        try {
          final data = jsonDecode(response.body);
          kitchenSearchError.value =
              data["message"] ?? "Failed to load nearby kitchens";
        } catch (_) {
          kitchenSearchError.value = "Failed to load nearby kitchens";
        }
      }
    } catch (_) {
      kitchenSearchError.value = "Something went wrong";
    } finally {
      isKitchenSearchLoading.value = false;
    }
  }

  Future<void> searchKitchensBySociety(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      kitchenSearchError.value = "";
      searchedKitchens.assignAll(nearbyKitchens);
      return;
    }

    try {
      isKitchenSearchLoading.value = true;
      kitchenSearchError.value = "";

      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        kitchenSearchError.value = "Session expired. Please login again.";
        return;
      }

      final base = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.Searchsociaties));
      final uri = base.replace(
        queryParameters: {
          ...base.queryParameters,
          "q": trimmed,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final kitchens = _extractKitchenList(decoded);
        searchedKitchens.assignAll(kitchens);
      } else {
        try {
          final data = jsonDecode(response.body);
          kitchenSearchError.value =
              data["message"] ?? "Failed to search kitchens";
        } catch (_) {
          kitchenSearchError.value = "Failed to search kitchens";
        }
      }
    } catch (_) {
      kitchenSearchError.value = "Something went wrong";
    } finally {
      isKitchenSearchLoading.value = false;
    }
  }

  Future<bool> markNotificationsRead({bool markAllLocal = true}) async {
    try {
      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        notificationError.value = "Session expired. Please login again.";
        return false;
      }

      final url = Uri.parse(
        ApiEndpoint.getUrl(ApiEndpoint.MarkNotificationRead),
      );
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!markAllLocal) return true;
        for (final n in notifications) {
          n.isRead = true;
        }
        notifications.refresh();
        return true;
      }

      try {
        final data = jsonDecode(response.body);
        notificationError.value =
            data["message"] ?? "Failed to mark notifications as read";
      } catch (_) {
        notificationError.value = "Failed to mark notifications as read";
      }
      return false;
    } catch (_) {
      notificationError.value = "Something went wrong";
      return false;
    }
  }

  Future<void> markSingleNotificationRead(NotificationItem item) async {
    if (item.isRead == true) return;

    item.isRead = true;
    notifications.refresh();

    final ok = await markNotificationReadById(item.id, markLocal: false);
    if (!ok) {
      item.isRead = false;
      notifications.refresh();
    }
  }

  Future<bool> markNotificationReadById(
    String? notificationId, {
    bool markLocal = true,
  }) async {
    if (notificationId == null || notificationId.isEmpty) {
      notificationError.value = "Invalid notification id";
      return false;
    }

    try {
      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        notificationError.value = "Session expired. Please login again.";
        return false;
      }

      final url = Uri.parse(
        "${ApiEndpoint.baseUrl}/notification/read/$notificationId",
      );

      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (markLocal) {
          final index = notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            notifications[index].isRead = true;
            notifications.refresh();
          }
        }
        return true;
      }

      try {
        final data = jsonDecode(response.body);
        notificationError.value =
            data["message"] ?? "Failed to mark notification as read";
      } catch (_) {
        notificationError.value = "Failed to mark notification as read";
      }
      return false;
    } catch (_) {
      notificationError.value = "Something went wrong";
      return false;
    }
  }

  Future<history.Order?> _fetchHistoryOrderById(String orderId) async {
    try {
      final token = TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.OrderHistory));
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final parsed = history.OrdershistoryResponse.fromJson(decoded);
        final list = parsed.orders ?? <history.Order>[];
        for (final o in list) {
          if (o.id == orderId) return o;
        }
        return null;
      }
    } catch (_) {}
    return null;
  }

  void _ensureSocketConnected(String token) {
    final socket = SocketService.socket;
    if (socket == null) {
      SocketService.connect(token);
    }
  }

  void _bindSocketListeners() {
    final socket = SocketService.socket;
    if (socket == null || _listenersBound) return;

    socket.off("orderStatusUpdated");
    socket.off("order_status");
    socket.off("order-status");
    socket.off("order_update");
    socket.off("orderUpdate");
    socket.off("order:update");

    // Listen to multiple possible event names for order status updates.
    socket.on("orderStatusUpdated", _handleSocketUpdate);
    socket.on("order_status", _handleSocketUpdate);
    socket.on("order-status", _handleSocketUpdate);
    socket.on("order_update", _handleSocketUpdate);
    socket.on("orderUpdate", _handleSocketUpdate);
    socket.on("order:update", _handleSocketUpdate);

    _listenersBound = true;
  }

  void _unbindSocketListeners() {
    final socket = SocketService.socket;
    if (socket == null) return;

    socket.off("orderStatusUpdated");
    socket.off("order_status");
    socket.off("order-status");
    socket.off("order_update");
    socket.off("orderUpdate");
    socket.off("order:update");

    _listenersBound = false;
  }

  void _handleSocketUpdate(dynamic data) {
    debugPrint("Socket update payload: $data");
    final payload = _normalizeSocketPayload(data);
    if (payload == null) return;

    final Map<String, dynamic> body = payload["order"] is Map<String, dynamic>
        ? (payload["order"] as Map<String, dynamic>)
        : payload;

    final incomingOrderId = (body["orderId"] ?? body["_id"] ?? body["id"])
        ?.toString();
    final statusValue = (body["status"] ?? body["orderStatus"] ?? body["state"])
        ?.toString();

    if (statusValue == null || statusValue.isEmpty) return;

    if (_listeningOrderId != null &&
        incomingOrderId != null &&
        incomingOrderId != _listeningOrderId) {
      return;
    }

    final normalized = statusValue.toUpperCase().trim();
    if (!statusSteps.contains(normalized)) return;

    final current = order.value;
    if (current != null) {
      if (body.containsKey("_id") || body.containsKey("items")) {
        try {
          order.value = Order.fromJson(body);
        } catch (_) {
          current.status = normalized;
          order.refresh();
        }
      } else {
        current.status = normalized;
        order.refresh();
      }
    }

    if (incomingOrderId != null) {
      final idx = orders.indexWhere((o) => o.id == incomingOrderId);
      if (idx >= 0) {
        if (body.containsKey("_id") || body.containsKey("items")) {
          try {
            orders[idx] = Order.fromJson(body);
          } catch (_) {
            orders[idx].status = normalized;
          }
        } else {
          orders[idx].status = normalized;
        }
        orders.refresh();
      }
    }
  }

  Map<String, dynamic>? _normalizeSocketPayload(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry("$key", value));
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry("$key", value));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  List<Kitchen> _extractKitchenList(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final kitchensRaw = decoded["kitchens"];
      if (kitchensRaw is List) {
        return kitchensRaw
            .whereType<Map>()
            .map((e) => Kitchen.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return <Kitchen>[];
  }
}
