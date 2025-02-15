import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddConsultationScreen extends StatefulWidget {
  final String seniorId;
  final String consultationType;
  final QueryDocumentSnapshot? existingConsultation;

  AddConsultationScreen({
    required this.seniorId,
    required this.consultationType,
    this.existingConsultation,
  });

  @override
  _AddConsultationScreenState createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  String? attachedFileUrl;

  @override
  void initState() {
    super.initState();
    if (widget.existingConsultation != null) {
      _titleController.text = widget.existingConsultation!['title'] ?? '';
      _detailsController.text = widget.existingConsultation!['details'] ?? '';
      attachedFileUrl = widget.existingConsultation!['attached_document'] ?? '';
    }
  }

  Future<void> _attachDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final ref = FirebaseStorage.instance.ref().child('consultation_documents/${file.name}');
      final uploadTask = await ref.putFile(File(file.path!));
      final fileUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        attachedFileUrl = fileUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document attached successfully")));
    }
  }

  Future<void> _saveOrUpdateConsultation() async {
    if (_titleController.text.isEmpty || _detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    try {
      if (widget.existingConsultation != null) {
        await FirebaseFirestore.instance
            .collection('consultations')
            .doc(widget.existingConsultation!.id)
            .update({
          'title': _titleController.text,
          'details': _detailsController.text,
          'attached_document': attachedFileUrl ?? '',
          'updated_at': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Consultation updated successfully")),
        );
      } else {
        await FirebaseFirestore.instance.collection('consultations').add({
          'senior_id': widget.seniorId,
          'consultation_type': widget.consultationType,
          'title': _titleController.text,
          'details': _detailsController.text,
          'attached_document': attachedFileUrl ?? '',
          'created_at': Timestamp.now(),
          'status': 'Pending',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Consultation saved successfully")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.existingConsultation == null ? "Add Consultation" : "Update Consultation",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF308A99), width: 2.0),
                  ),
                ),
                cursorColor: const Color(0xFF308A99),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Details",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF308A99), width: 2.0),
                  ),
                ),
                cursorColor: const Color(0xFF308A99),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _attachDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308A99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Attach Document", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: _saveOrUpdateConsultation,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF308A99),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    widget.existingConsultation == null ? "Save Consultation" : "Update Consultation",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
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
