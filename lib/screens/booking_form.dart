import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BookingForm extends StatefulWidget {
  final List<UserModel> users;
  final List<VehicleModel> vehicles;
  final List<String> destinations;
  final VoidCallback onBookingSuccess;

  const BookingForm({
    super.key,
    required this.users,
    required this.vehicles,
    required this.destinations,
    required this.onBookingSuccess,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();

  UserModel? _selectedUser;
  bool _isOtherUser = false;
  final _otherNameController = TextEditingController();

  VehicleModel? _selectedVehicle;
  final _fromController = TextEditingController(text: 'Sahaj Farm');
  final _toController = TextEditingController();
  final _reasonController = TextEditingController();
  final _durationController = TextEditingController(text: '30 min');
  final _displayNumberController = TextEditingController();

  bool _isAdvanceBooking = false;
  DateTime _bookingDate = DateTime.now();
  TimeOfDay _bookingTime = TimeOfDay.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicles.isNotEmpty) {
      _selectedVehicle = widget.vehicles.first;
      _displayNumberController.text = _selectedVehicle!.currentKm.toString();
    }
  }

  @override
  void dispose() {
    _otherNameController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _reasonController.dispose();
    _durationController.dispose();
    _displayNumberController.dispose();
    super.dispose();
  }

  void _onVehicleChanged(VehicleModel? v) {
    setState(() {
      _selectedVehicle = v;
      if (v != null) {
        _displayNumberController.text = v.currentKm.toString();
      }
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final driverName = _isOtherUser
        ? _otherNameController.text.trim()
        : (_selectedUser?.name ?? 'User');

    if (driverName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter driver name')),
      );
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tripDateStr = DateFormat('yyyy-MM-dd').format(_bookingDate);
      final tripTimeStr = _bookingTime.format(context);

      final tripData = {
        'muktoId': _isOtherUser ? null : _selectedUser?.id,
        'userCode': _isOtherUser ? '' : _selectedUser?.userCode,
        'muktoName': driverName,
        'vehicleId': _selectedVehicle!.id,
        'vehicleName': _selectedVehicle!.name,
        'vehiclePlate': _selectedVehicle!.plateNumber,
        'from': _fromController.text.trim(),
        'to': _toController.text.trim(),
        'displayNumber': int.tryParse(_displayNumberController.text) ?? _selectedVehicle!.currentKm,
        'estimatedDuration': _durationController.text.trim(),
        'reason': _reasonController.text.trim(),
        'bookingType': _isAdvanceBooking ? 'ADVANCE' : 'INSTANT',
        'date': tripDateStr,
        'time': tripTimeStr,
      };

      await ApiService.insertTrip(tripData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Trip successfully booked for $driverName!'),
          ),
        );
        widget.onBookingSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Movement Booking',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'SMVS Swaminarayan Dham Fleet',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Booking Type Selector (Instant vs 2-Day Advance)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAdvanceBooking = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isAdvanceBooking ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: !_isAdvanceBooking ? AppColors.primary : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '⚡ Instant (Now)',
                      style: TextStyle(
                        color: !_isAdvanceBooking ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAdvanceBooking = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isAdvanceBooking ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _isAdvanceBooking ? AppColors.primary : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '📅 Next 2-Days Booking',
                      style: TextStyle(
                        color: _isAdvanceBooking ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Driver Selection Section
          _buildCard(
            title: '1. Driver / Mukto Selection',
            icon: Icons.person_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<UserModel?>(
                  value: _isOtherUser ? null : _selectedUser,
                  isExpanded: true,
                  decoration: _inputDecoration('Select Driver / Maharaj'),
                  items: [
                    ...widget.users.map((u) => DropdownMenuItem<UserModel?>(
                          value: u,
                          child: Text(
                            u.userCode.isNotEmpty ? '${u.userCode} - ${u.name}' : u.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        )),
                    const DropdownMenuItem<UserModel?>(
                      value: null,
                      child: Text('➕ Other (New Member)', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      if (val == null) {
                        _isOtherUser = true;
                        _selectedUser = null;
                      } else {
                        _isOtherUser = false;
                        _selectedUser = val;
                      }
                    });
                  },
                ),
                if (_isOtherUser) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _otherNameController,
                    decoration: _inputDecoration('Enter Driver Name'),
                    validator: (val) => _isOtherUser && (val == null || val.trim().isEmpty) ? 'Please enter name' : null,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Vehicle Selection
          _buildCard(
            title: '2. Vehicle Selection',
            icon: Icons.airport_shuttle_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<VehicleModel>(
                  value: _selectedVehicle,
                  isExpanded: true,
                  decoration: _inputDecoration('Select Fleet Vehicle'),
                  items: widget.vehicles.map((v) {
                    return DropdownMenuItem<VehicleModel>(
                      value: v,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${v.name} (${v.plateNumber})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${v.currentKm} KM',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onVehicleChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _displayNumberController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Starting Odometer (KM)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: _inputDecoration('Est. Duration (e.g. 1 hr)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Route & Purpose
          _buildCard(
            title: '3. Route & Purpose',
            icon: Icons.location_on_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _fromController,
                  decoration: _inputDecoration('From Location (e.g. Sahaj Farm)'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _toController,
                  decoration: _inputDecoration('To Destination (e.g. Swaminarayan Dham)'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  decoration: _inputDecoration('Movement Purpose / Notes (Optional)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBooking,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Confirm & Record Movement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
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
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
