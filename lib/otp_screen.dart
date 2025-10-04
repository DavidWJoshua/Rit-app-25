// lib/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final VoidCallback onVerified;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.onVerified,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isVerifying = false;

  Future<void> verifyOtp() async {
    final smsCode = otpController.text.trim();
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit OTP')));
      return;
    }

    setState(() => isVerifying = true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(cred);
      widget.onVerified();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP verify failed: $e')));
    } finally {
      setState(() => isVerifying = false);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Enter OTP sent to ${widget.phoneNumber}'),
            const SizedBox(height: 12),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '6-digit OTP'),
            ),
            const SizedBox(height: 12),
            isVerifying
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: verifyOtp, child: const Text('Verify OTP')),
          ],
        ),
      ),
    );
  }
}
