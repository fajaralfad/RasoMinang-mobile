import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  static const uuid = Uuid();

  /// Mengkompresi gambar untuk mengurangi ukuran file sebelum upload
  static Future<File> compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      
      // Cek jika file exists
      if (!await file.exists()) {
        throw Exception('File gambar tidak ditemukan: $imagePath');
      }

      // Cek ukuran file asli
      final originalSize = await file.length();
      print('Ukuran file asli: ${(originalSize / 1024).toStringAsFixed(2)} KB');

      // Jika file sudah kecil (< 500KB), tidak perlu kompresi
      if (originalSize < 500 * 1024) {
        print('File sudah optimal, skip kompresi');
        return file;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${uuid.v4()}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80, // Sedikit dikurangi untuk ukuran lebih kecil
        minWidth: 800, // Diperbesar sedikit untuk kualitas lebih baik
        minHeight: 800,
        autoCorrectionAngle: true, // Auto rotate jika perlu
        keepExif: true, // Pertahankan metadata
      );

      if (compressedFile == null) {
        print('Kompresi gagal, menggunakan file asli');
        return file;
      }

      final compressedSize = await compressedFile.length();
      print('Ukuran file setelah kompresi: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
      
      final reduction = ((originalSize - compressedSize) / originalSize * 100);
      print('Pengurangan ukuran: ${reduction.toStringAsFixed(1)}%');

      return File(compressedFile.path);
    } catch (e) {
      print('Error saat kompresi gambar: $e');
      // Fallback ke file asli jika kompresi gagal
      return File(imagePath);
    }
  }

  /// Mendapatkan nama file dari path
  static String getFileNameFromPath(String path) {
    return path.split('/').last;
  }

  /// Mendapatkan ekstensi file
  static String getFileExtension(String path) {
    final fileName = getFileNameFromPath(path);
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(dotIndex + 1).toLowerCase() : 'jpg';
  }

  /// Validasi apakah file adalah gambar yang supported
  static bool isSupportedImageFormat(String path) {
    final extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'bmp', 'webp'].contains(extension);
  }

  /// Mendapatkan content type berdasarkan ekstensi file
  static String getContentType(String path) {
    final extension = getFileExtension(path);
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Menyimpan gambar ke direktori aplikasi untuk history
  static Future<File> saveImageToAppDirectory(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      
      // Buat directory jika belum ada
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${uuid.v4()}.jpg';
      final savedImagePath = '${imagesDir.path}/$fileName';
      final savedImage = await imageFile.copy(savedImagePath);
      
      print('Gambar disimpan ke: $savedImagePath');
      return savedImage;
    } catch (e) {
      print('Error menyimpan gambar: $e');
      throw Exception('Gagal menyimpan gambar: $e');
    }
  }

  /// Menghapus gambar dari temporary directory
  static Future<void> cleanupTempFiles(List<File> tempFiles) async {
    try {
      for (final file in tempFiles) {
        if (await file.exists()) {
          await file.delete();
          print('File temporary dihapus: ${file.path}');
        }
      }
    } catch (e) {
      print('Error membersihkan file temporary: $e');
    }
  }

  /// Mendapatkan informasi file gambar
  static Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final stat = await imageFile.stat();
      return {
        'path': imageFile.path,
        'size': stat.size,
        'sizeKB': (stat.size / 1024).toStringAsFixed(2),
        'lastModified': stat.modified,
        'fileName': getFileNameFromPath(imageFile.path),
        'extension': getFileExtension(imageFile.path),
      };
    } catch (e) {
      return {
        'path': imageFile.path,
        'error': e.toString(),
      };
    }
  }

  /// Validasi ukuran file (max 10MB)
  static Future<bool> validateFileSize(File imageFile, {int maxSizeMB = 10}) async {
    try {
      final stat = await imageFile.stat();
      final maxSizeBytes = maxSizeMB * 1024 * 1024;
      return stat.size <= maxSizeBytes;
    } catch (e) {
      return false;
    }
  }

  /// Create thumbnail dari gambar
  static Future<File> createThumbnail(String imagePath, {int width = 200, int height = 200}) async {
    try {
      final file = File(imagePath);
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = '${tempDir.path}/${uuid.v4()}_thumbnail.jpg';

      final thumbnail = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        thumbnailPath,
        quality: 60,
        minWidth: width,
        minHeight: height,
      );

      return thumbnail != null ? File(thumbnail.path) : file;
    } catch (e) {
      print('Error membuat thumbnail: $e');
      return File(imagePath);
    }
  }
}