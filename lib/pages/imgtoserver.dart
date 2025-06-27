import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/material.dart';

Future<bool> uploadFile(File file, BuildContext context, String imageName) async {
  var uri = Uri.parse("https://99fa-45-116-229-28.ngrok-free.app/add_suspect");

  // Create multipart request
  var request = http.MultipartRequest('POST', uri);
  
  // Add file to request
  request.files.add(
    await http.MultipartFile.fromPath(
      'image', 
      file.path,
      filename: basename(file.path),
    ),
  );
  
  // Add image name to request - using 'name' as the field name instead of 'imageName'
  request.fields['name'] = imageName.isNotEmpty ? imageName : basename(file.path);

  // Print request details for debugging
  print("Sending request with fields: ${request.fields}");
  print("Files: ${request.files.map((f) => f.field + ': ' + f.filename!).join(', ')}");

  try {
    // Send request
    var streamedResponse = await request.send();
    
    // Get response
    var response = await http.Response.fromStream(streamedResponse);

    print("Response status code: ${response.statusCode}");
    print("Response headers: ${response.headers}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      print("File uploaded successfully");
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded to server successfully')),
        );
      }
      
      return true;
    } else {
      print("Failed to upload file. Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server upload failed: ${response.statusCode} - ${response.body}')),
        );
      }
      
      return false;
    }
  } catch (e) {
    print("Error uploading file: $e");
    
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
    }
    
    return false;
  }
}