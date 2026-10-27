import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  final VoidCallback onPick;

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
            FilledButton.icon(
              onPressed: isChecking ? null : onPick,
              // On the web there is often no camera, so offer a file instead.
              icon: Icon(
                kIsWeb ? Icons.upload_file : Icons.photo_camera_outlined,
              ),
              label: Text(
                kIsWeb ? AppStrings.choosePhoto : AppStrings.takePhoto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
