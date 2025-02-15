import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalInfoScreen extends StatefulWidget {
  final String seniorId;

  const MedicalInfoScreen({Key? key, required this.seniorId})
      : super(key: key);

  @override
  _MedicalInfoScreenState createState() =>
      _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _bloodTypeController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _allergiesController = TextEditingController();
  TextEditingController _illnessesController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;

  Future<void> _fetchMedicalData() async {
    try {
      final doc = await _firestore
          .collection('Medical_data')
          .doc(widget.seniorId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        _bloodTypeController.text = data?['blood_type'] ?? '';
        _heightController.text = data?['height']?.toString() ?? '';
        _weightController.text = data?['weight']?.toString() ?? '';
        _allergiesController.text = data?['allergies'] ?? '';
        _illnessesController.text = data?['illnesses'] ?? '';
        _notesController.text = data?['notes'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMedicalData() async {
    try {
      await _firestore.collection('Medical_data').doc(widget.seniorId).set({
        'blood_type': _bloodTypeController.text,
        'height': int.tryParse(_heightController.text),
        'weight': int.tryParse(_weightController.text),
        'allergies': _allergiesController.text,
        'illnesses': _illnessesController.text,
        'notes': _notesController.text,
        'updated_at': DateTime.now(),
        'senior_id': widget.seniorId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medical information updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Blood Type', _bloodTypeController),
            _buildTextField('Height (cm)', _heightController, keyboardType: TextInputType.number),
            _buildTextField('Weight (kg)', _weightController, keyboardType: TextInputType.number),
            _buildTextField('Allergies', _allergiesController),
            _buildTextField('Illnesses', _illnessesController),
            _buildTextField('Notes', _notesController, maxLines: 3),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveMedicalData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308A99), // App color
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Information',
                  style: TextStyle(color: Colors.white),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF308A99)), // App color
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99), width: 2), // App color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99), width: 1.5), // App color
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99)), // App color
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
