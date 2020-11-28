import 'package:flutter/material.dart';
import 'dart:math' as math show sin, pi;
import 'package:flutter/animation.dart';

class CurveWave extends Curve {
  const CurveWave();
  @override
  double transform(double t) {
    if (t == 0 || t == 1) {
      return 0.01;
    }

    return math.sin(t * math.pi);
  }
}
