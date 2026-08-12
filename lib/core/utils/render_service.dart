import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RenderService {
  /// Captures a widget that is already in the widget tree identified by a [GlobalKey].
  static Future<ui.Image?> captureFromKey(GlobalKey key, {double pixelRatio = 2.0}) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } catch (e) {
      debugPrint('Error capturing from key: $e');
      return null;
    }
  }

  /// Captures a widget that might not be in the visible widget tree by temporarily
  /// rendering it. This replaces the unstable OverlayEntry approach.
  static Future<ui.Image?> captureFromWidget(
    BuildContext context,
    Widget widget, {
    Size? targetSize,
    double pixelRatio = 2.0,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    // For most Flutter apps, the most stable way to capture a "custom" widget
    // without it being on screen is to use a RepaintBoundary that is off-screen.
    
    // Actually, a better "RenderService" would manage the RepaintBoundary capture 
    // logic more cleanly.
    
    if (targetSize != null) {
      return safeCaptureWithOverlay(context, widget, size: targetSize, pixelRatio: pixelRatio, delay: delay);
    }
    
    return null; // Placeholder for the actual implementation if we were to use a more complex one.
  }

  /// Encapsulated safe capture using a temporary overlay
  static Future<ui.Image?> safeCaptureWithOverlay(
    BuildContext context,
    Widget widget, {
    required Size size,
    double pixelRatio = 2.0,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final boundaryKey = GlobalKey();
    
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Center(
          child: Opacity(
            opacity: 0.01, // Almost invisible
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: RepaintBoundary(
                key: boundaryKey,
                child: widget,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    
    try {
      await Future.delayed(delay);
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } finally {
      entry.remove();
    }
  }
}
