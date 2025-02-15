import 'package:flutter/material.dart';

import 'AppointmentCalendarScreen.dart';
import 'MedicalInfoScreen.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeniorDashboardScreen extends StatefulWidget {
  final String seniorId;

  const SeniorDashboardScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  State<SeniorDashboardScreen> createState() => _SeniorDashboardScreenState();
}

class _SeniorDashboardScreenState extends State<SeniorDashboardScreen> {
  String seniorName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSeniorName(); // Fetch the senior's name when the screen loads
  }

  Future<void> _fetchSeniorName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('seniors')
          .doc(widget.seniorId)
          .get();

      if (doc.exists) {
        setState(() {
          seniorName = doc['fullName'] ?? 'Unknown';
          isLoading = false;
        });
      } else {
        setState(() {
          seniorName = 'Unknown';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching senior's name: $e");
      setState(() {
        seniorName = 'Unknown';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF308A99),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              seniorName, // Display the dynamically fetched name
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ProfileStat(label: "Heart rate", value: "55"),
                _ProfileStat(label: "Calories", value: "55"),
                _ProfileStat(label: "Weight", value: "55"),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _ProfileOption(
                      icon: Icons.favorite,
                      label: "My Saved",
                      onTap: () {}, // Add your navigation
                    ),
                    _ProfileOption(
                      icon: Icons.calendar_today,
                      label: "Appointment",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AppointmentCalendarScreen(seniorId: widget.seniorId),
                          ),
                        );
                      },
                    ),
                    _ProfileOption(
                      icon: Icons.payment,
                      label: "Payment Method",
                      onTap: () {}, // Add your navigation
                    ),
                    _ProfileOption(
                      icon: Icons.question_answer,
                      label: "FAQs",
                      onTap: () {}, // Add your navigation
                    ),
                    _ProfileOption(
                      icon: Icons.medical_services,
                      label: "Medical Information",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicalInfoScreen(seniorId: widget.seniorId),
                          ),
                        );
                      },
                    ),
                    _ProfileOption(
                      icon: Icons.logout,
                      label: "Logout",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout,
                                      size: 40, color: const Color(0xFF308A99)),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Are you sure to log out of your account?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LoginScreen(role: 'elderly'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF308A99),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Log Out",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      isLogout: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
      title: Text(
        label,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}