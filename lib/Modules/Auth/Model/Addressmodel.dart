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
