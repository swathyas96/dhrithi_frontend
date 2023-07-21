import 'dart:io';
import 'package:dhrithi_frontend/api/ocr.dart';
import 'package:dhrithi_frontend/models/upload_ocr.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;

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
  final fq.QuillController _quillController = fq.QuillController.basic();
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
        isUploading = false;
        extractedTextController.text =
            ocr != null ? ocr!.predictedText!.replaceAll('\n', ' ') : '';
        _quillController.clear();
        _quillController.document.insert(
            0, ocr != null ? ocr!.predictedText!.replaceAll('\n', ' ') : '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isUploading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (ocr != null) ...[
                        fq.QuillToolbar.basic(controller: _quillController),
                        Expanded(
                            child: fq.QuillEditor.basic(
                                controller: _quillController,
                                readOnly: false // true for view only mode
                                ))
                      ]
                    ]))),
        floatingActionButton: FloatingActionButton.extended(
            label: const Text(
              'Upload File',
              style: TextStyle(textBaseline: TextBaseline.alphabetic),
            ),
            icon: const Icon(Icons.upload_outlined),
            onPressed: () => uploadFile()),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }
}
