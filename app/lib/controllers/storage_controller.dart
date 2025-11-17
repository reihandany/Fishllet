import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/image_picker_service.dart';

class StorageController extends GetxController {
  final StorageService _storage = StorageService();
  final ImagePickerService _picker = ImagePickerService();

  final isUploading = false.obs;
  final uploadedUrl = RxnString();

  Future<String?> pickAndUpload({String subdir = 'products'}) async {
    final picked = await _picker.pickFromGallery(imageQuality: 85, maxWidth: 1600);
    if (picked == null) return null;

    isUploading.value = true;
    try {
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}_${picked.fileName}';
      final path = '$subdir/$fileName';
      final url = await _storage.uploadBytes(
        bytes: picked.bytes,
        path: path,
        contentType: picked.contentType,
      );
      uploadedUrl.value = url;
      return url;
    } finally {
      isUploading.value = false;
    }
  }
}
