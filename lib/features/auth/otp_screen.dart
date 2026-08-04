import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';
import 'auth_provider.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  void _verify() async {
    String smsCode = _otpController.text.trim();
    if (smsCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter full 6-digit OTP code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await ref.read(authControllerProvider).verifyOTP(
      verificationId: widget.verificationId,
      smsCode: smsCode,
      onError: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );

    if (success && mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter 6-digit Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Code sent to ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verify & Complete',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
