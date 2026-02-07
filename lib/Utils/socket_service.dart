import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Utils/global_notification_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? _socket;
  static bool _orderNotificationsBound = false;

  static IO.Socket? get socket => _socket;

  static IO.Socket? connect(String token) {
    if (_socket != null) return _socket;

    const url = "https://padoshi-kitchen-b.onrender.com";

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(["websocket", "polling"])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .setAuth({"token": token})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint("User socket connected: ${_socket?.id}");
    });

    _socket!.onDisconnect((reason) {
      debugPrint("User socket disconnected: $reason");
    });

    _socket!.onConnectError((err) {
      debugPrint("Socket connect error: $err");
    });

    _socket!.connect();
    return _socket;
  }

  static void bindOrderNotifications() {
    final socket = _socket;
    if (socket == null || _orderNotificationsBound) return;

    socket.off("order:update");
    socket.on("order:update", (data) {
      final payload = _normalizePayload(data);
      if (payload == null) return;

      final status = payload["status"]?.toString().toUpperCase().trim();
      if (status == null || status.isEmpty) return;

      switch (status) {
        case "PLACED":
          GlobalNotificationService.show(
            title: "Order Placed",
            message: "Order placed successfully, please check your orders",
            bgColor: Colors.green,
          );
          break;
        case "ACCEPTED":
          GlobalNotificationService.show(
            title: "Order Accepted",
            message: "Your order has been accepted!",
            bgColor: Colors.green,
          );
          break;
        case "PREPARING":
          GlobalNotificationService.show(
            title: "Order Preparing",
            message: "Your food is preparing",
            bgColor: Colors.orange,
          );
          break;
        case "READY":
          GlobalNotificationService.show(
            title: "Order Ready",
            message: "Order is ready for pickup/delivery!",
            bgColor: Colors.green,
          );
          break;
        case "PICKED_UP":
          GlobalNotificationService.show(
            title: "Order Picked Up",
            message: "Order is picked up!",
            bgColor: Colors.green,
          );
          break;
        case "COMPLETED":
          GlobalNotificationService.show(
            title: "Order Completed",
            message: "Order completed. Enjoy your meal!",
            bgColor: Colors.green,
          );
          break;
        default:
          break;
      }
    });

    _orderNotificationsBound = true;
  }

  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
  }

  static Map<String, dynamic>? _normalizePayload(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry("$key", value));
    }
    return null;
  }
}
