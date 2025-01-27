import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Adminui extends StatefulWidget {
  const Adminui({super.key});

  @override
  _AdminuiState createState() => _AdminuiState();
}

class _AdminuiState extends State<Adminui> {
  File? _selectedImage;
  String? _imageName;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageName = image.name;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageName = null;
    });
  }

  Future<void> _sendImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
          'suspect_images/${DateTime.now().millisecondsSinceEpoch}_${_imageName?.substring(0, 20)}');
          

      // Upload the image
      await storageRef.putFile(_selectedImage!);

      // Get the download URL
      final downloadURL = await storageRef.getDownloadURL();

      // Save image metadata to Firestore
      await FirebaseFirestore.instance.collection('suspect_images').add({
        'imageUrl': downloadURL,
        'imageName': _imageName,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      // Reset image selection
      setState(() {
        _selectedImage = null;
        _imageName = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(177, 236, 111, 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: const Alignment(-0.7, -0.3),
                child: Text(
                  "TRACE\nTECH.",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.black,
                        height: 0.9,
                        fontSize: 70,
                      ),
                ),
              ),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10,),
                      Expanded(
                        child:Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                         child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Color.fromRGBO(21, 70, 24, 1),
                          ),
                          height: 50,
                          child: Row(
                            children: [
                              
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      'Image: $_imageName',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _removeImage,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        )
                        
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(21, 70, 24, 1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: _isUploading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : IconButton(
                                  onPressed: _sendImage,
                                  icon: const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 30,
                                    weight: 6,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF254117),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 60,
                      weight: 50,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}