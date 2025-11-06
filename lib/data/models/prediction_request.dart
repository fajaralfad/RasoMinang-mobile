import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:klasifikasi_makanan_minang/core/utils/image_utils.dart';

class PredictionRequest {
  final File imageFile;
  final String fileName;

  PredictionRequest({
    required this.imageFile,
    required this.fileName,
  });

  // Ubah menjadi FormData untuk multipart request
  Future<FormData> toFormData() async {
    // Validasi file sebelum upload
    if (!await imageFile.exists()) {
      throw Exception('File gambar tidak ditemukan');
    }

    if (!ImageUtils.isSupportedImageFormat(imageFile.path)) {
      throw Exception('Format gambar tidak didukung');
    }

    if (!await ImageUtils.validateFileSize(imageFile)) {
      throw Exception('Ukuran file terlalu besar (max 10MB)');
    }

    // Dapatkan info gambar untuk logging
    final imageInfo = await ImageUtils.getImageInfo(imageFile);
    print('Mengupload gambar: $imageInfo');

    return FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType.parse(ImageUtils.getContentType(imageFile.path)),
      ),
    });
  }
}