import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/doctor.dart';
import '../theme/colors.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _search = TextEditingController();
  String _selectedSpecialty = 'All';

  final List<String> _specialties = [
    'All', 'Cardiologist', 'Neurologist', 'Pediatrician',
    'Orthopedic Surgeon', 'Dermatologist',
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Doctor> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return Doctor.sampleDoctors.where((d) {
      final matchSpec = _selectedSpecialty == 'All' || d.specialty == _selectedSpecialty;
      final matchQ = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q) ||
          d.hospital.toLowerCase().contains(q);
      return matchSpec && matchQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Doctors',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Doctor.sampleDoctors.length} specialists available',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _SearchBar(
                controller: _search,
                onChanged: () => setState(() {}),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _specialties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final sp = _specialties[i];
                  final selected = sp == _selectedSpecialty;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSpecialty = sp),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        sp,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: doctors.isEmpty
                  ? Center(
                      child: Text('No doctors found',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: doctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _DoctorCard(
                        doctor: doctors[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(doctor: doctors[i]),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.placeholder),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: 'Search doctors, specialty...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.placeholder),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.text),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged();
              },
              child: const Icon(Icons.close, size: 18, color: AppColors.placeholder),
            ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});
  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            DoctorAvatar(doctor: doctor, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (doctor.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Online',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor.specialty,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor.hospital,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFA000)),
                      const SizedBox(width: 3),
                      Text(
                        '${doctor.rating} (${doctor.reviewCount} reviews)',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '\$${doctor.consultationFee.toStringAsFixed(0)}/visit',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({required this.doctor, this.size = 56});
  final Doctor doctor;
  final double size;

  static const _colors = [
    Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFF00695C),
    Color(0xFFE65100), Color(0xFF283593),
  ];

  Color get _color {
    final idx = doctor.name.codeUnits.fold(0, (a, b) => a + b) % _colors.length;
    return _colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final initial = doctor.name.isNotEmpty ? doctor.name.split(' ').map((e) => e[0]).take(2).join() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: size * 0.3,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
