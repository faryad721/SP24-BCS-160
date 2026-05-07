import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/submission.dart';

class FormView extends StatefulWidget {
  final Submission? submission;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const FormView({super.key, this.submission, required this.onSuccess, required this.onCancel});

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'Male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.submission != null) {
      _nameController.text = widget.submission!.fullName;
      _emailController.text = widget.submission!.email;
      _phoneController.text = widget.submission!.phoneNumber;
      _addressController.text = widget.submission!.address;
      _gender = widget.submission!.gender;
    }
  }

  @override
  void didUpdateWidget(FormView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.submission != oldWidget.submission) {
      if (widget.submission != null) {
        _nameController.text = widget.submission!.fullName;
        _emailController.text = widget.submission!.email;
        _phoneController.text = widget.submission!.phoneNumber;
        _addressController.text = widget.submission!.address;
        _gender = widget.submission!.gender;
      } else {
        _clearFields();
      }
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() => _gender = 'Male');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final data = {
        'full_name': _nameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'address': _addressController.text,
        'gender': _gender,
      };

      if (widget.submission != null) {
        await supabase.from('submissions').update(data).eq('id', widget.submission!.id!);
      } else {
        await supabase.from('submissions').insert(data);
      }

      _clearFields();
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Operation Successful!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('INPUT CONTROL', style: TextStyle(color: Color(0xFF0EA5E9), letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 9)),
            const SizedBox(height: 4),
            Text(widget.submission == null ? 'Submission Form' : 'Modify Record', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 32),
            _buildField('Full Name', _nameController, LucideIcons.user),
            const SizedBox(height: 16),
            _buildField('Email Address', _emailController, LucideIcons.mail, isEmail: true),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  return Column(
                    children: [
                      _buildField('Phone Number', _phoneController, LucideIcons.phone),
                      const SizedBox(height: 16),
                      _buildGenderDropdown(),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildField('Phone', _phoneController, LucideIcons.phone)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildGenderDropdown()),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _buildField('Address', _addressController, LucideIcons.mapPin, maxLines: 3, placeholder: 'Resident Address...'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.black,
                  elevation: 8,
                  shadowColor: const Color(0xFF0EA5E9).withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                  : Text(widget.submission == null ? 'SAVE SUBMISSION' : 'UPDATE RECORD', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13)),
              ),
            ),
            if (widget.submission != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: widget.onCancel, 
                  child: const Text('CANCEL OPERATION', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isEmail = false, int maxLines = 1, String? placeholder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Colors.grey.shade600, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: Icon(icon, size: 16, color: Colors.grey.shade500),
            hintText: placeholder ?? 'Enter ${label.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade800)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade800)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
            errorStyle: const TextStyle(height: 0),
          ),
          validator: (v) => v!.isEmpty ? '' : null,
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GENDER', style: TextStyle(color: Colors.grey.shade600, fontSize: 9, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 14, color: Colors.grey),
              dropdownColor: const Color(0xFF0F172A),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFFE2E8F0))));
              }).toList(),
              onChanged: (v) => setState(() => _gender = v!),
            ),
          ),
        ),
      ],
    );
  }
}
