import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  final String userId;

  const ServiceProviderProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ServiceProviderProfileScreenState createState() => _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState extends State<ServiceProviderProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('other_users').doc(widget.userId).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xff308A99),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to Edit Profile Screen (to be implemented)
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text("User not found"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: userData!["profile_image"] != null
                  ? NetworkImage(userData!["profile_image"])
                  : const AssetImage("assets/default_avatar.png") as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              userData!["fullName"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Role: ${userData!["role"]}",
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.teal),
              title: Text(userData!["email"]),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.teal),
              title: Text(userData!["phone"]),
            ),
            if (userData!["description"] != null && userData!["description"].isNotEmpty)
              ListTile(
                leading: const Icon(Icons.info, color: Colors.teal),
                title: Text(userData!["description"]),
              ),
          ],
        ),
      ),
    );
  }
}
