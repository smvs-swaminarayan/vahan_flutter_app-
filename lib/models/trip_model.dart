class TripModel {
  final int id;
  final String tripCode;
  final String date;
  final String time;
  final int? userId;
  final String userCode;
  final String userName;
  final int? vehicleId;
  final String vehicleName;
  final String vehiclePlate;
  final String from;
  final String to;
  final int displayNumber;
  final String estimatedDuration;
  final String reason;
  final String bookingType;
  final String status;
  final int? endOdo;
  final int? actualKm;
  final String? approvedBy;
  final String? returnNotes;

  TripModel({
    required this.id,
    required this.tripCode,
    required this.date,
    required this.time,
    this.userId,
    this.userCode = '',
    required this.userName,
    this.vehicleId,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.from,
    required this.to,
    this.displayNumber = 0,
    this.estimatedDuration = '30 min',
    this.reason = '',
    this.bookingType = 'INSTANT',
    this.status = 'SUBMITTED',
    this.endOdo,
    this.actualKm,
    this.approvedBy,
    this.returnNotes,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tripCode: json['tripCode']?.toString() ?? json['trip_code']?.toString() ?? '',
      date: json['date']?.toString() ?? json['trip_date']?.toString() ?? '',
      time: json['time']?.toString() ?? json['trip_time']?.toString() ?? '',
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? json['user_id']?.toString() ?? ''),
      userCode: json['userCode']?.toString() ?? json['user_code']?.toString() ?? '',
      userName: json['muktoName']?.toString() ?? json['driverName']?.toString() ?? json['user_name']?.toString() ?? 'User',
      vehicleId: json['vehicleId'] is int
          ? json['vehicleId']
          : int.tryParse(json['vehicleId']?.toString() ?? json['vehicle_id']?.toString() ?? ''),
      vehicleName: json['vehicleName']?.toString() ?? json['vehicle_name']?.toString() ?? '',
      vehiclePlate: json['vehiclePlate']?.toString() ?? json['vehicle_plate']?.toString() ?? '',
      from: json['from']?.toString() ?? json['from_location']?.toString() ?? '',
      to: json['to']?.toString() ?? json['to_location']?.toString() ?? '',
      displayNumber: json['displayNumber'] is int
          ? json['displayNumber']
          : int.tryParse(json['displayNumber']?.toString() ?? json['display_number']?.toString() ?? '0') ?? 0,
      estimatedDuration: json['estimatedDuration']?.toString() ?? json['estimated_duration']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? json['booking_type']?.toString() ?? 'INSTANT',
      status: json['status']?.toString() ?? 'SUBMITTED',
      endOdo: json['endOdo'] is int
          ? json['endOdo']
          : int.tryParse(json['endOdo']?.toString() ?? json['end_odo']?.toString() ?? ''),
      actualKm: json['actualKm'] is int
          ? json['actualKm']
          : int.tryParse(json['actualKm']?.toString() ?? json['actual_km']?.toString() ?? ''),
      approvedBy: json['approvedBy']?.toString() ?? json['approved_by']?.toString(),
      returnNotes: json['returnNotes']?.toString() ?? json['return_notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripCode': tripCode,
      'date': date,
      'time': time,
      'userId': userId,
      'userCode': userCode,
      'muktoName': userName,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehiclePlate': vehiclePlate,
      'from': from,
      'to': to,
      'displayNumber': displayNumber,
      'estimatedDuration': estimatedDuration,
      'reason': reason,
      'bookingType': bookingType,
      'status': status,
      'endOdo': endOdo,
      'actualKm': actualKm,
      'approvedBy': approvedBy,
      'returnNotes': returnNotes,
    };
  }

  bool get isApproved => status == 'APPROVED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isScheduled => status == 'SCHEDULED';
  bool get isSubmitted => status == 'SUBMITTED';
}
