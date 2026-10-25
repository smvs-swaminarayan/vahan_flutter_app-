import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/trip_model.dart';
import '../models/fuel_model.dart';
import '../theme/app_theme.dart';
import 'booking_form.dart';
import 'trips_screen.dart';
import 'fuel_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  List<UserModel> _users = [];
  List<VehicleModel> _vehicles = [];
  List<String> _destinations = [];
  List<TripModel> _trips = [];
  List<FuelLogModel> _fuelLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.fetchAllData();
      setState(() {
        _users = data.users;
        _vehicles = data.vehicles;
        _destinations = data.destinations;
        _trips = data.trips;
        _fuelLogs = data.fuelLogs;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_car_rounded, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STK Vahan Vyvastha',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                Text(
                  'Hostinger Live Sync',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync Fleet Data',
            onPressed: _fetchData,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppColors.primaryLight,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
            label: 'Book',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: 'Movements',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_gas_station_outlined),
            selectedIcon: Icon(Icons.local_gas_station_rounded, color: AppColors.primary),
            label: 'Fuel',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded, color: AppColors.primary),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Connecting to STK Hostinger Database...',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              const Text('Connection Failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentIndex) {
      case 0:
        return BookingForm(
          users: _users,
          vehicles: _vehicles,
          destinations: _destinations,
          onBookingSuccess: () {
            _fetchData();
            setState(() => _currentIndex = 1); // switch to Movements tab
          },
        );
      case 1:
        return TripsScreen(
          trips: _trips,
          onRefresh: _fetchData,
        );
      case 2:
        return FuelScreen(
          fuelLogs: _fuelLogs,
          vehicles: _vehicles,
          onRefresh: _fetchData,
        );
      case 3:
        return AdminScreen(
          trips: _trips,
          vehicles: _vehicles,
          users: _users,
          onRefresh: _fetchData,
        );
      default:
        return const SizedBox();
    }
  }
}
