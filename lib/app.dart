import 'dart:io';
import 'package:delta_to_pdf/delta_to_pdf.dart';
import 'package:dhrithi_frontend/api/api.dart';
import 'package:dhrithi_frontend/api/ocr.dart';
import 'package:dhrithi_frontend/models/upload_ocr.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:flutter_svg/svg.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
  final SvgPicture fileUploadSVG = SvgPicture.asset('assets/file_upload.svg',
      semanticsLabel: 'File Upload SVG');

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
    if (result != null) {
      file = File(result!.files.single.path!);
    }
    if (file != null) {
      ocr = await uploadOCR(file!);
      setState(() {
        isUploading = false;
        extractedTextController.text =
            ocr != null ? ocr!.predictedText!.replaceAll('\n', ' ') : '';
        _quillController.clear();
        _quillController.document
            .insert(0, ocr != null ? ocr!.predictedText : '');
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                EditingPage(ocr: ocr, quillController: _quillController)));
      });
    }
    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("ധൃതി")),
        body: isUploading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [fileUploadSVG, const Text('Upload PDF or Image')],
                ),
              ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton.extended(
              label: const Text('Upload File',
                  style: TextStyle(textBaseline: TextBaseline.alphabetic)),
              icon: const Icon(Icons.upload_outlined),
              onPressed: () => uploadFile()),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }
}

class EditingPage extends StatefulWidget {
  const EditingPage({
    super.key,
    required this.ocr,
    required fq.QuillController quillController,
  }) : _quillController = quillController;

  final UploadOCRModel? ocr;
  final fq.QuillController _quillController;

  @override
  State<EditingPage> createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  getNextPage() async {
    if (widget.ocr!.numberOfPages! > 1) {
      for (int i = 1; i < widget.ocr!.numberOfPages!; i++) {
        String? extractedText = await extractText(i, widget.ocr!.id!);
        String text = widget._quillController.document.toPlainText();
        text += (extractedText ?? '');
        widget._quillController.clear();
        widget._quillController.document.insert(0, text);
      }
    }
  }

  showSavedSnackbar(String downloadLocation, filename) {
    SnackBar snackBar = SnackBar(
        content: Text('File has been downloaded to $downloadLocation'),
        action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenAppFile.open('$downloadLocation/$filename')));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  saveDOCX(pdf) async {
    /// Save the PDF as a temporary file
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/document.pdf");
    await file.writeAsBytes(await pdf.save());

    /// Convert the PDF to DOCX format
    String? filePath = await exportAsDOC(file);

    /// Download the converted DOCX file
    final request = await HttpClient().getUrl(Uri.parse(baseURL +
        filePath!.replaceFirst(".pdf", ".docx").replaceFirst("PDF", "Doc")));
    final response = await request.close();
    final docfile = File("${output.path}/document.docx");
    response.pipe(docfile.openWrite());
    showSavedSnackbar(output.path, 'document.docx');
  }

  getTheme() async {
    var myTheme = pw.ThemeData.withFont(
        base: pw.Font.ttf(await rootBundle
            .load("assets/font/mandharam/mandharam_regular.ttf")),
        bold: pw.Font.ttf(
            await rootBundle.load("assets/font/mandharam/mandharam_bold.ttf")),
        italic: pw.Font.ttf(await rootBundle
            .load("assets/font/mandharam/mandharam_italic.ttf")),
        boldItalic: pw.Font.ttf(await rootBundle
            .load("assets/font/mandharam/mandharam_bold_italic.ttf")));
    return myTheme;
  }

  exportDoc() async {
    final pdf = pw.Document(
      theme: await getTheme(),
    );
    var delta = widget._quillController.document.toDelta().toList();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          DeltaToPDF dpdf = DeltaToPDF();
          return dpdf.deltaToPDF(delta);
        }));

    await saveDOCX(pdf);
  }

  @override
  void initState() {
    super.initState();
    getNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          TextButton(
              onPressed: () async => exportDoc(),
              child: const Text('Export As DOCX'))
        ]),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (widget.ocr != null) ...[
                fq.QuillToolbar.basic(controller: widget._quillController),
                Expanded(
                    child: fq.QuillEditor.basic(
                        controller: widget._quillController,
                        readOnly: false // true for view only mode
                        ))
              ]
            ])));
  }
}
