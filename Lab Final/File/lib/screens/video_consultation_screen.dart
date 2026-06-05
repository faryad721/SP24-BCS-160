import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/doctor.dart';
import '../theme/colors.dart';

class VideoConsultationScreen extends StatefulWidget {
  const VideoConsultationScreen({super.key, required this.doctor});
  final Doctor doctor;

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen>
    with TickerProviderStateMixin {
  bool _isConnecting = true;
  bool _inCall = false;
  bool _micOn = true;
  bool _cameraOn = true;
  bool _speakerOn = true;
  bool _isFrontCamera = true;
  bool _showControls = true;
  int _callDuration = 0;
  Timer? _timer;
  Timer? _connectTimer;
  Timer? _hideControlsTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startConnecting();
  }

  void _startConnecting() {
    _connectTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _inCall = true;
      });
      _startCallTimer();
      _scheduleHideControls();
    });
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _callDuration++);
    });
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHideControls();
  }

  String get _durationStr {
    final m = _callDuration ~/ 60;
    final s = _callDuration % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _endCall() async {
    _timer?.cancel();
    _connectTimer?.cancel();
    _hideControlsTimer?.cancel();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectTimer?.cancel();
    _hideControlsTimer?.cancel();
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _inCall ? _toggleControls : null,
        child: Stack(
          children: [
            _RemoteVideoArea(
              doctor: widget.doctor,
              isConnecting: _isConnecting,
              pulseController: _pulseController,
            ),
            if (_inCall) _LocalVideoPreview(isFront: _isFrontCamera),
            AnimatedOpacity(
              opacity: _showControls || !_inCall || _isConnecting ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  _TopBar(
                    doctorName: widget.doctor.name,
                    specialty: widget.doctor.specialty,
                    isConnecting: _isConnecting,
                    inCall: _inCall,
                    duration: _durationStr,
                    onBack: _endCall,
                  ),
                  const Spacer(),
                  if (_inCall)
                    _ControlBar(
                      micOn: _micOn,
                      cameraOn: _cameraOn,
                      speakerOn: _speakerOn,
                      onMic: () => setState(() => _micOn = !_micOn),
                      onCamera: () => setState(() => _cameraOn = !_cameraOn),
                      onSpeaker: () => setState(() => _speakerOn = !_speakerOn),
                      onFlip: () => setState(() => _isFrontCamera = !_isFrontCamera),
                      onEnd: _endCall,
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoteVideoArea extends StatelessWidget {
  const _RemoteVideoArea({
    required this.doctor,
    required this.isConnecting,
    required this.pulseController,
  });
  final Doctor doctor;
  final bool isConnecting;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final initial = doctor.name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1B2B3B), Color(0xFF0A2540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, child) {
                final scale = isConnecting
                    ? 1.0 + 0.06 * (0.5 + 0.5 * pulseController.value)
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.5), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              doctor.name,
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialty,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
            ),
            if (isConnecting) ...[
              const SizedBox(height: 24),
              Text('Connecting...',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 12),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white54, strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocalVideoPreview extends StatelessWidget {
  const _LocalVideoPreview({required this.isFront});
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      right: 16,
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: const Color(0xFF243447),
                child: const Icon(Icons.person, size: 40, color: Colors.white38),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isFront ? Icons.camera_front : Icons.camera_rear,
                    size: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.doctorName,
    required this.specialty,
    required this.isConnecting,
    required this.inCall,
    required this.duration,
    required this.onBack,
  });
  final String doctorName;
  final String specialty;
  final bool isConnecting;
  final bool inCall;
  final String duration;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctorName,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(
                    inCall && !isConnecting ? duration : specialty,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: inCall && !isConnecting
                            ? const Color(0xFF69F0AE)
                            : Colors.white60),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _TopBtn(icon: Icons.signal_cellular_alt, color: Colors.white70),
                const SizedBox(width: 4),
                _TopBtn(icon: Icons.wifi, color: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBtn extends StatelessWidget {
  const _TopBtn({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.micOn,
    required this.cameraOn,
    required this.speakerOn,
    required this.onMic,
    required this.onCamera,
    required this.onSpeaker,
    required this.onFlip,
    required this.onEnd,
  });
  final bool micOn;
  final bool cameraOn;
  final bool speakerOn;
  final VoidCallback onMic;
  final VoidCallback onCamera;
  final VoidCallback onSpeaker;
  final VoidCallback onFlip;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CtrlBtn(
            icon: micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            label: micOn ? 'Mute' : 'Unmute',
            active: micOn,
            onTap: onMic,
          ),
          _CtrlBtn(
            icon: cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
            label: cameraOn ? 'Camera' : 'No Cam',
            active: cameraOn,
            onTap: onCamera,
          ),
          GestureDetector(
            onTap: onEnd,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFE53935).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
            ),
          ),
          _CtrlBtn(
            icon: speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            label: 'Speaker',
            active: speakerOn,
            onTap: onSpeaker,
          ),
          _CtrlBtn(
            icon: Icons.flip_camera_ios_rounded,
            label: 'Flip',
            active: true,
            onTap: onFlip,
          ),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: active ? Colors.white.withOpacity(0.15) : Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon,
                color: active ? Colors.white : Colors.white54, size: 22),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}
