import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class RiceScreen extends StatefulWidget {
  const RiceScreen({super.key});

  @override
  State<RiceScreen> createState() => _RiceLeafDiseaseDetectionScreenState();
}

class _RiceLeafDiseaseDetectionScreenState extends State<RiceScreen>
    with TickerProviderStateMixin {
  File? filePath;
  String label = "No Image Selected";
  double confidence = 0.0;
  bool isProcessing = false;
  final ImagePicker picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Disease advice data
  final Map<String, Map<String, dynamic>> diseaseAdvice = {
  'Bacterial_Leaf_Blight': {
    'description': 'পাতা ও ফলে কালো দাগ সৃষ্টি করে এমন একটি ছত্রাকজনিত রোগ।',
    'symptoms': [
      'পাতায় গাঢ় রঙের দাগ বা দহন দাগ',
      'ফলে বাদামী বা কালো দাগ',
      'পাতা ঝরে পড়া',
      'ফলের গুণমান কমে যাওয়া'
    ],
    'treatments': [
      'কপারভিত্তিক ফাংগিসাইড স্প্রে করুন',
      'উচ্চ নিকাশী ব্যবস্থা নিশ্চিত করুন',
      'আক্রান্ত অংশ সরিয়ে ফেলুন',
      'গাছের আশেপাশে বাতাস চলাচলের ব্যবস্থা করুন',
      'নীম তেল স্প্রে ব্যবহার করুন'
    ],
    'prevention': [
      'প্রতিরোধী জাত ব্যবহার করুন',
      'ওভারহেড পানি সেচ এড়িয়ে চলুন',
      'বাতাস চলাচলের জন্য গাছ ছাঁটাই করুন',
      'পড়ে থাকা পাতা পরিষ্কার রাখুন'
    ],
    'color': const Color(0xFFE74C3C)
  },
  'Brown Spot': {
    'description': 'পাতা ও কাণ্ডে প্রভাব ফেলে এমন একটি ব্যাকটেরিয়াজনিত রোগ।',
    'symptoms': [
      'পাতায় পানিভেজা দাগ',
      'দাগের চারপাশে হলুদ রিং',
      'নবীন শাখা শুকিয়ে যাওয়া',
      'ডালে ক্যানকার সৃষ্টি হওয়া'
    ],
    'treatments': [
      'কপার সালফেট স্প্রে করুন',
      'আক্রান্ত অংশ দ্রুত কেটে ফেলুন',
      'স্ট্রেপ্টোমাইসিনভিত্তিক অ্যান্টিবায়োটিক ব্যবহার করুন',
      'নিকাশী ব্যবস্থা উন্নত করুন'
    ],
    'prevention': [
      'ছাঁটাই করার সময় ক্ষত তৈরি এড়িয়ে চলুন',
      'ছাঁটাইয়ের সরঞ্জাম জীবাণুমুক্ত রাখুন',
      'পোকা বাহক নিয়ন্ত্রণ করুন',
      'সঠিক দূরত্ব বজায় রেখে গাছ লাগান'
    ],
    'color': const Color.fromARGB(255, 243, 18, 18)
  },
  'Hispa': {
    'description': 'ভুল ছাঁটাই বা কাটার কারণে শারীরিক ক্ষতি।',
    'symptoms': [
      'ডালে পরিষ্কার কাটা দাগ',
      'কাঠামো উন্মুক্ত থাকা',
      'দ্বিতীয় পর্যায়ের সংক্রমণ সম্ভাবনা',
      'রস নির্গত হওয়া'
    ],
    'treatments': [
      'কাটার স্থানে সিল্যান্ট লাগান',
      'অ্যান্টিসেপটিক দিয়ে পরিষ্কার করুন',
      'সংক্রমণের লক্ষণ পর্যবেক্ষণ করুন',
      'দুর্বল ডালপালা সমর্থন দিন'
    ],
    'prevention': [
      'ধারালো ও পরিষ্কার যন্ত্র ব্যবহার করুন',
      'সঠিক সময়ে ছাঁটাই করুন',
      'উপযুক্ত কোণে কাটা দিন',
      'ভেজা আবহাওয়ায় ছাঁটাই এড়িয়ে চলুন'
    ],
    'color': const Color.fromARGB(255, 236, 0, 0)
  },
  'Leaf_Blast': {
    'description': 'একটি গুরুতর রোগ যা গাছের মৃত্যুর দিকে নিয়ে যায়।',
    'symptoms': [
      'সম্পূর্ণ পাতায় হলুদ হওয়া',
      'ডাল শুকিয়ে যাওয়া',
      'গোড়ায় পচন ধরার লক্ষণ',
      'গাছের সামগ্রিক দুর্বলতা'
    ],
    'treatments': [
      'মূল কারণ শনাক্ত করুন',
      'মাটির পানি নিষ্কাশন উন্নত করুন',
      'সিস্টেমিক ফাংগিসাইড ব্যবহার করুন',
      'প্রয়োজনে গাছ প্রতিস্থাপন করুন'
    ],
    'prevention': [
      'নিয়মিত গাছের স্বাস্থ্য পরীক্ষা করুন',
      'সঠিকভাবে সেচ দিন',
      'মাটির স্বাস্থ্য বজায় রাখুন',
      'প্রথম দিকেই রোগ নিয়ন্ত্রণ করুন'
    ],
    'color': const Color.fromARGB(255, 245, 21, 21)
  },
  'Leaf_scald': {
    'description': 'পোকা বা মাইটের কারণে অস্বাভাবিক বৃদ্ধির সৃষ্টি।',
    'symptoms': [
      'পাতায় অস্বাভাবিক ফোলাভাব',
      'বাঁকানো পাতার গঠন',
      'পাতায় ছোট ছোট গুটি বা ফোলা',
      'ফটোসিনথেসিস হ্রাস পায়'
    ],
    'treatments': [
      'ইনসেক্টিসাইডাল সাবান স্প্রে করুন',
      'নীম তেল ব্যবহার করুন',
      'আক্রান্ত পাতা সরিয়ে ফেলুন',
      'পোকা নিয়ন্ত্রণে রাখুন'
    ],
    'prevention': [
      'নিয়মিত পোকা পর্যবেক্ষণ করুন',
      'গাছের পরিচ্ছন্নতা বজায় রাখুন',
      'ফেরোমন ফাঁদ ব্যবহার করুন',
      'উপকারী পোকা সংরক্ষণ করুন'
    ],
    'color': const Color.fromARGB(255, 240, 2, 2)
  },
  'Healthy': {
    'description': 'আপনার গাছ বর্তমানে সুস্থ আছে!',
    'symptoms': [
      'উজ্জ্বল সবুজ রঙের পাতা',
      'কোনো দাগ বা রোগ নেই',
      'স্বাভাবিক পাতার গঠন',
      'গাছের জোরালো বৃদ্ধির লক্ষণ'
    ],
    'treatments': [
      'বর্তমান পরিচর্যা চালিয়ে যান',
      'নিয়মিত পানি দিন',
      'পর্যাপ্ত পুষ্টি নিশ্চিত করুন',
      'যেকোন পরিবর্তন পর্যবেক্ষণ করুন'
    ],
    'prevention': [
      'নিয়মিত স্বাস্থ্য পরীক্ষা',
      'সুষম সার প্রয়োগ',
      'সঠিকভাবে ছাঁটাই করা',
      'পোকা-মাকড় পর্যবেক্ষণ'
    ],
    'color': const Color.fromARGB(255, 1, 245, 103)
  },
  'Narrow_Brown_Leaf_Spot': {
    'description': 'স্কেল বা অ্যাফিড পোকা থেকে নিঃসৃত হানি ডিউ-এর উপর গড়ে ওঠা কালো ছত্রাক।',
    'symptoms': [
      'পাতায় কালো ধোঁয়াসম আবরণ',
      'সূর্যালোক প্রবেশে বাধা',
      'পাতায় স্টিকি হানি ডিউ',
      'স্কেল ইনসেক্ট থাকার সম্ভাবনা'
    ],
    'treatments': [
      'পাতা সাবান পানিতে ধুয়ে ফেলুন',
      'স্কেল পোকা নিয়ন্ত্রণ করুন',
      'হর্টিকালচারাল অয়েল স্প্রে করুন',
      'বাতাস চলাচল নিশ্চিত করুন'
    ],
    'prevention': [
      'নিয়মিত পোকা নিয়ন্ত্রণ',
      'স্কেল ইনসেক্ট মনিটর করুন',
      'পরিবেশ পরিচ্ছন্ন রাখুন',
      'সঠিক দূরত্ব বজায় রেখে রোপণ করুন'
    ],
    'color': const Color.fromARGB(255, 240, 2, 2)
  },
  'Sheath_Blight': {
    'description': 'পাতায় গুঁড়ো সাদা ছত্রাক যা গাছের স্বাস্থ্য ক্ষতিগ্রস্ত করে।',
    'symptoms': [
      'পাতায় সাদা পাউডারের মত ছত্রাক',
      'পাতা বিবর্ণ হয়ে যাওয়া',
      'বৃদ্ধি হ্রাস',
      'বিকৃত পাতা গঠন'
    ],
    'treatments': [
      'পাতা সাবান পানি দিয়ে পরিষ্কার করুন',
      'অ্যাফিড ও স্কেল পোকা নিয়ন্ত্রণ করুন',
      'নিম তেল স্প্রে করুন',
      'বাতাস চলাচলের ব্যবস্থা করুন'
    ],
    'prevention': [
      'নিয়মিত পোকা-মাকড় নিয়ন্ত্রণ',
      'স্কেল পোকা পর্যবেক্ষণ',
      'পরিচ্ছন্ন ও সুষম পরিবেশ বজায় রাখুন',
      'বেশি ঘনভাবে গাছ লাগাবেন না'
    ],
    'color': const Color.fromARGB(255, 243, 6, 6)
  }
};

  @override
  void initState() {
    super.initState();
    _loadModel();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/plantDiseaseModel.tflite",
        labels: "assets/lables.txt",
        numThreads: 2,
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
    _pulseController.repeat(reverse: true);

    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 8,
      threshold: 0.4,
    );

    print("Recognition Results: $recognitions");

    if (recognitions == null || recognitions.isEmpty) {
      recognitions = await _runModelWithManualPreprocessing(imagePath);
    }

    if (recognitions == null || recognitions.isEmpty) {
      setState(() {
        label = "No disease detected";
        confidence = 0.0;
      });
    } else {
      final firstRecognition = recognitions.first;
      final recognitionLabel = firstRecognition['label']?.toString();
      final recognitionConfidence = firstRecognition['confidence'] as double?;

      // 🔍 Check for non-RiceScreen plant diseases
      if (recognitionLabel != null && !recognitionLabel.startsWith("Rice_")) {
        setState(() {
          label = "Wrong plant detected";
          confidence = (recognitionConfidence ?? 0.0) * 100;
        });
      } else {
        // ✅ RiceScreen disease detected
        setState(() {
          label = recognitionLabel?.split('Mango_').last.trim() ?? "Unknown disease";
          confidence = (recognitionConfidence ?? 0.0) * 100;
        });
      }
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
    _pulseController.stop();
    _pulseController.reset();
  }
}


  Future<List<dynamic>?> _runModelWithManualPreprocessing(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return null;

      final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);
      
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
      label = "Analyzing...";
      confidence = 0.0;
    });

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
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

  void _showAdviceDialog() {
    final advice = diseaseAdvice[label];
    if (advice == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: advice['color'],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        label == 'Mango_Healthy' ? Icons.check_circle : Icons.warning,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice['description'],
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAdviceSection('Symptoms', advice['symptoms'], Icons.visibility),
                        const SizedBox(height: 16),
                        _buildAdviceSection('Treatment', advice['treatments'], Icons.healing),
                        const SizedBox(height: 16),
                        _buildAdviceSection('Prevention', advice['prevention'], Icons.shield),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdviceSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF3f7777), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3f7777),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A9396),
              Color(0xFF468585),
              Color(0xFF3f7777),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rice Leaf Disease',
                              style: GoogleFonts.quicksand(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'AI-Powered Detection',
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Image Selection Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Choose Image Source',
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3f7777),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildImageSourceButton(
                                      'Camera',
                                      Icons.camera_alt,
                                      () => _pickImage(ImageSource.camera),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildImageSourceButton(
                                      'Gallery',
                                      Icons.photo_library,
                                      () => _pickImage(ImageSource.gallery),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Image Display Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Image Container
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: isProcessing ? _pulseAnimation.value : 1.0,
                                    child: Container(
                                      height: 280,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isProcessing
                                              ? const Color(0xFF3f7777)
                                              : Colors.grey[300]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: filePath != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(14),
                                              child: Image.file(
                                                filePath!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image,
                                                  size: 60,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'No Image Selected',
                                                  style: GoogleFonts.quicksand(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Processing Indicator
                              if (isProcessing) ...[
                                const CircularProgressIndicator(
                                  color: Color(0xFF3f7777),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Analyzing your image...',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ] else ...[
                                // Results Display
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: _getResultColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getResultColor().withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getResultIcon(),
                                            color: _getResultColor(),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              label,
                                              style: GoogleFonts.quicksand(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _getResultColor(),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (confidence > 0) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          'Confidence: ${confidence.toStringAsFixed(1)}%',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: confidence / 100,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _getResultColor(),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                // Get Advice Button
                                if (diseaseAdvice.containsKey(label) && filePath != null) ...[
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _showAdviceDialog,
                                      icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                                      label: Text(
                                        'Get Treatment Advice',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3f7777),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton(String title, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isProcessing ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isProcessing 
                ? Colors.grey[200] 
                : const Color(0xFF3f7777).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isProcessing 
                  ? Colors.grey[300]! 
                  : const Color(0xFF3f7777).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isProcessing ? Colors.grey : const Color(0xFF3f7777),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isProcessing ? Colors.grey : const Color(0xFF3f7777),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getResultColor() {
    if (diseaseAdvice.containsKey(label)) {
      return diseaseAdvice[label]!['color'];
    }
    return Colors.grey;
  }

  IconData _getResultIcon() {
    switch (label) {
      case 'Healthy':
        return Icons.check_circle;
      case 'No Image Selected':
        return Icons.image;
      default:
        return Icons.warning;
    }
  }
}