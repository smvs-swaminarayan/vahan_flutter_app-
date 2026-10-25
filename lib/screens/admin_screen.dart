import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/vehicle_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  final List<TripModel> trips;
  final List<VehicleModel> vehicles;
  final List<UserModel> users;
  final VoidCallback onRefresh;

  const AdminScreen({
    super.key,
    required this.trips,
    required this.vehicles,
    required this.users,
    required this.onRefresh,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, dynamic>? _adminUser;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMsg = '';

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final admin = await ApiService.adminLogin(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() => _adminUser = admin);
    } catch (e) {
      setState(() => _errorMsg = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    setState(() {
      _adminUser = null;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  Future<void> _approveTrip(TripModel trip) async {
    try {
      await ApiService.approveTrip(
        tripId: trip.id,
        vehicleId: trip.vehicleId,
        leaderName: _adminUser?['name'] ?? 'Admin Leader',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.success, content: Text('Trip approved for ${trip.userName}!')),
      );
      widget.onRefresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.danger, content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_adminUser == null) {
      return _buildLoginForm();
    }
    return _buildAdminDashboard();
  }

  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text('Admin Gate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const Text('Authorized SMVS STK Leaders Only', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),

              if (_errorMsg.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMsg, style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign In to Admin Portal', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDashboard() {
    final pendingTrips = widget.trips.where((t) => t.isSubmitted).toList();

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Admin Profile Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _adminUser?['name'] ?? 'Admin',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        'Role: ${_adminUser?['role'] ?? 'ADMIN'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                  onPressed: _handleLogout,
                  tooltip: 'Sign Out',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pending Approvals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Key Approvals (${pendingTrips.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              IconButton(icon: const Icon(Icons.refresh_rounded, size: 20), onPressed: widget.onRefresh),
            ],
          ),
          const SizedBox(height: 8),

          if (pendingTrips.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text('No pending movement approvals at this time', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            )
          else
            ...pendingTrips.map((trip) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(trip.vehicleName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('${trip.date} • ${trip.time}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Driver: ${trip.userName}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text('Route: ${trip.from} ➔ ${trip.to}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    if (trip.reason.isNotEmpty)
                      Text('Purpose: ${trip.reason}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _approveTrip(trip),
                        icon: const Icon(Icons.vpn_key_rounded, size: 18),
                        label: const Text('Approve & Issue Vehicle Key', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Fleet Overview Cards
          const Text('Fleet Overview (Hostinger MySQL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),

          ...widget.vehicles.map((v) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_car_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('Plate: ${v.plateNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${v.currentKm} KM', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primaryDark)),
                      Text(v.serviceStatus, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
