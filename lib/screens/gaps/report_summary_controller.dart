import 'package:flutter/foundation.dart';

import '../../models/report_summary.dart';
import '../../services/ai_call.dart';

/// Holds the AI summary while the gap report is open, so the desktop header
/// button and the summary card share one state. Nothing is saved.
class ReportSummaryController extends ChangeNotifier {
  ReportSummaryController(this._request);

  final Future<ReportSummary> Function() _request;

  ReportSummary? _summary;
  bool _isLoading = false;
  AiError? _error;
  bool _disposed = false;

  ReportSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  AiError? get error => _error;

  Future<void> generate() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _summary = await _request();
    } on AiException catch (error) {
      _error = error.reason;
    } finally {
      _isLoading = false;
      // The user may have left the page while Gemini was answering.
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
