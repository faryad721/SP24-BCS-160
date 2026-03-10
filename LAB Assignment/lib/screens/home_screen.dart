import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../widgets/patient_card.dart';
import '../widgets/section_header.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Patient> _patients = [];
  List<Patient> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    final data = await _db.getPatients();
    if (!mounted) return;
    setState(() {
      _patients = data;
      _filtered = data;
      _loading = false;
    });
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filtered = _patients);
      return;
    }
    setState(() {
      _filtered = _patients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
            patient.phone.toLowerCase().contains(query) ||
            patient.condition.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _openForm([Patient? patient]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientFormScreen(patient: patient),
      ),
    );
    await _loadPatients();
  }

  Future<void> _openDetail(Patient patient) async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patient: patient),
      ),
    );
    if (updated == true) {
      await _loadPatients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Desk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPatients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Patient'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(total: _patients.length),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Patients',
                action: Text(
                  '${_filtered.length} records',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black45),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or condition',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? _EmptyState(onCreate: () => _openForm())
                        : ListView.separated(
                            itemCount: _filtered.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final patient = _filtered[index];
                              return PatientCard(
                                patient: patient,
                                index: index,
                                onTap: () => _openDetail(patient),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.brand, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good day, Doctor',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'You have $total active patient records',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _QuickStat(label: 'Appointments', value: 'Today'),
              _QuickStat(label: 'Focus', value: 'Follow-ups'),
              _QuickStat(label: 'Clinic', value: 'In-house'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded,
                size: 72, color: AppTheme.accent),
            const SizedBox(height: 12),
            Text(
              'No patients yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first patient record to get started.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
