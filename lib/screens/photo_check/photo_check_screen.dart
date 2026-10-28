import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../page_text.dart';
import '../../models/checklist_item.dart';
import '../../models/photo_finding.dart';
import '../../providers/assessment_provider.dart';
import '../../services/ai_call.dart';
import '../../services/gemini_service.dart';
import '../../strings.dart';
import '../../widgets/form_error_text.dart';
import '../../widgets/info_message.dart';
import '../../widgets/data_gate.dart';
import '../../widgets/page_scaffold.dart';
import 'finding_card.dart';
import 'photo_picker_panel.dart';

class PhotoCheckScreen extends StatefulWidget {
  const PhotoCheckScreen({super.key, required this.areaId, this.itemId});

  final String areaId;

  /// When set, only this checklist item is checked instead of the whole area.
  final String? itemId;

  @override
  State<PhotoCheckScreen> createState() => _PhotoCheckScreenState();
}

class _PhotoCheckScreenState extends State<PhotoCheckScreen> {
  final _gemini = GeminiService();
  final _saving = <PhotoFinding>{};

  // The photo lives only in memory on this screen and is gone when it closes.
  Uint8List? _imageBytes;
  bool _isChecking = false;
  AiError? _error;
  List<PhotoFinding>? _findings;
  int _reviewedCount = 0;

  List<ChecklistItem> _itemsToCheck(AssessmentProvider assessment) {
    final itemId = widget.itemId;
    if (itemId != null) {
      final item = assessment.itemById(itemId);
      if (item != null && item.area == widget.areaId) return [item];
    }
    return assessment.itemsForArea(widget.areaId);
  }

  Future<void> _pickAndCheck() async {
    final items = _itemsToCheck(context.read<AssessmentProvider>());
    if (items.isEmpty) return;

    final XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1280,
        imageQuality: 70,
        // Skips location and other metadata we do not need.
        requestFullMetadata: false,
      );
    } catch (_) {
      _showMessage(AppStrings.errorCamera);
      return;
    }
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _isChecking = true;
      _error = null;
      _findings = null;
      _reviewedCount = 0;
    });

    try {
      final findings = await _gemini.checkPhoto(
        imageBytes: bytes,
        mimeType: GeminiService.imageMimeType(file.mimeType, file.name),
        items: items,
      );
      if (mounted) setState(() => _findings = findings);
    } on AiException catch (error) {
      if (mounted) setState(() => _error = error.reason);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _accept(PhotoFinding finding, ChecklistItem item) async {
    setState(() => _saving.add(finding));
    final saved = await context.read<AssessmentProvider>().addGapFromPhoto(
      item,
      finding,
    );
    if (!mounted) return;
    setState(() {
      _saving.remove(finding);
      if (saved) _markReviewed(finding);
    });
    _showMessage(saved ? AppStrings.addedToGaps : AppStrings.errorSaveGap);
  }

  void _dismiss(PhotoFinding finding) {
    setState(() => _markReviewed(finding));
  }

  void _markReviewed(PhotoFinding finding) {
    _findings?.remove(finding);
    _reviewedCount++;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final assessment = context.watch<AssessmentProvider>();

    return PageScaffold(
      title: AppStrings.photoCheck,
      description: PageText.photoCheck,
      body: DataGate(builder: (context) => _buildBody(assessment)),
    );
  }

  Widget _buildBody(AssessmentProvider assessment) {
    final error = _error;
    final findings = _findings;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PhotoPickerPanel(
              imageBytes: _imageBytes,
              isChecking: _isChecking,
              onPick: _pickAndCheck,
            ),
            const SizedBox(height: 16),
            if (_isChecking)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text(AppStrings.checkingPhoto),
                ],
              ),
            if (error != null) FormErrorText(_messageFor(error)),
            if (findings != null && findings.isEmpty)
              InfoMessage(
                _reviewedCount > 0
                    ? AppStrings.allFindingsReviewed
                    : AppStrings.noBarriersSpotted,
              ),
            if (findings != null)
              for (final finding in findings)
                if (assessment.itemById(finding.itemId) case final item?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FindingCard(
                      finding: finding,
                      item: item,
                      isSaving: _saving.contains(finding),
                      onAccept: () => _accept(finding, item),
                      onDismiss: () => _dismiss(finding),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  static String _messageFor(AiError error) {
    return switch (error) {
      AiError.offline => AppStrings.errorOffline,
      AiError.quotaReached => AppStrings.errorPhotoQuota,
      AiError.unreadableResponse => AppStrings.errorPhotoUnreadable,
      AiError.unavailable => AppStrings.errorPhotoUnavailable,
    };
  }
}
