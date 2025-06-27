import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/main.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final serviceAccountJson = {
  "type": "service_account",
  "project_id": "trace-86ab3",
  "private_key_id": "2933c2772796b2199f01acbe25526e7300fd60e8",
  "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDe1vsukrg+W84N\nx4zfcvb3yViglYteA10mQtT1qV/6kgjrdR247WsDDU6eqTr7yowCcIDtN4C7x1Ti\nRsu/kHE1ZqFEdMBP4110ozjO6PT1GGmqeyXR9U8XT9OCa4/Pc2Ih45edp0OrBKDB\n7ibqMfebGy+wuJquRjo15ClaOqItfpJDt0rCOnNUo2xbaa657UUoadytSZD+IqlD\n6nyawR4Zd9ZL8/ArArvfq8ZRIZcw+I3ytYIipXuj606pFQ2oCwrEUzNp1LyjdrfA\nzYpBYMHSSET2fw6RXHTEyNJQUWy+DvBhOb5nyf2eyyXW+68NNlsehs30/xcCMjyU\nIV8YDTXPAgMBAAECggEAIfi2LEBz1BXc0N72C+6T1eydFUYXDAsJPVb87kKW/jUb\nJQIiuNmA8eMqdCeqdU5Ij+qkzQUkG/xkZWaTky2rBJATz8LYupUX3zsu4uRCy8af\n/Txu5JY4K36g6QYK035snGv85izktQKsm0P6LMPXUo8PcyqBckYEg8i3wSilJrgX\nMiAY0UqtXmv42FimAUfgCwjYmNckQLpDLIocJGGBg2qhD6gelS7J2qFznU/AHEBe\nwENruwA9iXlYaG2SMXAhZvMi2B7H+C6N8uJ5c7Eoq35AbIMIBKCeM4rfzrhdewm3\nC95ODOZfWK1zFuz7SPKG7SkUsirf+yS6Bcfv8PJs+QKBgQDxekGqYZj91NTEckZn\n8Pjtz/Y+6FJQ/Lwli3MxGMAQIG6haUuYPGw/RcdmbNqXOjuyxyB88+LW0FKjSXDZ\nDShh5opl57/R04eORSxjvKvEEvzJhCD7XfMXJqvr6hKCSKS3Ir2njge2K+3Xgu2p\niDUQ44IvAAPHT5FNRLnXBaJsZQKBgQDsPcfaMuF/7OA5+seJdT86pmZaXPfwgB5w\ne5QNW/0PYlFForKjSBr0/j/x8wBSFe8uBNx7rbKdm7CauXNnPGelvP+qwbafQDN4\nQzjoQAWD5JQTEIBYVzDR6qWkLJbmegw131zod7bYS2kCRPyRHaV8W3TnpKoVGOxj\n9X5/NZaUIwKBgEGBOqLvisMAox8PKM41bjGEwnXaK8pQZPGCXKMq5Z76TUh3+cu4\nSFz5ntfIG5v+bgdXQRbkSdqf9GrbF0Op8BRup4hxT3Wp/hG37gy4N5ge1ngL4a6O\nk8zp7qU2gALbleMgB3aWbr0aOZDGsZXVnx+Pt9bsGBpPGUlupUMRAjiJAoGBAIAI\nI43P0YKBICyMCyQmFPR2RjZm+ECxTs3rS5vJ5OY3hJBW0rXHWES6nnFEH0JdfNjV\n7aBhzNG6FQZlx3OFuy6JtY4Xmh/IrZxZ4jeMqvCGKvICGWzHJEBACTFmsQmLz55K\nxZF/f+rNQ8XlGXSUOqGg90Srazov3b12yO2sX0U9AoGAX+ySo1f5VsIPh+PDOP6o\npeBeRPH53hj8cXXCGahQgB3/L7kFzea4T2rx0pSWvWUsha3Tb4a6tg4m5StciF4X\neMmdb0TYZKYTtnCy5WSKp1cXofttSFf6B9e/SQEt7NWu0dj3GBWjW7rGEuFvPgLi\nXdSAzwF6uLZ9TKItvxPfpyA=\n-----END PRIVATE KEY-----\n",
  "client_email": "trace-743@trace-86ab3.iam.gserviceaccount.com",
  "client_id": "104083703071685727609",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/trace-743%40trace-86ab3.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};

class NotificationServices {
  static Future<String> getAccessToken() async {
    List<String> scopes = [
      // "https://www.googleapis.com/auth/userinfo.email",16,22,24,29
      // "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    // http.Client client = await auth.clientVia
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  static sendNotificationToAdmin(String deviceToken) async {
    log("sending notification");
    final String serverKey = await getAccessToken();
    String endPointFirebaseCloudMessaging =
        "https://fcm.googleapis.com/v1/projects/trace-86ab3/messages:send";

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "Suspect found!",
          'body': "on ip adrress $ipAdrress ,palakkad",
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endPointFirebaseCloudMessaging),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey'
      },
      body: jsonEncode(message),
    );

    storeNotificationToDatabase(
        title: "Suspect found!",
        message: "on ip address $ipAdrress palakkad");

    log(response.statusCode.toString());
  }

  static Future<bool> storeNotificationToDatabase({
    required String title,
    required String message,
    String? ipAddress,
    String? location,
    Map<String, dynamic>? additionalData,
    String? suspectId,
  }) async {
    try {
      // Get reference to Firestore collection
      final notificationsCollection =
          FirebaseFirestore.instance.collection('notifications');

      // Create notification data
      final Map<String, dynamic> notificationData = {
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        
      };

      // Add optional fields if provided
      if (ipAddress != null) {
        notificationData['ipAddress'] = ipAddress;
      }

      if (location != null) {
        notificationData['location'] = location;
      }

      if (suspectId != null) {
        notificationData['suspectId'] = suspectId;
      }

      // Add any additional data
      if (additionalData != null) {
        notificationData.addAll(additionalData);
      }

      // Add to Firestore
      await notificationsCollection.add(notificationData);

      print('Notification stored successfully to database');
      return true;
    } catch (e) {
      print('Error storing notification to database: $e');
      return false;
    }
  }
}
