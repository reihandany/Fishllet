import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final Uint8List bytes;
  final String fileName;
  final String contentType;

  PickedImage({required this.bytes, required this.fileName, required this.contentType});
}

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<PickedImage?> pickFromGallery({int imageQuality = 85, int? maxWidth}) async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: imageQuality, maxWidth: maxWidth?.toDouble());
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    return PickedImage(bytes: bytes, fileName: x.name, contentType: _guessContentType(x.name));
  }

  Future<PickedImage?> pickFromCamera({int imageQuality = 85, int? maxWidth}) async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: imageQuality, maxWidth: maxWidth?.toDouble());
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    return PickedImage(bytes: bytes, fileName: x.name, contentType: _guessContentType(x.name));
  }

  String _guessContentType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}
