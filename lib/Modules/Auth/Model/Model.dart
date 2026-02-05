// --- Get fetch current location kitchen model ---

class KitchenResponse {
  final bool? success;
  final int? count;
  final List<Kitchen>? kitchens;

  KitchenResponse({this.success, this.count, this.kitchens});

  factory KitchenResponse.fromJson(Map<String, dynamic> json) {
    return KitchenResponse(
      success: json['success'],
      count: json['count'],
      kitchens: (json['kitchens'] as List?)
          ?.map((e) => Kitchen.fromJson(e))
          .toList(),
    );
  }
}

class Kitchen {
  final String? id;
  final RestaurantInfo? restaurantInfo;
  final LocationInfo? location;
  final Operations? operations;
  final DeliveryCapabilities? deliveryCapabilities;
  final DeliveryPricing? deliveryPricing;
  final Serviceability? serviceability;
  final num? distanceKm;

  Kitchen({
    this.id,
    this.restaurantInfo,
    this.location,
    this.operations,
    this.deliveryCapabilities,
    this.deliveryPricing,
    this.serviceability,
    this.distanceKm,
  });

  factory Kitchen.fromJson(Map<String, dynamic> json) {
    return Kitchen(
      id: json['_id'], // ✅ CRITICAL
      restaurantInfo: json['restaurantInfo'] != null
          ? RestaurantInfo.fromJson(json['restaurantInfo'])
          : null,
      location: json['location'] != null
          ? LocationInfo.fromJson(json['location'])
          : null,
      operations: json['operations'] != null
          ? Operations.fromJson(json['operations'])
          : null,
      deliveryCapabilities: json['deliveryCapabilities'] != null
          ? DeliveryCapabilities.fromJson(json['deliveryCapabilities'])
          : null,
      deliveryPricing: json['deliveryPricing'] != null
          ? DeliveryPricing.fromJson(json['deliveryPricing'])
          : null,
      serviceability: json['serviceability'] != null
          ? Serviceability.fromJson(json['serviceability'])
          : null,
      distanceKm: json['distanceKm'],
    );
  }
}

class RestaurantInfo {
  final String? name;
  final String? description;

  RestaurantInfo({this.name, this.description});

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(name: json['name'], description: json['description']);
  }
}

class LocationInfo {
  final String? societyName;

  LocationInfo({this.societyName});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(societyName: json['societyName']);
  }
}

class Operations {
  final String? serviceType;
  final List<String>? cuisines;
  final OpeningHours? openingHours;
  final List<dynamic>? weeklyOff;

  Operations({
    this.serviceType,
    this.cuisines,
    this.openingHours,
    this.weeklyOff,
  });

  factory Operations.fromJson(Map<String, dynamic> json) {
    return Operations(
      serviceType: json['serviceType'],
      cuisines: (json['cuisines'] as List?)?.cast<String>(),
      openingHours: json['openingHours'] != null
          ? OpeningHours.fromJson(json['openingHours'])
          : null,
      weeklyOff: json['weeklyOff'],
    );
  }
}

class OpeningHours {
  final String? open;
  final String? close;

  OpeningHours({this.open, this.close});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(open: json['open'], close: json['close']);
  }
}

class DeliveryCapabilities {
  final bool? kitchenRider;
  final bool? partner;
  final bool? selfPickup;
  final bool? thirdParty;

  DeliveryCapabilities({
    this.kitchenRider,
    this.partner,
    this.selfPickup,
    this.thirdParty,
  });

  factory DeliveryCapabilities.fromJson(Map<String, dynamic> json) {
    return DeliveryCapabilities(
      kitchenRider: json['kitchenRider'] ?? json['KITCHEN_RIDER'],
      partner: json['partner'] ?? json['PARTNER'],
      selfPickup: json['selfPickup'] ?? json['SELF_PICKUP'],
      thirdParty: json['thirdParty'] ?? json['THIRD_PARTY'],
    );
  }
}

class DeliveryPricing {
  final num? baseFee;
  final num? partnerRatePerKm;
  final num? perKmCharge;

  DeliveryPricing({this.baseFee, this.partnerRatePerKm, this.perKmCharge});

  factory DeliveryPricing.fromJson(Map<String, dynamic> json) {
    return DeliveryPricing(
      baseFee: json['baseFee'],
      partnerRatePerKm: json['partnerRatePerKm'],
      perKmCharge: json['perKmCharge'],
    );
  }
}

class Serviceability {
  final bool? allowsPickup;
  final num? maxDeliveryRadiusKm;

  Serviceability({this.allowsPickup, this.maxDeliveryRadiusKm});

  factory Serviceability.fromJson(Map<String, dynamic> json) {
    return Serviceability(
      allowsPickup: json['allowsPickup'],
      maxDeliveryRadiusKm: json['maxDeliveryRadiusKm'],
    );
  }
}

// menu model can be added here if needed

class MenuResponse {
  final bool? success;
  final KitchenInfo? kitchen;
  final List<Category>? categories;
  final List<Item>? items;

  MenuResponse({this.success, this.kitchen, this.categories, this.items});

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      success: json['success'],
      kitchen: json['kitchen'] != null
          ? KitchenInfo.fromJson(json['kitchen'])
          : null,
      categories: (json['categories'] as List?)
          ?.map((e) => Category.fromJson(e))
          .toList(),
      items: (json['items'] as List?)?.map((e) => Item.fromJson(e)).toList(),
    );
  }
}

class KitchenInfo {
  final String? id;
  final String? name;
  final bool? isOnline;

  KitchenInfo({this.id, this.name, this.isOnline});

  factory KitchenInfo.fromJson(Map<String, dynamic> json) {
    return KitchenInfo(
      id: json['_id'],
      name: json['restaurantInfo']?['name'],
      isOnline: json['isOnline'],
    );
  }
}

class Category {
  final ImageData? image;
  final String? id;
  final String? kitchenId;
  final String? name;
  final String? description;
  final int? order;
  final bool? isActive;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;

  Category({
    this.image,
    this.id,
    this.kitchenId,
    this.name,
    this.description,
    this.order,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      kitchenId: json['kitchenId'],
      name: json['name'],
      description: json['description'],
      order: json['order'],
      isActive: json['isActive'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
    );
  }
}

class ImageData {
  final String? publicId;
  final String? url;

  ImageData({this.publicId, this.url});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(publicId: json['public_id'], url: json['url']);
  }
}

class Item {
  final Customization? customization;
  final String? id;
  final String? name;
  final String? description;
  final String? category;
  final String? foodType;
  final ImageData? image; // ✅ ADD THIS
  final List<Variant>? variants;
  final List<Addon>? addons;

  Item({
    this.customization,
    this.id,
    this.name,
    this.description,
    this.category,
    this.foodType,
    this.image,
    this.variants,
    this.addons,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      foodType: json['foodType'],
      image:
          json['image'] !=
              null // ✅ MAP IMAGE
          ? ImageData.fromJson(json['image'])
          : null,
      customization: json['customization'] != null
          ? Customization.fromJson(json['customization'])
          : null,
      variants: (json['variants'] as List?)
          ?.map((e) => Variant.fromJson(e))
          .toList(),
      addons: (json['addons'] as List?)?.map((e) => Addon.fromJson(e)).toList(),
    );
  }
}

class Customization {
  final bool? spiceLevel;
  final bool? jainAvailable;
  final bool? notesAllowed;

  Customization({this.spiceLevel, this.jainAvailable, this.notesAllowed});

  factory Customization.fromJson(Map<String, dynamic> json) {
    return Customization(
      spiceLevel: json['spiceLevel'],
      jainAvailable: json['jainAvailable'],
      notesAllowed: json['notesAllowed'],
    );
  }
}

class Variant {
  final String? label;
  final int? price;
  final String? servingSize;
  final bool? isDefault;
  final bool? isAvailable;
  final String? id;

  Variant({
    this.label,
    this.price,
    this.servingSize,
    this.isDefault,
    this.isAvailable,
    this.id,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      label: json['label'],
      price: json['price'],
      servingSize: json['servingSize'],
      isDefault: json['isDefault'],
      isAvailable: json['isAvailable'],
      id: json['_id'],
    );
  }
}

class Addon {
  final String? name;
  final int? price;
  final bool? isAvailable;
  final String? id;

  Addon({this.name, this.price, this.isAvailable, this.id});

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      name: json['name'],
      price: json['price'],
      isAvailable: json['isAvailable'],
      id: json['_id'],
    );
  }
}

// Cart model can be added here if needed

class CartResponse {
  final bool? success;
  final CartData? cart;

  CartResponse({this.success, this.cart});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'],
      cart: json['cart'] != null ? CartData.fromJson(json['cart']) : null,
    );
  }
}

class CartData {
  final String? userId;
  final String? kitchenId;
  final List<CartItem>? items;
  final String? updatedAt;

  CartData({this.userId, this.kitchenId, this.items, this.updatedAt});

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      userId: json['userId'],
      kitchenId: json['kitchenId'],
      items: (json['items'] as List?)
          ?.map((e) => CartItem.fromJson(e))
          .toList(),
      updatedAt: json['updatedAt'],
    );
  }
}

class CartItem {
  final String? menuItemId;
  final String? name;
  final CartVariant? variant;
  final List<CartAddon>? addons;
  final int? quantity;
  final CartCustomization? customization;
  final int? itemTotal;

  CartItem({
    this.menuItemId,
    this.name,
    this.variant,
    this.addons,
    this.quantity,
    this.customization,
    this.itemTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItemId: json['menuItemId'],
      name: json['name'],
      variant: json['variant'] != null
          ? CartVariant.fromJson(json['variant'])
          : null,
      addons: (json['addons'] as List?)
          ?.map((e) => CartAddon.fromJson(e))
          .toList(),
      quantity: json['quantity'],
      customization: json['customization'] != null
          ? CartCustomization.fromJson(json['customization'])
          : null,
      itemTotal: json['itemTotal'],
    );
  }
}

class CartVariant {
  final String? label;
  final int? price;

  CartVariant({this.label, this.price});

  factory CartVariant.fromJson(Map<String, dynamic> json) {
    return CartVariant(label: json['label'], price: json['price']);
  }
}

class CartAddon {
  final String? name;
  final int? price;

  CartAddon({this.name, this.price});

  factory CartAddon.fromJson(Map<String, dynamic> json) {
    return CartAddon(name: json['name'], price: json['price']);
  }
}

class CartCustomization {
  final String? spiceLevel;
  final bool? isJain;
  final String? notes;

  CartCustomization({this.spiceLevel, this.isJain, this.notes});

  factory CartCustomization.fromJson(Map<String, dynamic> json) {
    return CartCustomization(
      spiceLevel: json['spiceLevel'],
      isJain: json['isJain'],
      notes: json['notes'],
    );
  }
}

//  Getprofile model can be added here if needed

class UserProfileResponse {
  final bool? success;
  final UserData? user;

  UserProfileResponse({this.success, this.user});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }
}

class UserData {
  final String? id;
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? role;
  final String? profileImage;
  final bool? profileCompleted;
  final DefaultAddress? defaultAddress;

  UserData({
    this.id,
    this.fullName,
    this.email,
    this.mobile,
    this.role,
    this.profileImage,
    this.profileCompleted,
    this.defaultAddress,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      profileImage: json['profileImage'],
      profileCompleted: json['profileCompleted'],
      defaultAddress: json['defaultAddress'] != null
          ? DefaultAddress.fromJson(json['defaultAddress'])
          : null,
    );
  }
}

class DefaultAddress {
  final GeoLocation? geoLocation;
  final String? label;
  final String? addressLine;
  final bool? isDefault;
  final String? id;

  DefaultAddress({
    this.geoLocation,
    this.label,
    this.addressLine,
    this.isDefault,
    this.id,
  });

  factory DefaultAddress.fromJson(Map<String, dynamic> json) {
    return DefaultAddress(
      geoLocation: json['geoLocation'] != null
          ? GeoLocation.fromJson(json['geoLocation'])
          : null,
      label: json['label'],
      addressLine: json['addressLine'],
      isDefault: json['isDefault'],
      id: json['_id'],
    );
  }
}

class GeoLocation {
  final String? type;
  final List<double>? coordinates;

  GeoLocation({this.type, this.coordinates});

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      type: json['type'],
      coordinates: (json['coordinates'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

// ========== 🛍️ CHECKOUT MODELS ==========

class CheckoutResponse {
  final bool? success;
  final Pricing? pricing;
  final DeliveryInfo? delivery;

  CheckoutResponse({this.success, this.pricing, this.delivery});

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      success: json['success'],
      pricing: json['pricing'] != null
          ? Pricing.fromJson(json['pricing'])
          : null,
      delivery: json['delivery'] != null
          ? DeliveryInfo.fromJson(json['delivery'])
          : null,
    );
  }
}

class Pricing {
  final int? foodTotal;
  final int? deliveryCharge;
  final int? finalAmount;

  Pricing({this.foodTotal, this.deliveryCharge, this.finalAmount});

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      foodTotal: json['foodTotal'],
      deliveryCharge: json['deliveryCharge'],
      finalAmount: json['finalAmount'],
    );
  }
}

class DeliveryInfo {
  final String? mode; // SELF_PICKUP, KITCHEN_RIDER, THIRD_PARTY
  final String? settlementOwner;
  final num? distanceKm;

  DeliveryInfo({this.mode, this.settlementOwner, this.distanceKm});

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      mode: json['mode'],
      settlementOwner: json['settlementOwner'],
      distanceKm: json['distanceKm'],
    );
  }
}
