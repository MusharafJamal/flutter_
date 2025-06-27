import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/api_call.dart';
import 'package:flutter_application_3/pages/ipadd.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Userui(camera: camera),
    );
  }
}

class Userui extends StatefulWidget {
  
  final CameraDescription camera;
  const Userui({super.key, required this.camera});

  @override
  State<Userui> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<Userui> {
  late CameraController _controller;

  late Future<void> _initializeControllerFuture;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();

    _initializeControllerFuture.then((_) {
      _startRecordingLoop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startRecordingLoop() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _recordAndSendVideo();
    });
  }

  Future<void> _recordAndSendVideo() async {
    try {
      await _initializeControllerFuture;
      
      if (!_controller.value.isInitialized) {
        print("Camera not initialized");
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/video.mp4';

      print("Recording started...");
      await _controller.startVideoRecording();
      await Future.delayed(const Duration(seconds: 5)); // Record for 5 seconds
      final XFile videoFile = await _controller.stopVideoRecording();
      log("Recording finished: ${videoFile.path}");

      // Define the new path where we want to save the video
      // final newPath =
      //     '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      // final newFile = File(newPath);

      // // Rename and move the file to ensure it has an .mp4 extension
      // await File(videoFile.path).rename(newFile.path);

      // log("Video saved as: $newPath");

      // Step 3: Define Target Folder (Downloads or DCIM)
      final Directory? externalDir =
          Directory("/storage/emulated/0/Download"); // Downloads Folder
      // final Directory? externalDir = Directory("/storage/emulated/0/DCIM"); // DCIM Folder

      if (externalDir == null || !externalDir.existsSync()) {
        print("External directory not found!");
        return;
      }

      // Step 4: Move File to External Storage
      final newFilePath =
          "${externalDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4";
      final newFile = await File(videoFile.path).copy(newFilePath);

      log("Video saved successfully: $newFilePath");

      File video = File(videoFile.path);
      // await uploadVideo(newFilePath, "device one");
      await uploadVideo(newFile, "deviceName");
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> _sendVideoToServer(File video) async {
  //   try {
  //     var request = http.MultipartRequest("POST", Uri.parse();
  //     request.files.add(await http.MultipartFile.fromPath("video", video.path));

  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       print("Video uploaded successfully!");
  //     } else {
  //       print("Upload failed: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Upload error: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rear Camera Video")),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
