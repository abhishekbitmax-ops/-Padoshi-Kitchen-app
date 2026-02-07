class OrdersResponse {
  bool? success;
  List<Order>? orders;

  OrdersResponse({this.success, this.orders});

  OrdersResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    orders = json['orders'] != null
        ? List<Order>.from(
            json['orders'].map((x) => Order.fromJson(x)),
          )
        : null;
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'orders': orders?.map((x) => x.toJson()).toList(),
      };
}

class Order {
  UserDetails? userDetails;
  Pricing? pricing;
  Delivery? delivery;
  Payment? payment;
  String? id;
  String? userId;
  String? kitchenId;
  List<OrderItem>? items;
  String? status;
  bool? isVisibleToKitchen;
  String? createdAt;
  String? updatedAt;
  int? v;

  Order({
    this.userDetails,
    this.pricing,
    this.delivery,
    this.payment,
    this.id,
    this.userId,
    this.kitchenId,
    this.items,
    this.status,
    this.isVisibleToKitchen,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Order.fromJson(Map<String, dynamic> json) {
    userDetails = json['userDetails'] != null
        ? UserDetails.fromJson(json['userDetails'])
        : null;
    pricing =
        json['pricing'] != null ? Pricing.fromJson(json['pricing']) : null;
    delivery =
        json['delivery'] != null ? Delivery.fromJson(json['delivery']) : null;
    payment =
        json['payment'] != null ? Payment.fromJson(json['payment']) : null;
    id = json['_id'];
    userId = json['userId'];
    kitchenId = json['kitchenId'];
    items = json['items'] != null
        ? List<OrderItem>.from(
            json['items'].map((x) => OrderItem.fromJson(x)),
          )
        : null;
    status = json['status'];
    isVisibleToKitchen = json['isVisibleToKitchen'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() => {
        'userDetails': userDetails?.toJson(),
        'pricing': pricing?.toJson(),
        'delivery': delivery?.toJson(),
        'payment': payment?.toJson(),
        '_id': id,
        'userId': userId,
        'kitchenId': kitchenId,
        'items': items?.map((x) => x.toJson()).toList(),
        'status': status,
        'isVisibleToKitchen': isVisibleToKitchen,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': v,
      };
}

class UserDetails {
  String? userId;
  String? email;

  UserDetails({this.userId, this.email});

  UserDetails.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
      };
}

class Pricing {
  num? itemTotal;
  num? gstPercent;
  num? gstAmount;
  num? platformFee;
  num? grandTotalWithoutDelivery;
  num? finalGrandTotal;

  Pricing({
    this.itemTotal,
    this.gstPercent,
    this.gstAmount,
    this.platformFee,
    this.grandTotalWithoutDelivery,
    this.finalGrandTotal,
  });

  Pricing.fromJson(Map<String, dynamic> json) {
    itemTotal = json['itemTotal'];
    gstPercent = json['gstPercent'];
    gstAmount = json['gstAmount'];
    platformFee = json['platformFee'];
    grandTotalWithoutDelivery = json['grandTotalWithoutDelivery'];
    finalGrandTotal = json['finalGrandTotal'];
  }

  Map<String, dynamic> toJson() => {
        'itemTotal': itemTotal,
        'gstPercent': gstPercent,
        'gstAmount': gstAmount,
        'platformFee': platformFee,
        'grandTotalWithoutDelivery': grandTotalWithoutDelivery,
        'finalGrandTotal': finalGrandTotal,
      };
}

class Delivery {
  DeliveryPricing? pricing;
  Address? address;
  String? mode;
  String? settlementOwner;
  String? status;
  List<dynamic>? webhookEvents;

  Delivery({
    this.pricing,
    this.address,
    this.mode,
    this.settlementOwner,
    this.status,
    this.webhookEvents,
  });

  Delivery.fromJson(Map<String, dynamic> json) {
    pricing = json['pricing'] != null
        ? DeliveryPricing.fromJson(json['pricing'])
        : null;
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    mode = json['mode'];
    settlementOwner = json['settlementOwner'];
    status = json['status'];
    webhookEvents = json['webhookEvents'];
  }

  Map<String, dynamic> toJson() => {
        'pricing': pricing?.toJson(),
        'address': address?.toJson(),
        'mode': mode,
        'settlementOwner': settlementOwner,
        'status': status,
        'webhookEvents': webhookEvents,
      };
}

class DeliveryPricing {
  num? charge;
  String? currency;
  String? chargedBy;

  DeliveryPricing({this.charge, this.currency, this.chargedBy});

  DeliveryPricing.fromJson(Map<String, dynamic> json) {
    charge = json['charge'];
    currency = json['currency'];
    chargedBy = json['chargedBy'];
  }

  Map<String, dynamic> toJson() => {
        'charge': charge,
        'currency': currency,
        'chargedBy': chargedBy,
      };
}

class Address {
  GeoLocation? geoLocation;
  String? addressLine;
  String? societyName;

  Address({this.geoLocation, this.addressLine, this.societyName});

  Address.fromJson(Map<String, dynamic> json) {
    geoLocation = json['geoLocation'] != null
        ? GeoLocation.fromJson(json['geoLocation'])
        : null;
    addressLine = json['addressLine'];
    societyName = json['societyName'];
  }

  Map<String, dynamic> toJson() => {
        'geoLocation': geoLocation?.toJson(),
        'addressLine': addressLine,
        'societyName': societyName,
      };
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

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

class Payment {
  String? owner;
  String? method;
  String? status;

  Payment({this.owner, this.method, this.status});

  Payment.fromJson(Map<String, dynamic> json) {
    owner = json['owner'];
    method = json['method'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'method': method,
        'status': status,
      };
}

class OrderItem {
  Variant? variant;
  Customization? customization;
  String? menuItemId;
  String? name;
  List<Addon>? addons;
  int? quantity;
  num? itemTotal;
  String? id;

  OrderItem({
    this.variant,
    this.customization,
    this.menuItemId,
    this.name,
    this.addons,
    this.quantity,
    this.itemTotal,
    this.id,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    variant =
        json['variant'] != null ? Variant.fromJson(json['variant']) : null;
    customization = json['customization'] != null
        ? Customization.fromJson(json['customization'])
        : null;
    menuItemId = json['menuItemId'];
    name = json['name'];
    addons = json['addons'] != null
        ? List<Addon>.from(json['addons'].map((x) => Addon.fromJson(x)))
        : null;
    quantity = json['quantity'];
    itemTotal = json['itemTotal'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() => {
        'variant': variant?.toJson(),
        'customization': customization?.toJson(),
        'menuItemId': menuItemId,
        'name': name,
        'addons': addons?.map((x) => x.toJson()).toList(),
        'quantity': quantity,
        'itemTotal': itemTotal,
        '_id': id,
      };
}

class Variant {
  String? label;
  num? price;

  Variant({this.label, this.price});

  Variant.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'price': price,
      };
}

class Customization {
  String? spiceLevel;
  bool? isJain;
  String? notes;

  Customization({this.spiceLevel, this.isJain, this.notes});

  Customization.fromJson(Map<String, dynamic> json) {
    spiceLevel = json['spiceLevel'];
    isJain = json['isJain'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() => {
        'spiceLevel': spiceLevel,
        'isJain': isJain,
        'notes': notes,
      };
}

class Addon {
  String? name;
  num? price;
  String? id;

  Addon({this.name, this.price, this.id});

  Addon.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        '_id': id,
      };
}



//
