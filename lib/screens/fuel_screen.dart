import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fuel_model.dart';
import '../models/vehicle_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class FuelScreen extends StatefulWidget {
  final List<FuelLogModel> fuelLogs;
  final List<VehicleModel> vehicles;
  final VoidCallback onRefresh;

  const FuelScreen({
    super.key,
    required this.fuelLogs,
    required this.vehicles,
    required this.onRefresh,
  });

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  void _openAddFuelDialog() {
    final vehicle = widget.vehicles.isNotEmpty ? widget.vehicles.first : null;
    final amountController = TextEditingController();
    final litersController = TextEditingController();
    final odoController = TextEditingController(text: vehicle?.currentKm.toString() ?? '');
    final receiptController = TextEditingController();
    final notesController = TextEditingController();
    DateTime fuelDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add Fuel Refill Slip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                      ],
                    ),
                    const Divider(height: 20),

                    // Amount
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fuel Amount (₹) *',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Liters (Optional)
                    TextField(
                      controller: litersController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Liters (Optional)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Odometer (Optional)
                    TextField(
                      controller: odoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Odometer (KM) (Optional)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Receipt & Notes
                    TextField(
                      controller: receiptController,
                      decoration: InputDecoration(
                        labelText: 'Receipt No. / Bill Ref (Optional)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes / Station Name (Optional)',
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
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final amt = double.tryParse(amountController.text) ?? 0.0;
                          if (amt <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter valid fuel amount')),
                            );
                            return;
                          }

                          Navigator.pop(ctx);
                          try {
                            await ApiService.insertFuelLog({
                              'vehicleId': vehicle?.id,
                              'vehicleName': vehicle?.name ?? 'Fleet Car',
                              'vehiclePlate': vehicle?.plateNumber ?? '',
                              'amount': amt,
                              'liters': double.tryParse(litersController.text) ?? 0.0,
                              'odometer': int.tryParse(odoController.text) ?? (vehicle?.currentKm ?? 0),
                              'receiptNo': receiptController.text.trim(),
                              'notes': notesController.text.trim(),
                              'fuelDate': DateFormat('yyyy-MM-dd').format(fuelDate),
                            });
                            widget.onRefresh();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text('Save Fuel Entry', style: TextStyle(fontWeight: FontWeight.w800)),
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
    final filteredLogs = widget.fuelLogs.where((f) => f.date.startsWith(_selectedMonth)).toList();
    final totalAmount = filteredLogs.fold<double>(0.0, (acc, cur) => acc + cur.amount);
    final totalLiters = filteredLogs.fold<double>(0.0, (acc, cur) => acc + cur.liters);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _openAddFuelDialog,
        icon: const Icon(Icons.local_gas_station_rounded, color: Colors.white),
        label: const Text('Add Fuel Slip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Month Filter & Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Month Filter:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      DropdownButton<String>(
                        value: _selectedMonth,
                        underline: const SizedBox(),
                        items: [
                          DateFormat('yyyy-MM').format(DateTime.now()),
                          DateFormat('yyyy-MM').format(DateTime.now().subtract(const Duration(days: 30))),
                          DateFormat('yyyy-MM').format(DateTime.now().subtract(const Duration(days: 60))),
                        ].map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontWeight: FontWeight.w800)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMonth = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Expense', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Liters', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text('${totalLiters.toStringAsFixed(1)} L', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Entries', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text('${filteredLogs.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.success)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logs List
            if (filteredLogs.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text('No fuel refills recorded for this month', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              )
            else
              ...filteredLogs.map((log) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.local_gas_station_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.vehicleName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text('${log.date} • Odometer: ${log.odometer} KM', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${log.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryDark)),
                          if (log.liters > 0)
                            Text('${log.liters} L', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
