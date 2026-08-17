import "package:prachtiz_flutter/core/theme/app_colors.dart";
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: depend_on_referenced_packages
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../services/web_media_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WebVideoView
// Renders a real camera / screen-share MediaStream into a Flutter widget
// using PlatformView (HtmlElementView) on the web.
// ─────────────────────────────────────────────────────────────────────────────
class WebVideoView extends StatefulWidget {
  final html.MediaStream? stream;
  final String? videoUrl;
  final bool mirror;       // Mirror horizontally (front cam)
  final bool muted;        // Mute local preview audio (prevents echo)
  final BoxFit fit;
  final Widget? overlay;

  const WebVideoView({
    super.key,
    this.stream,
    this.videoUrl,
    this.mirror = false,
    this.muted = true,
    this.fit = BoxFit.cover,
    this.overlay,
  });

  @override
  State<WebVideoView> createState() => _WebVideoViewState();
}

class _WebVideoViewState extends State<WebVideoView> {
  late final String _viewId;
  html.VideoElement? _videoElement;

  @override
  void initState() {
    super.initState();
    _viewId =
        'web-cam-view-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
    _registerView();
  }

  void _registerView() {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = widget.muted
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = _fitToCss(widget.fit)
      ..style.transform = widget.mirror ? 'scaleX(-1)' : 'none'
      ..style.background = '#000'
      ..style.borderRadius = '0px';

    if (widget.stream != null) {
      _videoElement!.srcObject = widget.stream;
    } else if (widget.videoUrl != null) {
      _videoElement!.src = widget.videoUrl!;
      _videoElement!.loop = true;
      _videoElement!.setAttribute('playsinline', 'true');
      _videoElement!.crossOrigin = 'anonymous';
    }

    // Register the HTML element factory
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int id) => _videoElement!,
    );
  }

  @override
  void didUpdateWidget(WebVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream && _videoElement != null) {
      _videoElement!.srcObject = widget.stream;
    }
    if (oldWidget.videoUrl != widget.videoUrl && _videoElement != null) {
      if (widget.videoUrl != null) {
        _videoElement!.srcObject = null;
        _videoElement!.src = widget.videoUrl!;
        _videoElement!.loop = true;
        _videoElement!.setAttribute('playsinline', 'true');
        _videoElement!.crossOrigin = 'anonymous';
      }
    }
    if (oldWidget.mirror != widget.mirror && _videoElement != null) {
      _videoElement!.style.transform = widget.mirror ? 'scaleX(-1)' : 'none';
    }
    if (oldWidget.muted != widget.muted && _videoElement != null) {
      _videoElement!.muted = widget.muted;
    }
  }

  @override
  void dispose() {
    _videoElement?.srcObject = null;
    _videoElement?.src = '';
    super.dispose();
  }

  String _fitToCss(BoxFit fit) {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      default:
        return 'cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        HtmlElementView(viewType: _viewId),
        if (widget.overlay != null) widget.overlay!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PermissionGateWidget — shows a beautiful permission request screen
// before media is initialized, and graceful error states
// ─────────────────────────────────────────────────────────────────────────────
class MediaPermissionGate extends StatelessWidget {
  final MediaPermissionState state;
  final String? errorMessage;
  final VoidCallback onRequestPermission;
  final Color brandColor;

  const MediaPermissionGate({
    super.key,
    required this.state,
    this.errorMessage,
    required this.onRequestPermission,
    this.brandColor = const Color(0xFF3F8CFF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0C16),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _iconColor().withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _iconColor().withValues(alpha: 0.3), width: 1.5),
                ),
                child: Icon(_icon(), color: _iconColor(), size: 32),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                _title(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                _subtitle(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
              ),

              if (state == MediaPermissionState.idle ||
                  state == MediaPermissionState.denied) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRequestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: Text(
                    state == MediaPermissionState.denied
                        ? 'Retry Permission'
                        : 'Allow Camera & Microphone',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                if (state == MediaPermissionState.denied &&
                    errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFFEF4444).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFEF4444), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              if (state == MediaPermissionState.requesting) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: brandColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Waiting for browser permission...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon() {
    switch (state) {
      case MediaPermissionState.denied:
        return Icons.no_photography_rounded;
      case MediaPermissionState.notSupported:
        return Icons.videocam_off_rounded;
      case MediaPermissionState.requesting:
        return Icons.videocam_rounded;
      default:
        return Icons.videocam_rounded;
    }
  }

  Color _iconColor() {
    switch (state) {
      case MediaPermissionState.denied:
        return const Color(0xFFEF4444);
      case MediaPermissionState.notSupported:
        return const Color(0xFFF59E0B);
      default:
        return brandColor;
    }
  }

  String _title() {
    switch (state) {
      case MediaPermissionState.denied:
        return 'Permission Denied';
      case MediaPermissionState.notSupported:
        return 'No Camera Found';
      case MediaPermissionState.requesting:
        return 'Requesting Permission';
      default:
        return 'Camera & Microphone Required';
    }
  }

  String _subtitle() {
    switch (state) {
      case MediaPermissionState.denied:
        return 'Please allow camera and microphone access\nin your browser\'s address bar settings.';
      case MediaPermissionState.notSupported:
        return 'No camera or microphone was detected\non this device.';
      case MediaPermissionState.requesting:
        return 'Please approve the browser permission\ndialog to continue.';
      default:
        return 'Allow access to your camera and microphone\nto start the video consultation.';
    }
  }
}
