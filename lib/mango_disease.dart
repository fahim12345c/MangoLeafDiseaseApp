import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class MangoLeafDiseaseDetectionScreen extends StatefulWidget {
  const MangoLeafDiseaseDetectionScreen({super.key});

  @override
  createState() => _MangoLeafDiseaseDetectionScreenState();
}

class _MangoLeafDiseaseDetectionScreenState extends State<MangoLeafDiseaseDetectionScreen> {
  File? filePath;
  String label = "No Image Selected";
  double confidence = 0.0;
  bool isProcessing = false;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/semi-supervised_mango_leaf_model.tflite",
        labels: "assets/lables.txt",
        numThreads: 2,  // Increased for better performance
        isAsset: true,
        useGpuDelegate: false,
      );
      print("Model loaded successfully");
    } catch (e) {
      print("Failed to load model: $e");
      setState(() {
        label = "Model loading failed";
      });
    }
  }

  Future<void> _runModelOnImage(String imagePath) async {
    try {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 8,
      threshold: 0.4,
    );

    print("Recognition Results: $recognitions");

    // If simple method fails, try manual preprocessing
    if (recognitions == null || recognitions.isEmpty) {
      recognitions = await _runModelWithManualPreprocessing(imagePath);
    }

    if (recognitions == null || recognitions.isEmpty) {
      setState(() {
        label = "No disease detected";
        confidence = 0.0;
      });
    } else {
      // Safe null-checking for recognition results
      final firstRecognition = recognitions.first;
      final recognitionLabel = firstRecognition['label']?.toString();
      final recognitionConfidence = firstRecognition['confidence'] as double?;

      setState(() {
        label = recognitionLabel?.split(' ').first ?? "Unknown disease";
        confidence = (recognitionConfidence ?? 0.0) * 100;
      });
    }
  } catch (e) {
    print("Error during prediction: $e");
    setState(() {
      label = "Detection error";
      confidence = 0.0;
    });
  } finally {
    setState(() {
      isProcessing = false;
    });
  }
  }

  Future<List<dynamic>?> _runModelWithManualPreprocessing(String imagePath) async {
    try {
      // Load and decode image
      final imageBytes = await File(imagePath).readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return null;

      // Resize to model's expected input (224x224 for EfficientNet)
      final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);
      
      // Convert to model input format (uint8 for quantized model)
      var inputBytes = Uint8List(1 * 224 * 224 * 3);
      var pixelIndex = 0;
      
      for (var y = 0; y < resizedImage.height; y++) {
        for (var x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);
          inputBytes[pixelIndex++] = img.getRed(pixel);
          inputBytes[pixelIndex++] = img.getGreen(pixel);
          inputBytes[pixelIndex++] = img.getBlue(pixel);
        }
      }

      // Run model with manual input
      return await Tflite.runModelOnBinary(
        binary: inputBytes,
        numResults: 3,
        threshold: 0.4,
      );
    } catch (e) {
      print("Manual preprocessing error: $e");
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (isProcessing) return;
    
    setState(() {
      isProcessing = true;
      label = "Detecting...";
      confidence = 0.0;
    });

    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image == null) {
        setState(() {
          isProcessing = false;
          label = "No Image Selected";
        });
        return;
      }

      setState(() {
        filePath = File(image.path);
      });

      await _runModelOnImage(image.path);
    } catch (e) {
      print("Image picking error: $e");
      setState(() {
        isProcessing = false;
        label = "Error selecting image";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mango Leaf Disease Detection'),
        backgroundColor: const Color(0xff3f7777),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          height: MediaQuery.of(context).size.height,
          color: const Color(0xff468585),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Padding(padding: EdgeInsets.only(left: 30)),
                Text(
                  'Select Your Option',
                  style: GoogleFonts.quicksand(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xff3f7777),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Camera button
                      IconButton(
                        onPressed: isProcessing ? null : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded, color: Color(0xffdef9c4), size: 30),
                        style: IconButton.styleFrom(
                          backgroundColor: isProcessing ? Colors.grey : const Color(0xff50b498),
                        ),
                      ),

                      // Gallery button
                      IconButton(
                        onPressed: isProcessing ? null : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.image, color: Color(0xffdef9c4), size: 30),
                        style: IconButton.styleFrom(
                          backgroundColor: isProcessing ? Colors.grey : const Color(0xff50b498),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.transparent,
                    elevation: 100,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: filePath == null
                                ? const DecorationImage(
                                    image: AssetImage("assets/images.jpeg"),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: filePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(filePath!, fit: BoxFit.cover),
                                )
                              : Center(
                                  child: Text(
                                    "No Image Selected",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        if (isProcessing) ...[
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 20),
                        ],

                        Column(
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.quicksand(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (confidence > 0)
                              Text(
                                "Confidence: ${confidence.toStringAsFixed(2)}%",
                                style: GoogleFonts.quicksand(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}