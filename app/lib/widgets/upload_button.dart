import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/storage_controller.dart';

class UploadButton extends StatelessWidget {
  final void Function(String url) onUploaded;
  final String label;
  final String subdir;

  const UploadButton({super.key, required this.onUploaded, this.label = 'Pick & Upload Image', this.subdir = 'products'});

  @override
  Widget build(BuildContext context) {
    return GetX<StorageController>(
      init: StorageController(),
      builder: (c) {
        return OutlinedButton.icon(
          onPressed: c.isUploading.value
              ? null
              : () async {
                  final url = await c.pickAndUpload(subdir: subdir);
                  if (url != null) onUploaded(url);
                },
          icon: c.isUploading.value
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.image),
          label: Text(c.isUploading.value ? 'Uploading...' : label),
        );
      },
    );
  }
}
