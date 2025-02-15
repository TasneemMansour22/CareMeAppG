import 'package:flutter/material.dart';

class EmergencyServicesScreen extends StatelessWidget {
  final List<Map<String, String>> services = [
    {
      'title': 'Ambulance service',
      'description':
      'Service for transporting patients and wounded to hospitals and medical centers to receive the necessary treatment.',
      'icon': 'assets/ambulance.png',
    },
    {
      'title': 'Fire service',
      'description':
      'It is a firefighting service that protects lives and property from fire damage.',
      'icon': 'assets/fire_truck.png',
    },
    {
      'title': 'Police service',
      'description':
      'This is the service of maintaining security and public order, investigating crimes, and arresting criminals.',
      'icon': 'assets/police_car.png',
    },
    {
      'title': 'Police service',
      'description':
      'This is the service of maintaining security and public order, investigating crimes, and arresting criminals.',
      'icon': 'assets/police_car.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('emergency services'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'The closest places to you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(service['icon']!),
                        radius: 24,
                      ),
                      title: Text(
                        service['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        service['description']!,
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Implement call functionality
                        },
                        child: const Text('Call now'),
                      ),
                    ),
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
