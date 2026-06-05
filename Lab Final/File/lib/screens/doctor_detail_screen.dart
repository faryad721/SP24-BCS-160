import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/doctor.dart';
import '../providers/appointment_provider.dart';
import '../theme/colors.dart';
import 'book_appointment_screen.dart';
import 'chat_screen.dart';
import 'video_consultation_screen.dart';
import 'doctors_screen.dart' show DoctorAvatar;

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      DoctorAvatar(doctor: doctor, size: 80),
                      const SizedBox(height: 12),
                      Text(
                        doctor.name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialty,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionButtons(doctor: doctor),
                  const SizedBox(height: 24),
                  _StatsRow(doctor: doctor),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'About',
                    child: Text(
                      doctor.bio,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Hospital',
                    child: Row(
                      children: [
                        const Icon(Icons.local_hospital_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          doctor.hospital,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Available Days',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.availableDays
                          .map((d) => _DayChip(label: d))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Contact',
                    child: Column(
                      children: [
                        _ContactRow(icon: Icons.phone_outlined, text: doctor.phone),
                        const SizedBox(height: 8),
                        _ContactRow(icon: Icons.email_outlined, text: doctor.email),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BookAppointmentScreen(doctor: doctor),
                        ));
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(
                        'Book Appointment',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            icon: Icons.videocam_rounded,
            label: 'Video Call',
            color: AppColors.accent,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VideoConsultationScreen(doctor: doctor),
            )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Message',
            color: AppColors.primary,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(
                doctorId: doctor.id,
                doctorName: doctor.name,
                doctorSpecialty: doctor.specialty,
                isOnline: doctor.isOnline,
              ),
            )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionBtn(
            icon: Icons.phone_outlined,
            label: 'Call',
            color: AppColors.success,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Calling ${doctor.name}...'),
                backgroundColor: AppColors.success,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(value: '${doctor.experience}+', label: 'Years Exp.'),
        _Divider(),
        _StatItem(
            value: '${doctor.reviewCount}',
            label: 'Reviews'),
        _Divider(),
        _StatItem(
            value: doctor.rating.toStringAsFixed(1),
            label: 'Rating'),
        _Divider(),
        _StatItem(
            value: '\$${doctor.consultationFee.toStringAsFixed(0)}',
            label: 'Fee'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.border);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.text)),
      ],
    );
  }
}
