import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/animations/hover_animation.dart';
import '../../domain/models/dashboard_banner_model.dart';

class HeroSection extends StatelessWidget {
  final DashboardBannerModel bannerData;

  const HeroSection({
    super.key,
    required this.bannerData,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isMobile = screenWidth <= 768;

    return HoverAnimation(
      scale: 1.01,
      translateUp: 2.0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF13294B),
              Color(0xFF315BFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.radius18,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF13294B).withOpacity(0.16),
              offset: const Offset(0, 10),
              blurRadius: 28,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  color: const Color(0xFF24C06F).withOpacity(0.08),
                ),
              ),
            ),

            // Content Row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Clipboard & Schedule details
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clipboard Icon Stack
                        if (!isMobile) ...[
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.assignment_outlined,
                                color: Colors.white,
                                size: 36,
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: const BoxDecoration(
                                    color: Color(
                                        0xFF24C06F), // Glowing brand green check
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 9.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 22),
                        ],

                        // Schedule Details Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                bannerData.greeting,
                                style: AppTypography.sectionTitle.copyWith(
                                  color: Colors.white,
                                  fontSize: isMobile ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Shift 1
                              Row(
                                children: [
                                  const Text(
                                    "9:00 AM - 12:00 PM",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF24C06F)
                                          .withOpacity(
                                              0.15), // transparent green
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFF24C06F)
                                              .withOpacity(0.3),
                                          width: 1),
                                    ),
                                    child: const Text(
                                      "Morning Shift",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Shift 2
                              Row(
                                children: [
                                  const Text(
                                    "2:00 PM - 6:00 PM",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B)
                                          .withOpacity(
                                              0.15), // transparent orange
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFF59E0B)
                                              .withOpacity(0.3),
                                          width: 1),
                                    ),
                                    child: const Text(
                                      "Afternoon Shift",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Meta info
                              Wrap(
                                spacing: 18,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _buildMetaItem(Icons.access_time_outlined,
                                      bannerData.loginTimeText),
                                  _buildMetaItem(Icons.place_outlined,
                                      bannerData.locationText),
                                  _buildMetaItem(Icons.calendar_today_outlined,
                                      bannerData.dateRangeText),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Analogue Clock
                  if (!isMobile) ...[
                    const SizedBox(width: 20),
                    const AnalogueClock(size: 98.0),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFC7D2FE),
          size: 13.5,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFC7D2FE),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class AnalogueClock extends StatefulWidget {
  final double size;

  const AnalogueClock({
    super.key,
    this.size = 80.0,
  });

  @override
  State<AnalogueClock> createState() => _AnalogueClockState();
}

class _AnalogueClockState extends State<AnalogueClock> {
  Timer? _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();

    final bool isTesting = WidgetsBinding.instance.toString().contains('Test');
    if (!isTesting) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ClockPainter(_currentTime),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime dateTime;

  _ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(size.width, size.height) / 2;
    final center = Offset(centerX, centerY);

    // Frosted glass background
    final paintOuter = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintOuter);

    // Inner frosted ring
    final paintGlass = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 4, paintGlass);

    // Semi-transparent border
    final paintBorder = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, radius, paintBorder);

    // Clock ticks
    final paintTick = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 12; i++) {
      final double angle = i * 30 * math.pi / 180;
      final start = Offset(
        centerX + (radius - 5) * math.cos(angle),
        centerY + (radius - 5) * math.sin(angle),
      );
      final end = Offset(
        centerX + (radius - 1) * math.cos(angle),
        centerY + (radius - 1) * math.sin(angle),
      );
      canvas.drawLine(start, end, paintTick);
    }

    final double hourAngle =
        (dateTime.hour % 12 + dateTime.minute / 60) * 30 * math.pi / 180 -
            math.pi / 2;
    final double minuteAngle =
        (dateTime.minute + dateTime.second / 60) * 6 * math.pi / 180 -
            math.pi / 2;
    final double secondAngle =
        dateTime.second * 6 * math.pi / 180 - math.pi / 2;

    final hourHandLength = radius * 0.48;
    final paintHour = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(centerX + hourHandLength * math.cos(hourAngle),
          centerY + hourHandLength * math.sin(hourAngle)),
      paintHour,
    );

    final minuteHandLength = radius * 0.7;
    final paintMinute = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(centerX + minuteHandLength * math.cos(minuteAngle),
          centerY + minuteHandLength * math.sin(minuteAngle)),
      paintMinute,
    );

    // Brand Green sweeping hand
    final secondHandLength = radius * 0.82;
    final paintSecond = Paint()
      ..color = const Color(0xFF24C06F)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(centerX + secondHandLength * math.cos(secondAngle),
          centerY + secondHandLength * math.sin(secondAngle)),
      paintSecond,
    );

    final paintPin = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, paintPin);

    final paintPinCenter = Paint()
      ..color = const Color(0xFF24C06F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.2, paintPinCenter);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) {
    return oldDelegate.dateTime.second != dateTime.second;
  }
}
