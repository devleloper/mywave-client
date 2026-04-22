import 'package:flutter/material.dart';

class PlayerTransitionService {
  final ValueNotifier<double> expansionProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<double> deviceCornerRadius = ValueNotifier<double>(0.0);

  void updateProgress(double value) {
    expansionProgress.value = value.clamp(0.0, 1.0);
  }

  void setCornerRadius(double value) {
    deviceCornerRadius.value = value;
  }
}
