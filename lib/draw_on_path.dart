library draw_on_path;

import 'package:draw_on_path/utils.dart';
import 'package:flutter/material.dart';

enum TextAlignment { up, mid, bottom }

extension DrawOnPath on Canvas {
  /// draws [text] on [path] with [textStyle]
  ///
  /// It will clip [text] if it cannot fit itself in [path] for given [textStyle]
  ///
  /// [letterSpacing] is the space between 2 letters
  ///
  /// [letterSpacing] has no effect if [autoSpacing] is [true]
  ///
  /// [autoSpacing] will distribute your letters evenly
  ///
  /// Set [isClosed] to [true] if [path] is closed. This will put extra space at the end.
  /// [isClosed] has no effects if [autoSpacing] is [false]

  void drawTextOnPath(
    String text,
    Path path, {
    double startPoint = 0.0,
    TextStyle textStyle = const TextStyle(),
    double letterSpacing = 0.0,
    TextDirection textDirection = TextDirection.ltr,
    TextAlignment textAlignment = TextAlignment.mid,
  }) {
    if (text.isEmpty) {
      return;
    }

    final pathMetrics = path.computeMetrics();
    final pathMetricsList = pathMetrics.toList();

    int currentMetric = 0;
    double currDist = startPoint;

    for (int i = 0; i < text.length; i++) {
      final textPainter = getTextPainterFor(
        text[i],
        textStyle,
        textDirection: textDirection,
      );
      final charSize = textPainter.size;

      //startPoint<0일시(text가 path의 앞부분을 넘어갈시) text를 그리지 않음 
      if (currDist < 0) {
        currDist += charSize.width + letterSpacing;
      } else {
        final tangent = pathMetricsList[currentMetric]
            .getTangentForOffset(currDist + charSize.width / 2)!;

        final currLetterPos = tangent.position;
        final currLetterAngle = tangent.angle;

        save();
        translate(currLetterPos.dx, currLetterPos.dy);
        rotate(-currLetterAngle);
        textPainter.paint(
          this,
          currLetterPos
              .translate(
                -currLetterPos.dx,
                -currLetterPos.dy,
              )
              .translate(
                -charSize.width * 0.5,
                -charSize.height *
                    getTranslateYFactorForTextAlignment(textAlignment),
              ),
        );
        restore();
        currDist += charSize.width + letterSpacing; 

        if (currDist > pathMetricsList[currentMetric].length) {
          currDist = 0;
          currentMetric++;
        }

        if (currentMetric == pathMetricsList.length) {
          break;
        }
      }
    }
  }
}
