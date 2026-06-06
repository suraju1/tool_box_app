import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tool_bocs/util/font_family.dart';

class WebImagePickerDialog extends StatelessWidget {
  final bool allowMultiple;
  final int? limit;
  const WebImagePickerDialog({super.key, this.allowMultiple = false, this.limit});

  static Future<List<XFile>?> show(BuildContext context, {bool allowMultiple = false, int? limit}) async {
    return await showDialog<List<XFile>>(
      context: context,
      builder: (context) => WebImagePickerDialog(allowMultiple: allowMultiple, limit: limit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamily.openSans,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildOption(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if (context.mounted) {
                        Navigator.pop(context, image != null ? [image] : null);
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  _buildOption(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () async {
                      final picker = ImagePicker();
                      if (allowMultiple) {
                        final List<XFile> images = await picker.pickMultiImage(limit: limit);
                        if (context.mounted) {
                          Navigator.pop(context, images.isNotEmpty ? images : null);
                        }
                      } else {
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (context.mounted) {
                          Navigator.pop(context, image != null ? [image] : null);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF3F4F6),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.openSans,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
