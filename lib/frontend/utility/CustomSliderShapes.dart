import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomDividerShape extends SfDividerShape {
  @override
  void paint(PaintingContext context, Offset center, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection}) 
  {
    final bool isActive = center.dx >= startThumbCenter!.dx && center.dx <= endThumbCenter!.dx;
    if (!isActive) {
      context.canvas.drawCircle(center, 8.0,
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill
            ..color = const Color.fromARGB(255, 100, 100, 100));
    }
  }
}

class CustomTrackShape extends SfTrackShape {
  @override
  void paint(PaintingContext context, Offset offset, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Animation<double> enableAnimation,
      required Paint? inactivePaint,
      required Paint? activePaint,
      required TextDirection textDirection}) 
  {
    final Paint activePaint = Paint()
      ..color = const Color.fromARGB(255, 183, 236, 236)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    final Paint inactivePaint = Paint()
      ..color = const Color.fromARGB(255, 191, 191, 191)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    super.paint(context, offset, thumbCenter, startThumbCenter, endThumbCenter,
        parentBox: parentBox,
        themeData: themeData,
        enableAnimation: enableAnimation,
        inactivePaint: inactivePaint,
        activePaint: activePaint,
        textDirection: textDirection
    );
  }
}

class CustomThumbShape extends SfThumbShape {
  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    context.canvas.drawCircle(
      center,
      16.0,
      Paint()
        ..color = const Color.fromARGB(255, 183, 236, 236)
        ..style = PaintingStyle.fill
        ..strokeWidth = 10
    );
    context.canvas.drawCircle(
      center,
      8.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
    );
  }
}