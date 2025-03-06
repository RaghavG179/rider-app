import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rider's Safety App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RiderSafetyPage(),
    );
  }
}

class RiderSafetyPage extends StatefulWidget {
  @override
  _RiderSafetyPageState createState() => _RiderSafetyPageState();
}

class _RiderSafetyPageState extends State<RiderSafetyPage> {
  final _formKey = GlobalKey<FormState>();
  final ScreenshotController screenshotController = ScreenshotController();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emergencyContactsController = TextEditingController();
  final TextEditingController medicationsController = TextEditingController();
  final TextEditingController historyController = TextEditingController();

  String? selectedBloodGroup;
  final List<String> bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _captureAndSaveScreenshot() async {
    try {
      Uint8List? image = await screenshotController.capture();
      if (image != null) {
        Directory directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/rider_safety_${DateTime.now().millisecondsSinceEpoch}.png';
        File imgFile = File(filePath);
        await imgFile.writeAsBytes(image);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Screenshot saved to ${directory.path}")),
        );
      }
    } catch (error) {
      print("Error capturing screenshot: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rider's Safety App")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Screenshot(
          controller: screenshotController,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _pickImage,
                  child: _imageFile != null
                      ? Image.file(_imageFile!, height: 150, width: 150, fit: BoxFit.cover)
                      : Container(
                    height: 150,
                    width: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.camera_alt, size: 50),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(firstNameController, "First Name"),
                const SizedBox(height: 16),
                _buildTextField(lastNameController, "Last Name"),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                  items: bloodGroups.map((String group) {
                    return DropdownMenuItem<String>(value: group, child: Text(group));
                  }).toList(),
                  onChanged: (newValue) => setState(() => selectedBloodGroup = newValue),
                ),
                const SizedBox(height: 16),
                _buildMultilineTextField(emergencyContactsController, "Emergency Contacts"),
                const SizedBox(height: 16),
                _buildMultilineTextField(medicationsController, "Medications"),
                const SizedBox(height: 16),
                _buildMultilineTextField(historyController, "History of Disease, Allergy or Injury"),
                const SizedBox(height: 16),
                const Text(
                  "PLEASE HELP BY CALLING 112 - AMBULANCE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _captureAndSaveScreenshot,
                  child: const Text("Activate Riding Mode"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }

  Widget _buildMultilineTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }
}
