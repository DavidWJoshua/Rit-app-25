import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_screen.dart';
import 'public.dart'; // Import PublicDashboard

class PhoneAuthScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;

  const PhoneAuthScreen({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
  });

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    sendOtp(); // Automatically send OTP when screen opens
  }

  void sendOtp() async {
    setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification (rare)
        await FirebaseAuth.instance.signInWithCredential(credential);
        // Navigate to PublicDashboard after auto verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PublicDashboard()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => isLoading = false);

        // Navigate to OTP screen with verificationId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              verificationId: verificationId,
              phoneNumber: widget.phoneNumber,
              onVerified: () {
                // Navigate to PublicDashboard after successful OTP verification
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PublicDashboard()),
                );
              },
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Auth")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text("Sending OTP to ${widget.phoneNumber}"),
      ),
    );
  }
}
