// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: depend_on_referenced_packages
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Permission Status enum
// ─────────────────────────────────────────────────────────────────────────────
enum MediaPermissionState { idle, requesting, granted, denied, notSupported }

// ─────────────────────────────────────────────────────────────────────────────
// Camera Device model
// ─────────────────────────────────────────────────────────────────────────────
class CameraDevice {
  final String deviceId;
  final String label;
  final String facingMode; // 'user' | 'environment' | 'unknown'

  const CameraDevice({
    required this.deviceId,
    required this.label,
    required this.facingMode,
  });

  bool get isFront => facingMode == 'user';
  bool get isBack => facingMode == 'environment';

  String get displayName {
    if (label.isNotEmpty) return label;
    if (isFront) return 'Front Camera';
    if (isBack) return 'Back Camera';
    return 'Camera';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WebMediaService — singleton service
// Manages camera stream, microphone, and screen sharing for Flutter Web.
// ─────────────────────────────────────────────────────────────────────────────
class WebMediaService extends ChangeNotifier {
  static final WebMediaService _instance = WebMediaService._();
  factory WebMediaService() => _instance;
  WebMediaService._();

  // ── State ────────────────────────────────────────────────────────────────────
  MediaPermissionState _camPermission = MediaPermissionState.idle;
  MediaPermissionState _micPermission = MediaPermissionState.idle;
  MediaPermissionState _screenPermission = MediaPermissionState.idle;

  html.MediaStream? _localStream;         // Camera + mic stream
  html.MediaStream? _screenStream;        // Screen share stream

  List<CameraDevice> _cameras = [];
  int _currentCameraIdx = 0;

  bool _isMicMuted = false;
  bool _isVideoOff = false;
  bool _isScreenSharing = false;
  bool _isInitialized = false;

  String? _lastError;

  // ── Getters ──────────────────────────────────────────────────────────────────
  MediaPermissionState get camPermission => _camPermission;
  MediaPermissionState get micPermission => _micPermission;
  MediaPermissionState get screenPermission => _screenPermission;
  html.MediaStream? get localStream => _localStream;
  html.MediaStream? get screenStream => _screenStream;
  List<CameraDevice> get cameras => _cameras;
  bool get isMicMuted => _isMicMuted;
  bool get isVideoOff => _isVideoOff;
  bool get isScreenSharing => _isScreenSharing;
  bool get isInitialized => _isInitialized;
  bool get hasMultipleCameras => _cameras.length > 1;
  String? get lastError => _lastError;
  CameraDevice? get currentCamera =>
      _cameras.isNotEmpty ? _cameras[_currentCameraIdx] : null;

  // ────────────────────────────────────────────────────────────────────────────
  // 1. REQUEST CAMERA + MIC PERMISSIONS AND START STREAM
  // ────────────────────────────────────────────────────────────────────────────
  Future<bool> requestAndStartMedia() async {
    if (!kIsWeb) {
      _lastError = 'Camera/mic via WebRTC is only supported on web.';
      notifyListeners();
      return false;
    }

    _camPermission = MediaPermissionState.requesting;
    _micPermission = MediaPermissionState.requesting;
    notifyListeners();

    try {
      // First enumerate devices to detect cameras
      await _enumerateCameras();

      // Build constraints: prefer front camera on laptop (only 1 cam = user-facing)
      final constraints = <String, dynamic>{
        'video': _buildVideoConstraints(),
        'audio': true,
      };

      final stream = await html.window.navigator.mediaDevices!
          .getUserMedia(constraints);

      _localStream = stream;
      _camPermission = MediaPermissionState.granted;
      _micPermission = MediaPermissionState.granted;
      _isInitialized = true;
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('notallowederror') ||
          errStr.contains('permissiondenied') ||
          errStr.contains('permission denied')) {
        _camPermission = MediaPermissionState.denied;
        _micPermission = MediaPermissionState.denied;
        _lastError =
            'Camera or microphone permission was denied. Please allow access in your browser settings.';
      } else if (errStr.contains('notfounderror') ||
          errStr.contains('devicenotfound')) {
        _camPermission = MediaPermissionState.notSupported;
        _lastError = 'No camera or microphone found on this device.';
      } else if (errStr.contains('notreadableerror') ||
          errStr.contains('could not start')) {
        _camPermission = MediaPermissionState.denied;
        _lastError =
            'Camera is in use by another application. Please close it and retry.';
      } else {
        _camPermission = MediaPermissionState.denied;
        _lastError = 'Failed to access camera/microphone: $e';
      }
      notifyListeners();
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 2. ENUMERATE CAMERA DEVICES
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _enumerateCameras() async {
    try {
      final devices = await html.window.navigator.mediaDevices!.enumerateDevices();
      final videoInputs = devices
          .where((d) => d.kind == 'videoinput')
          .toList();

      _cameras = videoInputs.map((d) {
        // Heuristic: detect facing mode from label
        final lbl = (d.label ?? '').toLowerCase();
        String facing = 'unknown';
        if (lbl.contains('front') || lbl.contains('facetime') ||
            lbl.contains('user') || lbl.contains('selfie')) {
          facing = 'user';
        } else if (lbl.contains('back') || lbl.contains('rear') ||
            lbl.contains('environment') || lbl.contains('world')) {
          facing = 'environment';
        } else if (videoInputs.length == 1) {
          // On laptop with single webcam, treat it as front
          facing = 'user';
        }
        return CameraDevice(
          deviceId: d.deviceId ?? '',
          label: d.label ?? '',
          facingMode: facing,
        );
      }).toList();
    } catch (_) {
      _cameras = [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 3. BUILD VIDEO CONSTRAINTS
  // ────────────────────────────────────────────────────────────────────────────
  dynamic _buildVideoConstraints() {
    if (_cameras.isEmpty) {
      return {'facingMode': 'user', 'width': 1280, 'height': 720};
    }
    final cam = _cameras[_currentCameraIdx];
    if (cam.deviceId.isNotEmpty) {
      return {
        'deviceId': {'exact': cam.deviceId},
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      };
    }
    return {'facingMode': 'user', 'width': 1280, 'height': 720};
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 4. SWITCH CAMERA (Front ↔ Back)
  // ────────────────────────────────────────────────────────────────────────────
  Future<String> switchCamera() async {
    if (_cameras.length <= 1) {
      // Single camera device (laptop)
      return _cameras.length == 1
          ? 'Only one camera found on this device (${_cameras[0].displayName}). No camera to switch to.'
          : 'No camera found on this device.';
    }

    _currentCameraIdx = (_currentCameraIdx + 1) % _cameras.length;

    // Stop old video track
    _localStream?.getVideoTracks().forEach((t) => t.stop());

    try {
      final newConstraints = <String, dynamic>{
        'video': _buildVideoConstraints(),
        'audio': false, // Don't re-request audio
      };

      final newVideoStream = await html.window.navigator.mediaDevices!
          .getUserMedia(newConstraints);

      // Replace video track in existing stream
      final newVideoTrack = newVideoStream.getVideoTracks().first;

      // Remove old video tracks and add new one
      _localStream?.getVideoTracks().forEach((t) => _localStream!.removeTrack(t));
      _localStream?.addTrack(newVideoTrack);

      // If video was off, keep it muted
      newVideoTrack.enabled = !_isVideoOff;

      notifyListeners();
      final cam = _cameras[_currentCameraIdx];
      return 'Switched to ${cam.displayName}';
    } catch (e) {
      _currentCameraIdx = (_currentCameraIdx - 1 + _cameras.length) % _cameras.length;
      return 'Failed to switch camera: $e';
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 5. TOGGLE MICROPHONE (Real hardware mute via track.enabled)
  // ────────────────────────────────────────────────────────────────────────────
  void toggleMicrophone() {
    _isMicMuted = !_isMicMuted;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMicMuted; // false = hardware muted
    });
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 6. TOGGLE VIDEO (Real hardware pause via track.enabled)
  // ────────────────────────────────────────────────────────────────────────────
  void toggleVideo() {
    _isVideoOff = !_isVideoOff;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !_isVideoOff; // false = black frame
    });
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 7. START SCREEN SHARING (getDisplayMedia)
  // ────────────────────────────────────────────────────────────────────────────
  Future<bool> startScreenShare() async {
    if (!kIsWeb) return false;

    _screenPermission = MediaPermissionState.requesting;
    notifyListeners();

    try {
      // getDisplayMedia shows native OS screen picker
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) throw Exception('MediaDevices not supported');
      
      final jsMediaDevices = js.JsObject.fromBrowserObject(mediaDevices);
      if (jsMediaDevices['getDisplayMedia'] == null) {
        throw Exception(
            'Screen sharing (getDisplayMedia) is not supported by your browser, or is disabled because this site is not running over HTTPS (secure context).');
      }

      final completer = Completer<html.MediaStream>();
      final promise = jsMediaDevices.callMethod('getDisplayMedia', [
        js.JsObject.jsify({'video': true, 'audio': true})
      ]);
      final jsPromise = js.JsObject.fromBrowserObject(promise);
      jsPromise.callMethod('then', [
        (stream) {
          completer.complete(stream as html.MediaStream);
        },
        (error) {
          completer.completeError(error);
        }
      ]);
      final stream = await completer.future;

      _screenStream = stream;
      _isScreenSharing = true;
      _screenPermission = MediaPermissionState.granted;

      // Listen for when user clicks "Stop Sharing" in browser UI
      stream.getVideoTracks().first.onEnded.listen((_) {
        _isScreenSharing = false;
        _screenStream = null;
        _screenPermission = MediaPermissionState.idle;
        notifyListeners();
      });

      notifyListeners();
      return true;
    } catch (e) {
      _isScreenSharing = false;
      _screenStream = null;
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('notallowed') || errStr.contains('permission')) {
        _screenPermission = MediaPermissionState.denied;
        _lastError = 'Screen sharing permission was denied.';
      } else {
        _screenPermission = MediaPermissionState.idle;
        _lastError = 'Screen sharing was cancelled or failed: $e';
      }
      notifyListeners();
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 8. STOP SCREEN SHARING
  // ────────────────────────────────────────────────────────────────────────────
  void stopScreenShare() {
    _screenStream?.getTracks().forEach((t) => t.stop());
    _screenStream = null;
    _isScreenSharing = false;
    _screenPermission = MediaPermissionState.idle;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 9. STOP ALL MEDIA (call end / dispose)
  // ────────────────────────────────────────────────────────────────────────────
  void stopAll() {
    _localStream?.getTracks().forEach((t) => t.stop());
    _screenStream?.getTracks().forEach((t) => t.stop());
    _localStream = null;
    _screenStream = null;
    _isInitialized = false;
    _isScreenSharing = false;
    _isMicMuted = false;
    _isVideoOff = false;
    _camPermission = MediaPermissionState.idle;
    _micPermission = MediaPermissionState.idle;
    _screenPermission = MediaPermissionState.idle;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 10. RESET for new call session
  // ────────────────────────────────────────────────────────────────────────────
  void resetForNewCall() {
    _isMicMuted = false;
    _isVideoOff = false;
    // Re-enable all tracks if they were muted from a previous call
    _localStream?.getAudioTracks().forEach((t) => t.enabled = true);
    _localStream?.getVideoTracks().forEach((t) => t.enabled = true);
    notifyListeners();
  }
}
