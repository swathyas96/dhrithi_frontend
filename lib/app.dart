import 'dart:io';
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
                    child: Center(child: SingleChildScrollView(
                        child: LayoutBuilder(builder: (context, constraint) {
                      if (constraint.maxWidth < 700) {
                        return Column(children: [
                          if (ocr != null) ...[
                            // Text(file!.path),
                            Image.network('$baseURL${ocr!.file!}'),
                            const SizedBox(height: 32),
                            TextFormField(
                                minLines: 2,
                                maxLines: 30,
                                controller: extractedTextController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()))
                          ]
                        ]);
                      } else {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (ocr != null) ...[
                                // Text(file!.path),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: MediaQuery.of(context).size.height *
                                        0.9,
                                    child:
                                        Image.network('$baseURL${ocr!.file!}')),
                                const SizedBox(width: 32),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    // child: Text(ocr!.predictedText!)
                                    child: TextFormField(
                                        minLines: 2,
                                        maxLines: 30,
                                        controller: extractedTextController,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder())))
                              ]
                            ]);
                      }
                    })))),
              ),
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
