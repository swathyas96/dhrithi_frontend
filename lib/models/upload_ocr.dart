class UploadOCRModel {
  int? id;
  String? filename;
  String? file;
  String? fileType;
  int? numberOfPages;
  String? predictedText;
  String? uploadedBy;
  String? uploadedOn;

  UploadOCRModel(
      {this.id,
      this.filename,
      this.file,
      this.fileType,
      this.numberOfPages,
      this.predictedText,
      this.uploadedBy,
      this.uploadedOn});

  UploadOCRModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    filename = json["filename"];
    file = json["file"];
    fileType = json["file_type"];
    numberOfPages = json["number_of_pages"];
    predictedText = json["predicted_text"];
    uploadedBy = json["uploaded_by"];
    uploadedOn = json["uploaded_on"];
  }

  static List<UploadOCRModel> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => UploadOCRModel.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["filename"] = filename;
    data["file"] = file;
    data["file_type"] = fileType;
    data["number_of_pages"] = numberOfPages;
    data["predicted_text"] = predictedText;
    data["uploaded_by"] = uploadedBy;
    data["uploaded_on"] = uploadedOn;
    return data;
  }

  UploadOCRModel copyWith({
    int? id,
    String? filename,
    String? file,
    String? fileType,
    int? numberOfPages,
    String? predictedText,
    dynamic uploadedBy,
    String? uploadedOn,
  }) =>
      UploadOCRModel(
        id: id ?? this.id,
        filename: filename ?? this.filename,
        file: file ?? this.file,
        fileType: fileType ?? this.fileType,
        numberOfPages: numberOfPages ?? this.numberOfPages,
        predictedText: predictedText ?? this.predictedText,
        uploadedBy: uploadedBy ?? this.uploadedBy,
        uploadedOn: uploadedOn ?? this.uploadedOn,
      );
}
