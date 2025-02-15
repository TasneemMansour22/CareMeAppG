import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test1/screens/OnboardingScreen.dart';
import 'package:test1/screens/account_type_screen.dart';
import 'package:test1/screens/add_activity_screen.dart';
import 'package:test1/screens/MedicalProviderProfileScreen.dart';
import 'package:test1/screens/DocumentManagementScreen.dart';
import 'package:test1/screens/emergency_services.dart';
import 'package:test1/screens/home_view.dart';
import 'package:test1/screens/login_screen.dart';
import 'package:test1/screens/on_boarding_screen1.dart';
import 'package:test1/screens/register_admin_screen.dart';
import 'package:test1/screens/register_eldery_screen.dart';
import 'package:test1/screens/SocialActivitiesListScreen.dart';
import 'package:test1/screens/technical_support.dart';
import 'firebase_options.dart';
import 'screens/AddMedicalInfoScreen.dart';
import 'screens/MedicationListScreen.dart';
import 'screens/SeniorDashboardScreen.dart';
import 'screens/medical_service_providers_list.dart';
import 'screens/medical_services_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF308A99), // Change cursor color
          selectionHandleColor: Color(0xFF308A99), // Change the color of the ball
          selectionColor: Color(0x55308A99), // Optional: highlight color when selecting text
        ),
      ),

      home:OnboardingScreen(),

    );
  }
}
