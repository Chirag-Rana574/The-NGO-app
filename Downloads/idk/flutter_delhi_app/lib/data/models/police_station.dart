class PoliceStation {
  final String id;
  final String name;
  final String district;
  final String address;
  final List<String> phone;
  final String? shoName;
  final double? latitude;
  final double? longitude;

  PoliceStation({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.phone,
    this.shoName,
    this.latitude,
    this.longitude,
  });

  factory PoliceStation.fromJson(Map<String, dynamic> json, int fallbackId) {
    List<String> parsePhones(dynamic phoneData) {
      if (phoneData == null) return [];
      if (phoneData is List) {
        return phoneData.map((e) => e.toString()).toList();
      }
      if (phoneData is String) {
        return phoneData.split(',').map((e) => e.trim()).toList();
      }
      return [];
    }

    return PoliceStation(
      id: json['id']?.toString() ?? fallbackId.toString(),
      name: json['NAME'] ?? json['name'] ?? '',
      district: json['CATEGORY'] ?? json['district'] ?? '',
      address: json['ADDRESS'] ?? json['address'] ?? '',
      phone: parsePhones(json['PHONE'] ?? json['phone']),
      shoName: json['sho_name'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }
}
