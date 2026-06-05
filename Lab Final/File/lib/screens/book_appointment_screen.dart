import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../providers/appointment_provider.dart';
import '../theme/colors.dart';
import '../widgets/toast.dart';
import 'doctors_screen.dart' show DoctorAvatar;

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required this.doctor});
  final Doctor doctor;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '9:00 AM';
  String _selectedType = 'In-Person';
  final _notesController = TextEditingController();
  final _nameController = TextEditingController(text: 'Patient');
  bool _loading = false;

  final List<String> _times = [
    '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '2:00 PM', '2:30 PM',
    '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    setState(() => _loading = true);
    try {
      await context.read<AppointmentProvider>().bookAppointment(
            doctor: widget.doctor,
            date: DateFormat('yyyy-MM-dd').format(_selectedDate),
            time: _selectedTime,
            type: _selectedType,
            notes: _notesController.text.trim(),
            patientName: _nameController.text.trim().isEmpty
                ? 'Patient'
                : _nameController.text.trim(),
          );
      if (!mounted) return;
      AppToast.show(
          message: 'Appointment booked with ${widget.doctor.name}!',
          type: ToastType.success);
      Navigator.of(context).pop();
    } catch (e) {
      AppToast.show(message: 'Booking failed. Try again.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorSummary(doctor: widget.doctor),
            const SizedBox(height: 24),
            _SectionTitle('Your Name'),
            const SizedBox(height: 8),
            _inputField(
              controller: _nameController,
              hint: 'Enter your name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _SectionTitle('Select Date'),
            const SizedBox(height: 10),
            _DatePicker(
              selected: _selectedDate,
              onChanged: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 20),
            _SectionTitle('Select Time'),
            const SizedBox(height: 10),
            _TimeGrid(
              times: _times,
              selected: _selectedTime,
              onSelected: (t) => setState(() => _selectedTime = t),
            ),
            const SizedBox(height: 20),
            _SectionTitle('Visit Type'),
            const SizedBox(height: 10),
            Row(
              children: Appointment.types.map((type) {
                final selected = type == _selectedType;
                IconData icon = Icons.person_outline;
                if (type == 'Video Call') icon = Icons.videocam_outlined;
                if (type == 'Phone Call') icon = Icons.phone_outlined;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(icon,
                              size: 20,
                              color: selected ? AppColors.primary : AppColors.placeholder),
                          const SizedBox(height: 4),
                          Text(
                            type,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _SectionTitle('Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms or reason for visit...',
                hintStyle:
                    GoogleFonts.inter(fontSize: 14, color: AppColors.placeholder),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 28),
            _FeeRow(fee: widget.doctor.consultationFee),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _book,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text('Confirm Appointment',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.placeholder),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _DoctorSummary extends StatelessWidget {
  const _DoctorSummary({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          DoctorAvatar(doctor: doctor, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text(doctor.specialty,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                Text(doctor.hospital,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 16),
              Text(doctor.rating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text));
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.selected, required this.onChanged});
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (_, i) {
          final date = DateTime.now().add(Duration(days: i + 1));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(selected);
          return GestureDetector(
            onTap: () => onChanged(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.text,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({
    required this.times,
    required this.selected,
    required this.onSelected,
  });
  final List<String> times;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: times.map((t) {
        final isSelected = t == selected;
        return GestureDetector(
          onTap: () => onSelected(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              t,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.text,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({required this.fee});
  final double fee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Consultation Fee',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.text)),
          Text(
            '\$${fee.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
