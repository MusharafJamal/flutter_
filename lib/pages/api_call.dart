import 'dart:developer';
import 'dart:io';
import 'package:flutter_application_3/services/notification_services.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

Future<void> uploadVideo(File videoFile, String deviceName) async {
  final dioClient = Dio(
    BaseOptions(
      connectTimeout: Duration(minutes: 6),
      receiveTimeout: Duration(minutes: 6),
    ),
  );

  const url =
      'https://99fa-45-116-229-28.ngrok-free.app/upload_video';

  try {
    log("Uploading video..... ${videoFile.path}");

    // Ensure file exists
    if (!videoFile.existsSync()) {
      print("Error: Video file not found at ${videoFile.path}");
      return;
    }

    // Determine MIME type (default to video/mp4 if unknown)
    final mimeType = lookupMimeType(videoFile.path) ?? 'video/mp4';
    log("Mimetype : $mimeType");

    // Create FormData with the File
    FormData formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(
        videoFile.path,
        filename: videoFile.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
      'device': deviceName,
    });

    log("Sending request to $url...");
    Response response = await dioClient.post(
      url,
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    if (response.statusCode == 200) {
      log("Analysis successful");
      log("Response Data: ${response.data}");
      if (response.data['suspects_detected'].length != 0) {
        NotificationServices.sendNotificationToAdmin(
            "cnG2XmanQCK39irxO-zGBG:APA91bEHWXkR6S6H5ZiVx5kuiY5SFKQwpRXQGo_hrR6cqoNfsyFOH3t-J-_2oMuxlUGAkE0nOxy5sp62pVe4nnYw2AGOB0M4-ZfcAqEOJ7bSYf8Q-_fIFmQ");
      }
    } else {
      log("Server error: ${response.statusCode} - ${response.statusMessage}");
    }
  } on DioException catch (e) {
    log("Dio error: ${e.response?.statusCode} - ${e.message}");
  } on SocketException {
    log("No internet connection");
  } on FormatException {
    log("Bad response format");
  } catch (e) {
    log("Unexpected error: $e");
  }
}

// Future<void> uploadVideo(String videoFilePath, String deviceName) async {
//   // final dioClient = Dio();
//   final dioClient = Dio(
//     BaseOptions(
//       // baseUrl: "http://192.168.1.100:8000",
//       connectTimeout: Duration(minutes: 6),
//       receiveTimeout: Duration(minutes: 6),
//     ),
//   );
//   // const url = 'http://localhost:5000/upload_video';
//   const url =
//       'https://aed5-2409-4073-93-f8ba-c86c-6256-5e59-9077.ngrok-free.app/upload_video';

//   try {
//     log("Uploading video..... $videoFilePath");
//     // Ensure file exists
//     final videoFile = File(videoFilePath);
//     if (!videoFile.existsSync()) {
//       print("Error: Video file not found at $videoFilePath");
//       return;
//     }

//     // Determine MIME type (default to video/mp4 if unknown)
//     final mimeType = lookupMimeType(videoFilePath) ?? 'video/mp4';
//     log("Mimetype : $mimeType");

//     FormData formData = FormData.fromMap({
//       'video': await MultipartFile.fromFile(
//         videoFilePath,
//         filename: videoFile.path.split('/').last,
//         contentType: MediaType.parse(mimeType),
//       ),
//       'device': deviceName,
//     });

//     log("Sending request to $url...");
//     Response response = await dioClient.post(
//       url,
//       data: formData,
//       options: Options(headers: {'Accept': 'application/json'}),
//     );

//     if (response.statusCode == 200) {
//       log("Analysis successful");
//       log("Response Data: ${response.data}");
//     } else {
//       log("Server error: ${response.statusCode} - ${response.statusMessage}");
//     }
//   } on DioException catch (e) {
//     log("Dio error: ${e.response?.statusCode} - ${e.message}");
//   } on SocketException {
//     log("No internet connection");
//   } on FormatException {
//     log("Bad response format");
//   } catch (e) {
//     log("Unexpected error: $e");
//   }
// }

Future<void> addSuspect(String imagePath, String suspectName) async {
  final dio = Dio();
  const url = 'https://99fa-45-116-229-28.ngrok-free.app/add_suspect';

  try {
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      print("Error: Image file not found at $imagePath");
      return;
    }

    final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';

    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imagePath,
        filename: imageFile.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
      'name': suspectName,
    });

    print("Sending request to $url...");
    Response response = await dio.post(
      url,
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    if (response.statusCode == 200) {
      print("Suspect added successfully!");
      print("Response Data: ${response.data}");
    } else {
      print("Server error: ${response.statusCode} - ${response.statusMessage}");
    }
  } on DioException catch (e) {
    print("Dio error: ${e.response?.statusCode} - ${e.message}");
  } on SocketException {
    print("No internet connection");
  } on FormatException {
    print("Bad response format");
  } catch (e) {
    print("Unexpected error: $e");
  }
}
