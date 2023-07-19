import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:dhrithi_frontend/api/api.dart';
import 'package:dhrithi_frontend/api/ocr.dart';
import 'package:dhrithi_frontend/models/upload_ocr.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR',
      theme: ThemeData.light(useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Returns void.
  FilePickerResult? result;
  File? file;
  UploadOCRModel? ocr;
  bool isUploading = false;
  TextEditingController extractedTextController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  Future<void> uploadFile() async {
    result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'jpeg', 'png']);

    setState(() {
      isUploading = true;
    });
    file = File(result!.files.single.path!);
    if (file != null) {
      ocr = await uploadOCR(file!);
      setState(() {
        extractedTextController.text = ocr!.predictedText!.replaceAll('\n', ' ');
        _controller.document.insert(0, ocr!.predictedText!.replaceFirst(" ", ""));
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isUploading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (ocr != null) ...[
                        Column(
                          children: [
                            QuillToolbar.basic(controller: _controller),
                            Expanded(child: QuillEditor.basic(
                              controller: _controller, 
                              readOnly: false))
                          ],
                        ),
                        // Text(file!.path),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: Image.network('$baseURL${ocr!.file!}')),
                        const SizedBox(width: 32),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            // child: Text(ocr!.predictedText!)
                            child: TextFormField(
                                maxLines: 30,
                                controller: extractedTextController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder())))
                      ]
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(32.0),
        child: FloatingActionButton.extended(
          label: const Text(
            'Upload your image',
            style: TextStyle(textBaseline: TextBaseline.alphabetic),
          ),
          backgroundColor: const Color.fromARGB(255, 243, 238, 238),
          icon: const Icon(Icons.upload_outlined),
          onPressed: () {
            uploadFile();
          },
          elevation: 0,
          hoverColor: const Color.fromARGB(162, 242, 109, 153),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
