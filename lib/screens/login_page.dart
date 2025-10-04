// login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _getOtp() {
    String phone = _phoneController.text.trim();
    String normalizedPhone = "";
    if (phone.startsWith("+91") && phone.length == 13) {
      normalizedPhone = phone;
    } else if (phone.startsWith("91") && phone.length == 12) {
      normalizedPhone = "+$phone";
    } else if (phone.length == 10) {
      normalizedPhone = "+91$phone";
    }
    if (normalizedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid Indian phone number")));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => OtpPage(phoneNumber: normalizedPhone)));
  }

  Future<void> _officerLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username and password cannot be empty")));
      return;
    }
    setState(() => _isLoading = true);

    // MOCK: Replace below with actual Firebase Email/Password auth and role retrieval
    final rolesMap = {
      "fieldofficer@office.com": "fieldofficer",
      "juniorengineer@office.com": "juniorengineer",
      "commissioner@office.com": "commissioner",
      "lifting1@work.com": "lifting",
      "lifting2@work.com": "lifting",
      "lifting3@work.com": "lifting",
      "lifting4@work.com": "lifting",
      "pumping1@work.com": "pumping",
      "pumping2@work.com": "pumping",
      "pumping3@work.com": "pumping",
      "stp1@work.com": "stp",
      "stp2@work.com": "stp",
      "admin@all.com": "admin",
    };

    final passwordsMap = {
      "fieldofficer@office.com": "fieldpass",
      "juniorengineer@office.com": "juniorpass",
      "commissioner@office.com": "compass",
      "lifting1@work.com": "liftpass1",
      "lifting2@work.com": "liftpass2",
      "lifting3@work.com": "liftpass3",
      "lifting4@work.com": "liftpass4",
      "pumping1@work.com": "pumppass1",
      "pumping2@work.com": "pumppass2",
      "pumping3@work.com": "pumppass3",
      "stp1@work.com": "stppass1",
      "stp2@work.com": "stppass2",
      "admin@all.com": "adminpass",
    };

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Simulate authentication check
    if (passwordsMap[username] == password) {
      String role = rolesMap[username] ?? "";
      setState(() => _isLoading = false);
      switch (role) {
        case "fieldofficer":
          Navigator.pushReplacementNamed(context, "/officerField");
          break;
        case "juniorengineer":
          Navigator.pushReplacementNamed(context, "/officerJrEng");
          break;
        case "commissioner":
          Navigator.pushReplacementNamed(context, "/officerCommissioner");
          break;
        case "lifting":
          Navigator.pushReplacementNamed(context, "/lifting");
          break;
        case "pumping":
          Navigator.pushReplacementNamed(context, "/pumping");
          break;
        case "stp":
          Navigator.pushReplacementNamed(context, "/stp");
          break;
        case "admin":
          Navigator.pushReplacementNamed(context, "/adminDashboard");
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unknown role")));
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid username or password")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.indigo.shade400], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Public Login Section
              const Text("Login for Public", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                  hintText: "+91 xxxxxxxxxx",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.indigo.shade700,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getOtp,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Get OTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.white70, thickness: 1),
              const SizedBox(height: 30),
              // Officer Login Section
              const Text("Login for Officers", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  hintText: "Username",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.indigo.shade700,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.indigo.shade700,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    onPressed: _isLoading ? null : _officerLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 8),
                    child: _isLoading ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.indigo)) : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
