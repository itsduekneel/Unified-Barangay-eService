// ============================================================================
// lib/features/staff/route_planning_page.dart
// Staff: Route Planning Module
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/services/mock/mock_service.dart';
import 'package:ube/models/app_models.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class RoutePlanningPage extends StatefulWidget {
  const RoutePlanningPage({super.key});

  @override
  State<RoutePlanningPage> createState() => _RoutePlanningPageState();
}

class _RoutePlanningPageState extends State<RoutePlanningPage> {
  List<PatrolRouteModel> _routes = [];
  bool _isLoading = true;
  final List<String> _checkpoints = [];
  final TextEditingController _checkpointCtrl = TextEditingController();
  String _selectedTanod = 'Carlo Dela Peña';
  final String _selectedDate = 'May 5, 2025';
  final String _startTime = '10:00 PM';
  final String _endTime = '2:00 AM';

  final List<String> _tanodOptions = ['Carlo Dela Peña', 'Ramon Torres'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _checkpointCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await MockService.getPatrolRoutes();
    if (mounted) {
      setState(() {
        _routes = data;
        _isLoading = false;
      });
    }
  }

  void _addCheckpoint() {
    final text = _checkpointCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checkpoints.add(text);
      _checkpointCtrl.clear();
    });
  }

  void _showCreateSheet() {
    setState(() {
      _checkpoints.clear();
      _checkpointCtrl.clear();
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateRouteSheet(
        tanodOptions: _tanodOptions,
        selectedTanod: _selectedTanod,
        onTanodChanged: (v) => setState(() => _selectedTanod = v!),
        checkpoints: _checkpoints,
        checkpointCtrl: _checkpointCtrl,
        onAddCheckpoint: _addCheckpoint,
        onRemoveCheckpoint: (i) => setState(() => _checkpoints.removeAt(i)),
        onSave: _saveRoute,
      ),
    );
  }

  Future<void> _saveRoute() async {
    Navigator.pop(context);
    final route = PatrolRouteModel(
      id: 'PAT_NEW',
      name: 'New Patrol Route',
      checkpoints: List.from(_checkpoints),
      startTime: _startTime,
      endTime: _endTime,
      assignedTanod: _selectedTanod,
      assignedTanodId: 'S003',
      date: _selectedDate,
      status: 'Scheduled',
      completedCheckpoints: 0,
    );
    await MockService.createPatrolRoute(route);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route created successfully!'),
          backgroundColor: _kPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Route Planning',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: _kBg,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kPrimary,
        onPressed: _showCreateSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Route',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Coverage map placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: _kPrimaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.route, color: _kPrimary, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Route Coverage Map',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _kPrimary,
                            ),
                          ),
                          Text(
                            '(Map integration in production)',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Planned Routes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_routes.length} routes',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _routes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = _routes[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kPrimaryLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _kBorder),
                                  ),
                                  child: Text(
                                    r.status,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: _kPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_pin_circle_outlined,
                                  size: 14,
                                  color: _kPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r.assignedTanod,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _kPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${r.startTime} – ${r.endTime}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r.date,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${r.checkpoints.length} checkpoints: '
                              '${r.checkpoints.take(2).join(', ')}'
                              '${r.checkpoints.length > 2 ? '...' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Create Route Bottom Sheet ────────────────────────────────────────────────

class _CreateRouteSheet extends StatefulWidget {
  final List<String> tanodOptions;
  final String selectedTanod;
  final ValueChanged<String?> onTanodChanged;
  final List<String> checkpoints;
  final TextEditingController checkpointCtrl;
  final VoidCallback onAddCheckpoint;
  final ValueChanged<int> onRemoveCheckpoint;
  final VoidCallback onSave;

  const _CreateRouteSheet({
    required this.tanodOptions,
    required this.selectedTanod,
    required this.onTanodChanged,
    required this.checkpoints,
    required this.checkpointCtrl,
    required this.onAddCheckpoint,
    required this.onRemoveCheckpoint,
    required this.onSave,
  });

  @override
  State<_CreateRouteSheet> createState() => _CreateRouteSheetState();
}

class _CreateRouteSheetState extends State<_CreateRouteSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Create Patrol Route',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Assign Tanod',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: widget.selectedTanod,
              onChanged: widget.onTanodChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kBorder),
                ),
              ),
              items: widget.tanodOptions
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            const Text(
              'Add Checkpoints',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.checkpointCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Brgy Hall Gate',
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    widget.onAddCheckpoint();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...widget.checkpoints.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: _kPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onRemoveCheckpoint(e.key);
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: widget.checkpoints.isEmpty ? null : widget.onSave,
                child: const Text(
                  'Save Route',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
