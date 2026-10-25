class VehicleModel {
  final int id;
  final String name;
  final String plateNumber;
  final String type;
  final int currentKm;
  final String serviceStatus;
  final bool isActive;

  VehicleModel({
    required this.id,
    required this.name,
    required this.plateNumber,
    this.type = 'Car',
    this.currentKm = 0,
    this.serviceStatus = 'AVAILABLE',
    this.isActive = true,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? json['plate_number']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Car',
      currentKm: json['currentKm'] is int
          ? json['currentKm']
          : int.tryParse(json['currentKm']?.toString() ?? json['current_km']?.toString() ?? '0') ?? 0,
      serviceStatus: json['serviceStatus']?.toString() ?? json['service_status']?.toString() ?? 'AVAILABLE',
      isActive: json['isActive'] == true || json['is_active'] == 1 || json['isActive'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plateNumber': plateNumber,
      'type': type,
      'currentKm': currentKm,
      'serviceStatus': serviceStatus,
      'isActive': isActive,
    };
  }

  bool get isAvailable => serviceStatus.toUpperCase() == 'AVAILABLE';
  bool get isInUse => serviceStatus.toUpperCase() == 'IN_USE';
  bool get isMaintenance => serviceStatus.toUpperCase() == 'MAINTENANCE';
}
