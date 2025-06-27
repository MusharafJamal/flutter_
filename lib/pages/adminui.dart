import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/api_call.dart';
import 'package:flutter_application_3/services/notification_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/pages/imgtoserver.dart';
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

  // List to store notifications
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoadingNotifications = false;

  @override
  void initState() {
    super.initState();
    // Fetch notifications when the page loads
    _fetchNotifications();
  }

  // Method to fetch notifications from Firestore
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      // Fetch notifications from Firestore
      log("Getting notifications");
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      setState(() {
        _notifications = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': (doc.data() as Map<String, dynamic>)['title'] ??
                      'suspect founded',
                  'message': (doc.data() as Map<String, dynamic>)['message'] ??
                      'No message',
                  'timestamp':
                      (doc.data() as Map<String, dynamic>)['timestamp'] ??
                          Timestamp.now(),
                  'read': (doc.data() as Map<String, dynamic>)['read'] ?? false,
                })
            .toList();
      });

      log(_notifications.toString());
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  // Method to show notifications panel
  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet expand to half screen
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5, // Makes it half screen
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _fetchNotifications,
                    ),
                  ],
                ),
              ),
              Divider(),
              // Notifications list
              Expanded(
                child: _isLoadingNotifications
                    ? Center(child: CircularProgressIndicator())
                    : _notifications.isEmpty
                        ? Center(child: Text('No notifications yet'))
                        : ListView.builder(
                            controller: controller,
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              final timestamp =
                                  notification['timestamp'] as Timestamp;
                              final date = timestamp.toDate();

                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: notification['read']
                                      ? Colors.white
                                      : Colors.green[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF254117),
                                    child: Icon(Icons.notification_important,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    notification['title'],
                                    style: TextStyle(
                                      fontWeight: notification['read']
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(notification['message']),
                                      SizedBox(height: 4),
                                      Text(
                                        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    // Mark as read when tapped
                                    await FirebaseFirestore.instance
                                        .collection('notifications')
                                        .doc(notification['id'])
                                        .update({'read': true});
                                    _fetchNotifications();
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageName = image.name;
        //String imageName = path.basename(_selectedImage);
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
    addSuspect(_selectedImage!.path, _imageName!);
    //uploadFile(_selectedImage!, context,_imageName!);
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
      // In your _sendImage() method
      //bool serverUploadSuccess = await uploadFile(_selectedImage!, context);

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
                    onPressed: _showNotificationsPanel,
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
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                      )),
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
