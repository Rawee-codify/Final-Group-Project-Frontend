import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  File? _image;
  String? _prediction;
  bool _isLoading = false;

  Future<void> _getPrediction() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST', Uri.parse("http://10.11.5.30:8080/predict"),
    );
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      setState(() => _isLoading = true);
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();

        try {
          var result = jsonDecode(responseData);
          setState(() => _prediction = "Prediction: ${result['prediction']}");
        } catch (jsonError) {
          setState(() => _prediction = "Error: Unable to parse prediction");
        }
      } else {
        setState(() => _prediction = "Prediction failed with status ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _prediction = "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color.fromARGB(255, 11, 32, 11),
      appBar: AppBar(
        title: Text("New Prediction",
        style: TextStyle(
            color:  Color.fromARGB(255, 9, 44, 11),
            fontSize: 23,
          ),
        
        ),

        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 222, 228, 223),
      ),
      body: Center( // Center widget to vertically center everything
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Centers contents without stretching
            children: [
              if (_image == null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "No image selected",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text("Select Image"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 9, 44, 11), backgroundColor: const Color.fromARGB(255, 248, 249, 249),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _getPrediction,
                icon: Icon(Icons.search),
                label: Text("Get Prediction"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 11, 68, 5),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator()
              else if (_prediction != null)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _prediction!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
