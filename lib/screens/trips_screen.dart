import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TripsScreen extends StatefulWidget {
  final List<TripModel> trips;
  final VoidCallback onRefresh;

  const TripsScreen({
    super.key,
    required this.trips,
    required this.onRefresh,
  });

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  void _openReturnDialog(TripModel trip) {
    final endOdoController = TextEditingController(text: trip.displayNumber.toString());
    final notesController = TextEditingController();
    int actualKm = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void calcKm() {
              final end = int.tryParse(endOdoController.text) ?? trip.displayNumber;
              setModalState(() {
                actualKm = end >= trip.displayNumber ? (end - trip.displayNumber) : 0;
              });
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Return Vehicle (Check-in)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${trip.vehicleName} • Driver: ${trip.userName}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Initial Odometer Chip
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Starting Odometer:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('${trip.displayNumber} KM', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // End Odometer Input
                    TextField(
                      controller: endOdoController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calcKm(),
                      decoration: InputDecoration(
                        labelText: 'End Odometer (KM)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Distance Traveled Summary
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Distance Traveled:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(
                            '$actualKm KM',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Return Notes (Optional)',
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final endVal = int.tryParse(endOdoController.text) ?? trip.displayNumber;
                          if (endVal < trip.displayNumber) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('End Odometer cannot be less than Start Odometer')),
                            );
                            return;
                          }

                          Navigator.pop(ctx);
                          try {
                            await ApiService.returnVehicle(
                              tripId: trip.id,
                              vehicleId: trip.vehicleId,
                              endOdo: endVal,
                              actualKm: actualKm,
                              returnNotes: notesController.text.trim(),
                            );
                            widget.onRefresh();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text('Complete Return & Update Odometer', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrips = widget.trips.where((t) => !t.isCompleted).toList();
    final completedTrips = widget.trips.where((t) => t.isCompleted).toList();

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active Trips Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Movements (${activeTrips.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: widget.onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (activeTrips.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.success),
                  SizedBox(height: 8),
                  Text('All fleet vehicles currently at depot', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text('No movements currently active', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            )
          else
            ...activeTrips.map((trip) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trip.vehicleName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: trip.isApproved ? AppColors.successLight : AppColors.warningLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            trip.status,
                            style: TextStyle(
                              color: trip.isApproved ? AppColors.success : AppColors.warning,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${trip.userCode.isNotEmpty ? '[${trip.userCode}] ' : ''}${trip.userName}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Route: ${trip.from} ➔ ${trip.to}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Start Odometer: ${trip.displayNumber} KM • ${trip.date} at ${trip.time}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _openReturnDialog(trip),
                        icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                        label: const Text('Return Vehicle / Check-in', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Completed Trips Header
          Text(
            'Completed History (${completedTrips.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          if (completedTrips.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No trip history recorded yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
            )
          else
            ...completedTrips.map((trip) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${trip.vehicleName} (${trip.userName})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('${trip.from} ➔ ${trip.to} • ${trip.date}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${trip.actualKm ?? 0} KM',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                      ),
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
