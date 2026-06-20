import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../data/dummy/dashboard_dummy.dart';
import '../sections/hero_section.dart';
import '../sections/summary_section.dart';
import '../sections/appointment_section.dart';
import '../sections/calendar_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingHorizontal,
          vertical: AppDimensions.pagePaddingVertical,
        ),
        physics: const BouncingScrollPhysics(),
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            final isDesktop = deviceType.isDesktop;
            final screenWidth = MediaQuery.sizeOf(context).width;
            final dashboardGap = screenWidth < 700 ? 16.0 : 20.0;
            final queueHeight = screenWidth >= 1400 ? 640.0 : 612.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero / Schedule Banner Section
                HeroSection(bannerData: DashboardDummy.bannerData)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: dashboardGap),

                // 2. Summary / Metrics Section (Appointments Today, Sub-cards grid, Upcoming card)
                const SummarySection()
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: dashboardGap),

                // 3. Columns: Calendar Section (Left) and Appointment Queue (Right)
                if (isDesktop)
                  SizedBox(
                    height: queueHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: CalendarSection(
                              events: DashboardDummy.calendarEvents),
                        ),
                        SizedBox(width: dashboardGap),
                        Expanded(
                          flex: 7,
                          child: AppointmentSection(
                              appointments: DashboardDummy.appointments),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 450.ms)
                      .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad)
                else
                  Column(
                    children: [
                      CalendarSection(events: DashboardDummy.calendarEvents),
                      SizedBox(height: dashboardGap),
                      AppointmentSection(
                          appointments: DashboardDummy.appointments),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 450.ms)
                      .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
              ],
            );
          },
        ),
      ),
    );
  }
}
