import 'package:flutter/material.dart';
import 'ConsultationsScreen.dart';
import 'MedicationListScreen.dart';
import 'medical_service_providers_list.dart';

class MedicalServicesMenuScreen extends StatefulWidget {
  final String seniorId;

  const MedicalServicesMenuScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _MedicalServicesMenuScreenState createState() => _MedicalServicesMenuScreenState();
}

class _MedicalServicesMenuScreenState extends State<MedicalServicesMenuScreen> {
  int _selectedIndex = -1; // -1 means no button is selected initially

  void _onButtonPressed(int index, Widget screen) {
    setState(() {
      _selectedIndex = index;
    });

    // Delay navigation by 1 second
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 150.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/medical.png',
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Medical Services',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // Add Medicine Button
              ElevatedButton(
                onPressed: () {
                  _onButtonPressed(0, MedicationListScreen(seniorId: widget.seniorId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == 0 ? Color(0xFF308A99) : const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: BorderSide(color: _selectedIndex == 0 ? Colors.blue : const Color(0xFF308A99), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'Add Medicine',
                    style: TextStyle(fontSize: 16, color: _selectedIndex == 0 ? Colors.white : const Color(0xFF308A99)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Medical Consultation Button
              OutlinedButton(
                onPressed: () {
                  _onButtonPressed(1, ConsultationsScreen(seniorId: widget.seniorId, consultationType: 'Medical'));
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: _selectedIndex == 1 ? Color(0xFF308A99) : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: BorderSide(color: _selectedIndex == 1 ? Colors.blue : const Color(0xFF308A99), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'Medical Consultation',
                    style: TextStyle(fontSize: 16, color: _selectedIndex == 1 ? Colors.white : const Color(0xFF308A99)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Choose Medical Consultant Button
              OutlinedButton(
                onPressed: () {
                  _onButtonPressed(2, MedicalServiceProviderScreen(seniorId: widget.seniorId));
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: _selectedIndex == 2 ? Color(0xFF308A99) : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: BorderSide(color: _selectedIndex == 2 ? Colors.blue : const Color(0xFF308A99), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'Choose your medical consultant',
                    style: TextStyle(fontSize: 16, color: _selectedIndex == 2 ? Colors.white : const Color(0xFF308A99)),
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
