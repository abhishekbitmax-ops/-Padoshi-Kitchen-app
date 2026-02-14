class AddressResponse {
  bool? success;
  List<Address>? addresses;

  AddressResponse({this.success, this.addresses});

  AddressResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['addresses'] != null) {
      addresses = json['addresses']
          .map<Address>((v) => Address.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'addresses': addresses?.map((v) => v.toJson()).toList(),
    };
  }
}

class Address {
  GeoLocation? geoLocation;
  String? label;
  String? addressLine;
  String? societyName;
  bool? isDefault;
  String? id;

  Address({
    this.geoLocation,
    this.label,
    this.addressLine,
    this.societyName,
    this.isDefault,
    this.id,
  });

  Address.fromJson(Map<String, dynamic> json) {
    geoLocation = json['geoLocation'] != null
        ? GeoLocation.fromJson(json['geoLocation'])
        : null;
    label = json['label'];
    addressLine = json['addressLine'];
    societyName = json['societyName'];
    isDefault = json['isDefault'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'geoLocation': geoLocation?.toJson(),
      'label': label,
      'addressLine': addressLine,
      'societyName': societyName,
      'isDefault': isDefault,
      '_id': id,
    };
  }
}

class GeoLocation {
  String? type;
  List<double>? coordinates;

  GeoLocation({this.type, this.coordinates});

  GeoLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'] != null
        ? List<double>.from(
            json['coordinates'].map((e) => (e as num).toDouble()),
          )
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}


//  notification  model class -----

class NotificationsResponse {
  bool? success;
  List<NotificationItem>? notifications;

  NotificationsResponse({this.success, this.notifications});

  NotificationsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    notifications = json['notifications'] != null
        ? List<NotificationItem>.from(
            json['notifications'].map((x) => NotificationItem.fromJson(x)),
          )
        : null;
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'notifications': notifications?.map((x) => x.toJson()).toList(),
      };
}

class NotificationItem {
  String? id;
  String? userId;
  String? kitchenId;
  String? role;
  String? type;
  String? title;
  String? message;
  NotificationData? data;
  bool? isRead;
  DeliveredStatus? delivered;
  String? createdAt;
  String? updatedAt;
  int? v;

  NotificationItem({
    this.id,
    this.userId,
    this.kitchenId,
    this.role,
    this.type,
    this.title,
    this.message,
    this.data,
    this.isRead,
    this.delivered,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  NotificationItem.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['userId'];
    kitchenId = json['kitchenId'];
    role = json['role'];
    type = json['type'];
    title = json['title'];
    message = json['message'];
    data =
        json['data'] != null ? NotificationData.fromJson(json['data']) : null;
    isRead = json['isRead'];
    delivered = json['delivered'] != null
        ? DeliveredStatus.fromJson(json['delivered'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'kitchenId': kitchenId,
        'role': role,
        'type': type,
        'title': title,
        'message': message,
        'data': data?.toJson(),
        'isRead': isRead,
        'delivered': delivered?.toJson(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
      };
}

class NotificationData {
  String? orderId;

  NotificationData({this.orderId});

  NotificationData.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
      };
}

class DeliveredStatus {
  bool? socket;
  bool? push;
  bool? email;
  bool? sms;

  DeliveredStatus({
    this.socket,
    this.push,
    this.email,
    this.sms,
  });

  DeliveredStatus.fromJson(Map<String, dynamic> json) {
    socket = json['socket'];
    push = json['push'];
    email = json['email'];
    sms = json['sms'];
  }

  Map<String, dynamic> toJson() => {
        'socket': socket,
        'push': push,
        'email': email,
        'sms': sms,
      };
}


