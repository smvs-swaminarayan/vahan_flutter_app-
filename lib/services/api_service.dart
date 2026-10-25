import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/trip_model.dart';
import '../models/fuel_model.dart';

class VahanData {
  final List<UserModel> users;
  final List<VehicleModel> vehicles;
  final List<String> destinations;
  final List<TripModel> trips;
  final List<FuelLogModel> fuelLogs;

  VahanData({
    required this.users,
    required this.vehicles,
    required this.destinations,
    required this.trips,
    required this.fuelLogs,
  });
}

class ApiService {
  // Live Vercel Production API URL
  static const String baseUrl = 'https://vahan-vyvastha.vercel.app/api/vahan';

  // 1. Fetch All Fleet Data
  static Future<VahanData> fetchAllData() async {
    final response = await http.get(Uri.parse('$baseUrl?action=fetchAll'));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      final users = (data['users'] as List? ?? data['muktos'] as List? ?? [])
          .map((u) => UserModel.fromJson(u))
          .toList();

      final vehicles = (data['vehicles'] as List? ?? [])
          .map((v) => VehicleModel.fromJson(v))
          .toList();

      final destinations = (data['destinations'] as List? ?? data['locations'] as List? ?? [])
          .map((d) => d['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      final trips = (data['trips'] as List? ?? [])
          .map((t) => TripModel.fromJson(t))
          .toList();

      final fuelLogs = (data['fuelLogs'] as List? ?? [])
          .map((f) => FuelLogModel.fromJson(f))
          .toList();

      return VahanData(
        users: users,
        vehicles: vehicles,
        destinations: destinations,
        trips: trips,
        fuelLogs: fuelLogs,
      );
    } else {
      throw Exception('Failed to load fleet data (HTTP ${response.statusCode})');
    }
  }

  // 2. Request / Book a Trip
  static Future<TripModel> insertTrip(Map<String, dynamic> tripData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'action': 'insertTrip',
        'data': tripData,
      }),
    );

    if (response.statusCode == 200) {
      final jsonRes = json.decode(utf8.decode(response.bodyBytes));
      return TripModel.fromJson(jsonRes);
    } else {
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'Failed to submit trip booking');
    }
  }

  // 3. Approve Trip (Admin)
  static Future<bool> approveTrip({
    required int tripId,
    int? vehicleId,
    String leaderName = 'Admin Leader',
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'action': 'approveTrip',
        'tripId': tripId,
        'vehicleId': vehicleId,
        'leaderName': leaderName,
      }),
    );

    return response.statusCode == 200;
  }

  // 4. Return Vehicle (Check-in)
  static Future<bool> returnVehicle({
    required int tripId,
    int? vehicleId,
    required int endOdo,
    required int actualKm,
    String returnNotes = '',
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'action': 'returnVehicle',
        'tripId': tripId,
        'vehicleId': vehicleId,
        'endOdo': endOdo,
        'actualKm': actualKm,
        'returnNotes': returnNotes,
      }),
    );

    return response.statusCode == 200;
  }

  // 5. Add Fuel Refill Entry
  static Future<FuelLogModel> insertFuelLog(Map<String, dynamic> fuelData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'action': 'insertFuelLog',
        'data': fuelData,
      }),
    );

    if (response.statusCode == 200) {
      final jsonRes = json.decode(utf8.decode(response.bodyBytes));
      return FuelLogModel.fromJson(jsonRes);
    } else {
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'Failed to record fuel slip');
    }
  }

  // 6. Admin Authentication
  static Future<Map<String, dynamic>> adminLogin({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'action': 'adminLogin',
        'username': username,
        'password': password,
      }),
    );

    final res = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && res['success'] == true) {
      return res['admin'];
    } else {
      throw Exception(res['error'] ?? 'Authentication failed');
    }
  }
}
