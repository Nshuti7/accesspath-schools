import 'dart:async';

import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../strings.dart';

/// Shows a strip above the page while the app cannot reach the server.
/// Without it, answers given offline look saved but only save once the
/// connection is back, and are lost if the app is closed first.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({
    super.key,
    required this.uid,
    required this.child,
    this.onlineChanges,
  });

  final String uid;
  final Widget child;

  /// Replaces the Firestore check in tests.
  final Stream<bool>? onlineChanges;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<bool>? _subscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) _listen();
  }

  void _listen() {
    _subscription?.cancel();
    if (widget.onlineChanges == null && widget.uid.isEmpty) return;
    final changes =
        widget.onlineChanges ?? FirestoreService().watchOnline(widget.uid);
    _subscription = changes.listen(
      (isOnline) => setState(() => _isOnline = isOnline),
      // If the check itself fails, say nothing rather than guess.
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (!_isOnline)
          Semantics(
            liveRegion: true,
            child: Material(
              color: colors.errorContainer,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        color: colors.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.offlineBanner,
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
