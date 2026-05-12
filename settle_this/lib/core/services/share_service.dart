import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Capture a [RepaintBoundary] (looked up via [boundaryKey]) as a PNG and
  /// hand it to the OS share sheet.
  Future<void> shareCardImage({
    required GlobalKey boundaryKey,
    required String text,
    double pixelRatio = 1.5,
  }) async {
    final bytes = await capturePng(boundaryKey, pixelRatio: pixelRatio);
    if (bytes == null) return;
    final file = XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: 'settle-this-verdict.png',
    );
    await SharePlus.instance.share(
      ShareParams(files: [file], text: text),
    );
  }

  Future<Uint8List?> capturePng(
    GlobalKey boundaryKey, {
    double pixelRatio = 1.5,
  }) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
