import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/login_page.dart';
import 'screens/public_home.dart';
import 'screens/officer_field.dart';
import 'screens/officer_jreng.dart';
import 'screens/officer_commissioner.dart';
import 'screens/lifting_page.dart';
import 'screens/pumping_page.dart';
import 'screens/stp_page.dart';
import 'screens/admin_dashboard.dart';
import 'screens/otp_page.dart';
import 'screens/complaint_form.dart';
import 'screens/complaint_status.dart';

const String baseUrl = "http://192.168.31.100:3000";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Civil Project',
      theme: ThemeData(primarySwatch: Colors.indigo),
      // Remove "/otp" from fixed routes and handle it via onGenerateRoute to pass argument
      routes: {
        "/publicHome": (_) => const PublicHome(),
        "/complaintForm": (_) => ComplaintForm(),
        "/complaintStatus": (_) => const ComplaintStatus(),
        "/officerField": (_) => const OfficerField(),
        "/officerJrEng": (_) => const OfficerJrEng(),
        "/officerCommissioner": (_) => const OfficerCommissioner(),
        "/lifting": (_) => const LiftingPage(),
        "/pumping": (_) => const PumpingPage(),
        "/stp": (_) => const StpPage(),
        "/adminDashboard": (_) => const AdminDashboard(),
      },
      onGenerateRoute: (settings) {
        // Handle OTP route with required phoneNumber argument
        if (settings.name == '/otp') {
          final phoneNumber = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => OtpPage(phoneNumber: phoneNumber),
          );
        }
        // Return null for other unknown routes
        return null;
      },
      home: const LoginPage(),
    );
  }
}
