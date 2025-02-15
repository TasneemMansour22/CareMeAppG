import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRequestsScreen extends StatefulWidget {
  final String userId; // Logged-in service provider ID

  const MyRequestsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<Map<String, dynamic>> requestsList = [];
  List<Map<String, dynamic>> filteredRequests = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('team_requests')
          .where('user_id', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'requested')
          .get();

      List<Map<String, dynamic>> fetchedRequests = [];

      for (var doc in requestsSnapshot.docs) {
        String seniorId = doc['senior_id'];

        final seniorDoc =
        await FirebaseFirestore.instance.collection('seniors').doc(seniorId).get();

        if (seniorDoc.exists) {
          fetchedRequests.add({
            'request_id': doc.id,
            'senior_id': seniorId,
            'senior_name': seniorDoc['fullName'] ?? "Unknown Senior",
          });
        }
      }

      setState(() {
        requestsList = fetchedRequests;
        filteredRequests = fetchedRequests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading requests: $e")),
      );
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('team_requests').doc(requestId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status successfully!")),
      );

      _fetchRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating request: $e")),
      );
    }
  }

  void _filterRequests(String query) {
    setState(() {
      filteredRequests = requestsList
          .where((request) => request['senior_name']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Requests"),
        backgroundColor: const Color(0xff308A99),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterRequests,
              decoration: InputDecoration(
                labelText: "Search",
                labelStyle: const TextStyle(color: Color(0xff308A99)),
                prefixIcon: const Icon(Icons.search, color: Color(0xff308A99)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                ? const Center(child: Text("No new requests."))
                : ListView.builder(
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(request['senior_name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () =>
                              _updateRequestStatus(request['request_id'], "accepted"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                          child: const Text("Accept"),
                        ),
                        TextButton(
                          onPressed: () =>
                              _updateRequestStatus(request['request_id'], "rejected"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
