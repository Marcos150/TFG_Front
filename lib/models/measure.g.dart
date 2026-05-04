// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Measure _$MeasureFromJson(Map<String, dynamic> json) => Measure(
  (json['left'] as num).toDouble(),
  (json['top'] as num).toDouble(),
  (json['right'] as num).toDouble(),
  (json['bottom'] as num).toDouble(),
);

Map<String, dynamic> _$MeasureToJson(Measure instance) => <String, dynamic>{
  'left': instance.left,
  'top': instance.top,
  'right': instance.right,
  'bottom': instance.bottom,
};
