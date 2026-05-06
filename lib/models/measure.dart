import 'dart:ui' show Rect;

import 'package:json_annotation/json_annotation.dart';

part 'measure.g.dart';

@JsonSerializable()
class Measure extends Rect {
  const Measure(super.left, super.top, super.right, super.bottom) : super.fromLTRB();

  Measure.fromPoints(super.a, super.b) : super.fromPoints();

  factory Measure.fromJson(Map<String, dynamic> json) =>
      _$MeasureFromJson(json);

  Map<String, dynamic> toJson() => _$MeasureToJson(this);
}