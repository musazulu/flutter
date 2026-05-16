import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  String result = "No plate detected";
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();

    controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );

    controller.initialize().then((_) async {
      if (!mounted) return;

      await controller.setZoomLevel(2.0);
      setState(() {});
    });
  }

  Future<void> captureAndSend() async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      final image = await controller.takePicture();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.110.50:5000/detect"), // 🔥 UPDATE IF IP CHANGES
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var response = await request.send();

      var respStr = await response.stream.bytesToString();
      print("SERVER RESPONSE: $respStr");

      var data = jsonDecode(respStr);

      String plate = data["plate"] ?? "No plate";
      String status = data["status"] ?? "NONE";

      setState(() {
        if (status == "BLACKLISTED") {
          result = "🚨 BLACKLISTED: $plate";
        } else {
          result = plate;
        }
      });

    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }

    isProcessing = false;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("ANPR Mobile")),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              flex: 4,
              child: CameraPreview(controller),
            ),

            Container(
              color: Colors.black,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [

                  Text(
                    result,
                    style: TextStyle(
                      fontSize: 22,
                      color: result.contains("BLACKLISTED")
                          ? Colors.red
                          : Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: captureAndSend,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        "📸 Capture Plate",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}