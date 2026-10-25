class FuelLogModel {
  final int id;
  final String date;
  final int? vehicleId;
  final String vehicleName;
  final String vehiclePlate;
  final double liters;
  final double amount;
  final int odometer;
  final String receiptNo;
  final String notes;

  FuelLogModel({
    required this.id,
    required this.date,
    this.vehicleId,
    required this.vehicleName,
    required this.vehiclePlate,
    this.liters = 0.0,
    this.amount = 0.0,
    this.odometer = 0,
    this.receiptNo = '',
    this.notes = '',
  });

  factory FuelLogModel.fromJson(Map<String, dynamic> json) {
    return FuelLogModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      date: json['date']?.toString() ?? json['fuelDate']?.toString() ?? json['fuel_date']?.toString() ?? '',
      vehicleId: json['vehicleId'] is int
          ? json['vehicleId']
          : int.tryParse(json['vehicleId']?.toString() ?? json['vehicle_id']?.toString() ?? ''),
      vehicleName: json['vehicleName']?.toString() ?? json['vehicle_name']?.toString() ?? '',
      vehiclePlate: json['vehiclePlate']?.toString() ?? json['vehicle_plate']?.toString() ?? '',
      liters: json['liters'] is num
          ? (json['liters'] as num).toDouble()
          : double.tryParse(json['liters']?.toString() ?? '0') ?? 0.0,
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      odometer: json['odometer'] is int
          ? json['odometer']
          : int.tryParse(json['odometer']?.toString() ?? '0') ?? 0,
      receiptNo: json['receiptNo']?.toString() ?? json['receipt_no']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fuelDate': date,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehiclePlate': vehiclePlate,
      'liters': liters,
      'amount': amount,
      'odometer': odometer,
      'receiptNo': receiptNo,
      'notes': notes,
    };
  }
}
