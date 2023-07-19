import 'dart:developer';
import 'dart:io';
import 'package:dhrithi_frontend/models/upload_ocr.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'api.dart';

final dio = Dio(baseOptions);

Future<UploadOCRModel?> uploadOCR(File file) async {
  String fileName = file.path.split('/').last;
  log(fileName);
  FormData formData = FormData.fromMap({
    "filename": fileName,
    "file": await MultipartFile.fromFile(file.path,
        filename: fileName,
        contentType:
            MediaType('image', file.uri.pathSegments.last.split('.').last)),
  });
  try {
    final response = await dio.post("/api/document/upload", data: formData);
    if (response.statusCode == 200) {
      return UploadOCRModel.fromJson(response.data);
    } else {
      log('${response.statusCode} : ${response.data.toString()}');
      throw response.statusCode!;
    }
  } catch (error) {
    log(error.toString());
  }
  return null;
}

