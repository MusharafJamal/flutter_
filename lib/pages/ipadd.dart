import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


  // Fetch IP address using a public API
  Future<String?> getIPAddress() async {
    try {
      // Check if device is connected to the internet
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return null; // No internet connection
      }
      
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['ip'];
      } else {
        print('Failed to get IP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting IP address: $e');
      return null;
    }
  }

  // Get detailed location information from IP address
   Future<Map<String, dynamic>?> getLocationFromIP(String ipAddress) async {
    try {
      final response = await http.get(
        Uri.parse('https://ipapi.co/$ipAddress/json/'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get location data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting location from IP: $e');
      return null;
    }
  }

  // Get device GPS location
   Future<Position?> getCurrentGPSPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      return null;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied
      return null;
    }

    // Get current position
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
    } catch (e) {
      print('Error getting GPS position: $e');
      return null;
    }
  }

  // Convert GPS coordinates to address
   Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  // Combined function to get both IP and GPS location
   Future<Map<String, dynamic>> getDeviceLocation(BuildContext context) async {
    Map<String, dynamic> result = {
      'ipAddress': null,
      'ipLocation': null,
      'gpsCoordinates': null,
      'gpsAddress': null,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // Show loading indicator
      if (context != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }

      // Get IP address
      String? ipAddress = await getIPAddress();
      result['ipAddress'] = ipAddress;

      // Get location from IP
      if (ipAddress != null) {
        Map<String, dynamic>? ipLocationData = await getLocationFromIP(ipAddress);
        if (ipLocationData != null) {
          result['ipLocation'] = {
            'city': ipLocationData['city'],
            'region': ipLocationData['region'],
            'country': ipLocationData['country_name'],
            'postal': ipLocationData['postal'],
            'latitude': ipLocationData['latitude'],
            'longitude': ipLocationData['longitude'],
            'timezone': ipLocationData['timezone'],
            'isp': ipLocationData['org'],
          };
        }
      }

      // Get GPS position
      Position? position = await getCurrentGPSPosition();
      if (position != null) {
        result['gpsCoordinates'] = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'speedAccuracy': position.speedAccuracy,
        };

        // Get address from GPS coordinates
        String? address = await getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        result['gpsAddress'] = address;
      }

      return result;
    } catch (e) {
      print('Error in getDeviceLocation: $e');
      return result;
    } finally {
      // Close loading dialog
      if (context != null && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  
