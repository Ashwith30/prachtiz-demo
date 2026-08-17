import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final double strokeWidth;

  const SparklineChart({
    super.key,
    required this.data,
    required this.lineColor,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SparklinePainter(data, lineColor, strokeWidth),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final double strokeWidth;

  _SparklinePainter(this.data, this.lineColor, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final double width = size.width;
    final double height = size.height;

    double minVal = data[0];
    double maxVal = data[0];
    for (double val in data) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
    }

    final double valRange = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    final double stepX = width / (data.length - 1);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = height - ((data[i] - minVal) / valRange * (height - 8)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withOpacity(0.20),
          lineColor.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
