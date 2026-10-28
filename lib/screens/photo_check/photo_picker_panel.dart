import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../strings.dart';

/// Explains the photo check, shows the chosen photo, and the button to take
/// or choose one.
class PhotoPickerPanel extends StatelessWidget {
  const PhotoPickerPanel({
    super.key,
    required this.imageBytes,
    required this.isChecking,
    required this.onPick,
  });

  final Uint8List? imageBytes;
  final bool isChecking;
  final ValueChanged<ImageSource> onPick;

  /// Phones and tablets open the camera straight away, in the app and in the
  /// browser. Computers usually have no useful camera, so they pick a file.
  static bool get _canUseCamera =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = imageBytes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.photoCheckIntro, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.photoNotStored,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (bytes != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  bytes,
                  height: 240,
                  fit: BoxFit.cover,
                  semanticLabel: 'Your photo',
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_canUseCamera) ...[
              FilledButton.icon(
                onPressed: isChecking ? null : () => onPick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text(AppStrings.takePhoto),
              ),
              const SizedBox(height: 8),
              // For photos taken earlier, e.g. while walking around the school.
              TextButton.icon(
                onPressed: isChecking
                    ? null
                    : () => onPick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text(AppStrings.chooseFromGallery),
              ),
            ] else
              FilledButton.icon(
                onPressed: isChecking
                    ? null
                    : () => onPick(ImageSource.gallery),
                icon: const Icon(Icons.upload_file),
                label: const Text(AppStrings.choosePhoto),
              ),
          ],
        ),
      ),
    );
  }
}
