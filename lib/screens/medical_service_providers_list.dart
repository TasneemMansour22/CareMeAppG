import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'MedicalProviderProfileScreen.dart';

class MedicalServiceProviderScreen extends StatefulWidget {
  final String seniorId; // Senior ID to link the booking.

  const MedicalServiceProviderScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _MedicalServiceProviderScreenState createState() => _MedicalServiceProviderScreenState();
}

class _MedicalServiceProviderScreenState extends State<MedicalServiceProviderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _currentProviderId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentProvider();
  }

  Future<void> _fetchCurrentProvider() async {
    final snapshot = await _firestore
        .collection('team_requests')
        .where('senior_id', isEqualTo: widget.seniorId)
        .where('status', isEqualTo: 'accepted')
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _currentProviderId = snapshot.docs.first['user_id'];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMedicalProviders() async {
    final providersSnapshot = await _firestore
        .collection('other_users')
        .where('role', isEqualTo: 'medical')
        .get();

    final requestsSnapshot = await _firestore
        .collection('team_requests')
        .where('senior_id', isEqualTo: widget.seniorId)
        .get();

    // Check if a "Requested" provider exists
    String? requestedProviderId;
    String? requestedStatus;
    if (requestsSnapshot.docs.isNotEmpty) {
      final currentRequest = requestsSnapshot.docs.first.data();
      requestedProviderId = currentRequest['user_id'];
      requestedStatus = currentRequest['status'];
    }

    // Map providers and set status
    return providersSnapshot.docs.map((doc) {
      final provider = doc.data();
      provider['isRequested'] = doc.id == requestedProviderId;
      provider['requestStatus'] = doc.id == requestedProviderId ? requestedStatus : null;
      provider['user_id'] = doc.id; // Include provider's ID
      return provider;
    }).toList();
  }



  void _bookProvider(String providerId, String providerName) async {
    try {
      final existingRequestSnapshot = await _firestore
          .collection('team_requests')
          .where('senior_id', isEqualTo: widget.seniorId)
          .where('status', whereIn: ['requested', 'accepted'])
          .get();

      if (existingRequestSnapshot.docs.isNotEmpty) {
        final existingProviderName = existingRequestSnapshot.docs.first['user_name'];
        _showWarningDialog(
            'Request Denied',
            'You are already in contact with $existingProviderName. '
                'Cancel the current request to choose another provider.');
        return;
      }

      await _firestore.collection('team_requests').add({
        'senior_id': widget.seniorId,
        'user_id': providerId,
        'user_name': providerName,
        'status': 'requested',
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have requested $providerName successfully!')),
      );

      setState(() {
        _fetchCurrentProvider();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking provider: $e')),
      );
    }
  }

  void _showWarningDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                style: TextStyle(color:Color(0xFF308A99), ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Service Providers"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchMedicalProviders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final providers = snapshot.data ?? [];

                  final filteredProviders = providers.where((provider) {
                    final name = (provider['fullName'] ?? '').toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

// Sort so the "Requested" provider appears first
                  filteredProviders.sort((a, b) {
                    if (a['isRequested'] == true && b['isRequested'] != true) return -1;
                    if (b['isRequested'] == true && a['isRequested'] != true) return 1;
                    return 0; // Maintain the default order otherwise
                  });


                  if (filteredProviders.isEmpty) {
                    return const Center(
                      child: Text('No medical service providers found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      final provider = filteredProviders[index];
                      final isRequested = provider['isRequested'] ?? false;
                      final requestStatus = provider['requestStatus'] ?? null;

                      return Column(
                        children: [
                          if (index == 0 && requestStatus == 'requested')
                            const Divider(thickness: 1.5, color: Colors.grey),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child:
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicalProviderProfileScreen(provider: provider),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage: provider['profile_picture'] != null
                                    ? NetworkImage(provider['profile_picture'])
                                    : null,
                                child: provider['profile_picture'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(provider['fullName'] ?? 'Unknown'),
                              trailing: ElevatedButton(
                                onPressed: provider['isRequested']
                                    ? null // Disable the button for requested/accepted states
                                    : () => _bookProvider(provider['user_id'], provider['fullName']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: provider['isRequested']
                                      ? (provider['requestStatus'] == 'accepted'
                                      ? Colors.green // Green for "Accepted"
                                      : Colors.grey) // Grey for "Requested"
                                      : const Color(0xFF308A99), // Teal for "Request Now"
                                ),
                                child: Text(
                                  provider['isRequested']
                                      ? (provider['requestStatus'] == 'accepted' ? "Accepted" : "Requested")
                                      : "Request Now",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                          ),
                          if (index == 0 && requestStatus == 'requested')
                            const Divider(thickness: 1.5, color: Colors.grey),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
