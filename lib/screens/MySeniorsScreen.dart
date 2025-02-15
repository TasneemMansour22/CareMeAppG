import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MySeniorsScreen extends StatefulWidget {
  final String userId;

  const MySeniorsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MySeniorsScreenState createState() => _MySeniorsScreenState();
}

class _MySeniorsScreenState extends State<MySeniorsScreen> {
  List<Map<String, dynamic>> seniorsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSeniors();
  }

  Future<void> _fetchSeniors() async {
    try {
      final seniorsSnapshot = await FirebaseFirestore.instance
          .collection('team_requests')
          .where('user_id', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'accepted') // Only assigned seniors
          .get();

      List<Map<String, dynamic>> fetchedSeniors = [];

      for (var doc in seniorsSnapshot.docs) {
        String seniorId = doc['senior_id'];

        // Fetch senior details from seniors collection
        final seniorDoc = await FirebaseFirestore.instance.collection('seniors').doc(seniorId).get();

        if (seniorDoc.exists) {
          fetchedSeniors.add({
            'senior_id': seniorId,
            'senior_name': seniorDoc.data()?['fullName'] ?? "Unknown Senior",
          });
        }
      }

      setState(() {
        seniorsList = fetchedSeniors;
        isLoading = false;
      });

      print("Fetched Seniors: $seniorsList"); // Debugging log
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading seniors: $e")),
      );
    }
  }

  void _navigateToSeniorProfile(String seniorId) {
    // Navigate to Senior Profile Screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Navigating to Senior Profile: $seniorId")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Seniors"),
        backgroundColor: const Color(0xff308A99),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : seniorsList.isEmpty
          ? const Center(child: Text("No seniors assigned yet."))
          : ListView.builder(
        itemCount: seniorsList.length,
        itemBuilder: (context, index) {
          final senior = seniorsList[index];
          return ListTile(
            title: Text(senior['senior_name']),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () => _navigateToSeniorProfile(senior['senior_id']),
          );
        },
      ),
    );
  }
}
