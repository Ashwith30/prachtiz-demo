import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/loading/shimmer_placeholder.dart';

// Unified Brand Colors Match
const Color _kCardBg = Color(0xFF0C0E1F); // Unified Flat Dark Navy
final Color _kCardBorder = Colors.white.withOpacity(0.08); // Subtle white opacity border
Color _kBrandBlue = AppColors.primary; // Page Views Blue
const Color _kBrandGreen = Color(0xFF24C06F); // Unique Visitors Green
const Color _kBounceAmber = Color(0xFFF59E0B); // Bounce Rate Amber
const Color _kSessionPurple = Color(0xFF8B5CF6); // Session Purple
const Color _kTextGray = Color(0xFF94A3B8); // Muted grey text
const Color _kBarColor = Color(0xFF5F76FF); // Traffic bar color

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeframe = 'Last 12 months';
  bool _isLoading = false;
  int? _hoveredBarIndex;

  final List<String> _timeframeOptions = [
    'Today',
    'Last 7 days',
    'Last 30 days',
    'Last 12 months',
  ];

  // Mock datasets for different timeframes
  late Map<String, _TrafficStats> _datasets;

  @override
  void initState() {
    super.initState();
    _initDatasets();
  }

  void _initDatasets() {
    _datasets = {
      'Last 12 months': _TrafficStats(
        pageViews: '284,392',
        pageViewsChange: '+12.5% vs last period',
        pageViewsPositive: true,
        uniqueVisitors: '42,847',
        uniqueVisitorsChange: '+8.3% vs last period',
        uniqueVisitorsPositive: true,
        bounceRate: '32.4%',
        bounceRateChange: '-2.1% vs last period',
        bounceRatePositive: true, // positive for lower bounce rate (displayed in green/red appropriately)
        avgSession: '4m 32s',
        avgSessionChange: '+0.8m vs last period',
        avgSessionPositive: true,
        monthlyTraffic: [22, 25, 23, 28, 32, 31, 26, 33, 35, 32, 31, 34],
        directPercent: 42,
        referralPercent: 28,
        searchPercent: 18,
        socialPercent: 12,
        topPages: [
          _PageInfo(path: '/dashboard', views: '102,482', unique: '24,180', bounce: '28.4%', avgTime: '3m 42s'),
          _PageInfo(path: '/appointments', views: '84,390', unique: '18,242', bounce: '31.2%', avgTime: '4m 15s'),
          _PageInfo(path: '/patient-overview', views: '42,810', unique: '9,184', bounce: '24.5%', avgTime: '5m 08s'),
          _PageInfo(path: '/health-records', views: '28,490', unique: '6,842', bounce: '34.2%', avgTime: '2m 50s'),
          _PageInfo(path: '/telemedicine', views: '18,430', unique: '4,204', bounce: '42.0%', avgTime: '6m 12s'),
          _PageInfo(path: '/billing', views: '7,790', unique: '2,198', bounce: '18.5%', avgTime: '2m 10s'),
        ],
      ),
      'Last 30 days': _TrafficStats(
        pageViews: '28,190',
        pageViewsChange: '+15.2% vs last period',
        pageViewsPositive: true,
        uniqueVisitors: '4,812',
        uniqueVisitorsChange: '+9.4% vs last period',
        uniqueVisitorsPositive: true,
        bounceRate: '31.8%',
        bounceRateChange: '-1.8% vs last period',
        bounceRatePositive: true,
        avgSession: '4m 15s',
        avgSessionChange: '+0.5m vs last period',
        avgSessionPositive: true,
        monthlyTraffic: [12, 14, 15, 13, 17, 18, 19, 16, 17, 18, 20, 22],
        directPercent: 40,
        referralPercent: 30,
        searchPercent: 20,
        socialPercent: 10,
        topPages: [
          _PageInfo(path: '/dashboard', views: '10,248', unique: '2,418', bounce: '28.1%', avgTime: '3m 38s'),
          _PageInfo(path: '/appointments', views: '8,439', unique: '1,824', bounce: '30.8%', avgTime: '4m 10s'),
          _PageInfo(path: '/patient-overview', views: '4,281', unique: '918', bounce: '23.8%', avgTime: '5m 02s'),
          _PageInfo(path: '/health-records', views: '2,849', unique: '684', bounce: '33.9%', avgTime: '2m 45s'),
          _PageInfo(path: '/telemedicine', views: '1,843', unique: '420', bounce: '41.5%', avgTime: '6m 05s'),
          _PageInfo(path: '/billing', views: '779', unique: '219', bounce: '18.1%', avgTime: '2m 05s'),
        ],
      ),
      'Last 7 days': _TrafficStats(
        pageViews: '7,420',
        pageViewsChange: '+4.8% vs last period',
        pageViewsPositive: true,
        uniqueVisitors: '1,220',
        uniqueVisitorsChange: '+2.1% vs last period',
        uniqueVisitorsPositive: true,
        bounceRate: '33.1%',
        bounceRateChange: '+1.2% vs last period',
        bounceRatePositive: false,
        avgSession: '3m 58s',
        avgSessionChange: '-0.2m vs last period',
        avgSessionPositive: false,
        monthlyTraffic: [8, 9, 7, 8, 10, 11, 9, 10, 11, 10, 11, 12],
        directPercent: 38,
        referralPercent: 32,
        searchPercent: 22,
        socialPercent: 8,
        topPages: [
          _PageInfo(path: '/dashboard', views: '2,450', unique: '580', bounce: '30.2%', avgTime: '3m 22s'),
          _PageInfo(path: '/appointments', views: '2,110', unique: '460', bounce: '32.1%', avgTime: '3m 55s'),
          _PageInfo(path: '/patient-overview', views: '1,020', unique: '230', bounce: '26.8%', avgTime: '4m 42s'),
          _PageInfo(path: '/health-records', views: '710', unique: '170', bounce: '35.4%', avgTime: '2m 38s'),
          _PageInfo(path: '/telemedicine', views: '430', unique: '90', bounce: '43.2%', avgTime: '5m 50s'),
          _PageInfo(path: '/billing', views: '190', unique: '50', bounce: '19.8%', avgTime: '1m 58s'),
        ],
      ),
      'Today': _TrafficStats(
        pageViews: '1,840',
        pageViewsChange: '+8.2% vs last period',
        pageViewsPositive: true,
        uniqueVisitors: '310',
        uniqueVisitorsChange: '+5.5% vs last period',
        uniqueVisitorsPositive: true,
        bounceRate: '29.5%',
        bounceRateChange: '-4.1% vs last period',
        bounceRatePositive: true,
        avgSession: '4m 45s',
        avgSessionChange: '+1.1m vs last period',
        avgSessionPositive: true,
        monthlyTraffic: [4, 5, 4, 6, 8, 7, 6, 8, 9, 7, 8, 10],
        directPercent: 45,
        referralPercent: 25,
        searchPercent: 18,
        socialPercent: 12,
        topPages: [
          _PageInfo(path: '/dashboard', views: '580', unique: '130', bounce: '25.4%', avgTime: '3m 52s'),
          _PageInfo(path: '/appointments', views: '490', unique: '110', bounce: '28.1%', avgTime: '4m 30s'),
          _PageInfo(path: '/patient-overview', views: '290', unique: '60', bounce: '21.2%', avgTime: '5m 12s'),
          _PageInfo(path: '/health-records', views: '180', unique: '40', bounce: '30.1%', avgTime: '3m 10s'),
          _PageInfo(path: '/telemedicine', views: '110', unique: '20', bounce: '38.5%', avgTime: '6m 24s'),
          _PageInfo(path: '/billing', views: '40', unique: '10', bounce: '15.2%', avgTime: '2m 15s'),
        ],
      ),
    };
  }

  void _onTimeframeChanged(String value) {
    setState(() {
      _selectedTimeframe = value;
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;
    final gap = width < 700 ? 12.0 : 16.0;

    final currentData = _datasets[_selectedTimeframe] ?? _datasets['Last 12 months']!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: width < 700 ? 12.0 : AppDimensions.pagePaddingHorizontal,
          vertical: AppDimensions.pagePaddingVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header & Action Row
            _buildTitleRow(context),
            SizedBox(height: gap),

            if (_isLoading)
              _buildSkeletons(isDesktop, isTablet, gap)
            else ...[
              // KPI Cards Row
              _buildKPIGrid(isDesktop, isTablet, currentData, gap)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
              SizedBox(height: gap),

              // Monthly Traffic & Sources Grid
              _buildMiddleSection(isDesktop, currentData, gap)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 320.ms)
                  .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
              SizedBox(height: gap),

              // Top Pages Table Section
              _buildTopPagesCard(currentData)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 320.ms)
                  .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
            ]
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TITLE ROW & DROPDOWNS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B8EFF), // Unified light electric brand blue
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Track your clinic's performance and key metrics.",
              style: GoogleFonts.inter(
                color: _kTextGray,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Timeframe Selector dropdown
            PopupMenuButton<String>(
              onSelected: _onTimeframeChanged,
              color: _kCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: _kCardBorder),
              ),
              itemBuilder: (context) {
                return _timeframeOptions.map((opt) {
                  final isSelected = opt == _selectedTimeframe;
                  return PopupMenuItem<String>(
                    value: opt,
                    child: Text(
                      opt,
                      style: GoogleFonts.inter(
                        color: isSelected ? const Color(0xFF315BFF) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kCardBorder),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedTimeframe,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Export Button
            Material(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kCardBg,
                      content: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text('Exporting data report...', style: GoogleFonts.inter(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_download_outlined, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'Export',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // KPI METRICS GRID (4 Columns)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildKPIGrid(bool isDesktop, bool isTablet, _TrafficStats data, double gap) {
    final kpis = [
      _KPICardItem(
        title: 'Page Views',
        value: data.pageViews,
        change: data.pageViewsChange,
        positive: data.pageViewsPositive,
        icon: Icons.visibility,
        color: _kBrandBlue,
      ),
      _KPICardItem(
        title: 'Unique Visitors',
        value: data.uniqueVisitors,
        change: data.uniqueVisitorsChange,
        positive: data.uniqueVisitorsPositive,
        icon: Icons.group,
        color: _kBrandGreen,
      ),
      _KPICardItem(
        title: 'Bounce Rate',
        value: data.bounceRate,
        change: data.bounceRateChange,
        positive: data.bounceRatePositive, // True = Downwards is good for bounce rate
        icon: Icons.trending_down,
        color: _kBounceAmber,
        isBounceRate: true,
      ),
      _KPICardItem(
        title: 'Avg. Session',
        value: data.avgSession,
        change: data.avgSessionChange,
        positive: data.avgSessionPositive,
        icon: Icons.timer,
        color: _kSessionPurple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = isDesktop ? 4 : (isTablet ? 2 : 1);
        final itemWidth = (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: kpis.map((kpi) {
            return SizedBox(
              width: itemWidth,
              child: _InteractiveKPICard(kpi: kpi),
            );
          }).toList(),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MIDDLE SECTION (Bar Chart & Donut Chart side by side)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMiddleSection(bool isDesktop, _TrafficStats data, double gap) {
    final barChartCard = AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Patient Traffic',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Visits per month this year',
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _kBarColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '2025',
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive bar rod widths based on layout constraint
              final double barWidth = constraints.maxWidth < 350
                  ? 12.0
                  : (constraints.maxWidth < 550
                      ? 18.0
                      : (constraints.maxWidth < 800 ? 24.0 : 28.0));

              return SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: 40,
                    barTouchData: BarTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.spot == null) {
                            _hoveredBarIndex = null;
                            return;
                          }
                          _hoveredBarIndex = response.spot!.touchedBarGroupIndex;
                        });
                      },
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: const Color(0xFF1E293B),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()}k visits',
                            GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (val) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.04),
                          strokeWidth: 1.0,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${value.toInt()}k',
                                style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, meta) {
                            const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
                            final index = value.toInt();
                            if (index < 0 || index >= months.length) return const SizedBox.shrink();
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                months[index],
                                style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(data.monthlyTraffic.length, (index) {
                      final isHovered = _hoveredBarIndex == index;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data.monthlyTraffic[index].toDouble(),
                            color: isHovered ? _kBarColor.withOpacity(0.8) : _kBarColor,
                            width: barWidth,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    final donutCard = AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Traffic Sources',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Where patients come from',
            style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                // Left donut chart
                Expanded(
                  flex: 5,
                  child: Stack(
                     alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 36,
                          sectionsSpace: 3,
                          startDegreeOffset: 270,
                          sections: [
                            PieChartSectionData(
                              value: data.directPercent.toDouble(),
                              color: _kBrandBlue,
                              radius: 22,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: data.referralPercent.toDouble(),
                              color: _kBrandGreen,
                              radius: 22,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: data.searchPercent.toDouble(),
                              color: const Color(0xFF0EA5E9),
                              radius: 22,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: data.socialPercent.toDouble(),
                              color: const Color(0xFFF59E0B),
                              radius: 22,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '100%',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'All sources',
                            style: GoogleFonts.inter(
                              color: _kTextGray,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Right progress breakdowns list
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSourceProgressRow(
                        label: 'Direct',
                        percent: data.directPercent,
                        color: _kBrandBlue,
                      ),
                      _buildSourceProgressRow(
                        label: 'Referral',
                        percent: data.referralPercent,
                        color: _kBrandGreen,
                      ),
                      _buildSourceProgressRow(
                        label: 'Search',
                        percent: data.searchPercent,
                        color: const Color(0xFF0EA5E9),
                      ),
                      _buildSourceProgressRow(
                        label: 'Social',
                        percent: data.socialPercent,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return SizedBox(
        height: 350,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 7, child: barChartCard),
            SizedBox(width: gap),
            Expanded(flex: 5, child: donutCard),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          SizedBox(height: 350, child: barChartCard),
          SizedBox(height: gap),
          SizedBox(height: 280, child: donutCard),
        ],
      );
    }
  }

  Widget _buildSourceProgressRow({
    required String label,
    required int percent,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '$percent%',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TOP PAGES TABLE CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTopPagesCard(_TrafficStats data) {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Pages',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Most visited sections this period',
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAllPagesDialog(context, data),
                child: Row(
                  children: [
                    Text('View All', style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 12.5, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 12, color: _kBrandBlue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Data Table for paths
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: DataTable(
                columnSpacing: 38,
                horizontalMargin: 8,
                headingRowHeight: 40,
                dataRowMinHeight: 46,
                dataRowMaxHeight: 46,
                columns: [
                  DataColumn(label: Text('PAGE PATH', style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('PAGE VIEWS', style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('UNIQUE VISITORS', style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('BOUNCE RATE', style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('AVG. TIME', style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.w700))),
                ],
                rows: data.topPages.map((page) {
                  return DataRow(
                    cells: [
                      DataCell(Text(page.path, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600))),
                      DataCell(Text(page.views, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                      DataCell(Text(page.unique, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                      DataCell(Text(page.bounce, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                      DataCell(Text(page.avgTime, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SHIMMER SKELETONS FOR LOADING STATE
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSkeletons(bool isDesktop, bool isTablet, double gap) {
    return Column(
      children: [
        // 4 KPI skeletons
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = isDesktop ? 4 : (isTablet ? 2 : 1);
            final itemWidth = (constraints.maxWidth - ((columns - 1) * gap)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(4, (index) {
                return ShimmerPlaceholder(
                  height: 104,
                  width: itemWidth,
                  borderRadius: AppRadius.radius12,
                );
              }),
            );
          },
        ),
        SizedBox(height: gap),
        // Middle block skeletons
        Row(
          children: [
            Expanded(
              flex: 7,
              child: ShimmerPlaceholder(
                height: 310,
                width: double.infinity,
                borderRadius: AppRadius.radius12,
              ),
            ),
            if (isDesktop) ...[
              SizedBox(width: gap),
              Expanded(
                flex: 5,
                child: ShimmerPlaceholder(
                  height: 310,
                  width: double.infinity,
                  borderRadius: AppRadius.radius12,
                ),
              ),
            ]
          ],
        ),
        SizedBox(height: gap),
        // Table skeleton
        ShimmerPlaceholder(
          height: 340,
          width: double.infinity,
          borderRadius: AppRadius.radius12,
        ),
      ],
    ).animate().fadeIn(duration: 150.ms);
  }

  void _showAllPagesDialog(BuildContext context, _TrafficStats data) {
    showDialog(
      context: context,
      builder: (context) {
        return _AllPagesDialog(
          themeBg: _kCardBg,
          themeBorderColor: _kCardBorder,
          textGray: _kTextGray,
          brandBlue: _kBrandBlue,
          initialPages: data.topPages,
          selectedTimeframe: _selectedTimeframe,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive KPI Card Widget with hover interactions
// ─────────────────────────────────────────────────────────────────────────────
class _InteractiveKPICard extends StatefulWidget {
  final _KPICardItem kpi;
  const _InteractiveKPICard({required this.kpi});

  @override
  State<_InteractiveKPICard> createState() => _InteractiveKPICardState();
}

class _InteractiveKPICardState extends State<_InteractiveKPICard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final kpi = widget.kpi;
    Color trendColor = _kBrandGreen;
    if (kpi.isBounceRate) {
      trendColor = kpi.positive ? _kBrandGreen : AppColors.danger;
    } else {
      trendColor = kpi.positive ? _kBrandGreen : AppColors.danger;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0, 0.0)
          ..scale(_isHovered ? 1.01 : 1.0),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: AppRadius.radius12,
          border: Border.all(
            color: _isHovered ? kpi.color.withOpacity(0.4) : _kCardBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.15),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
            if (_isHovered)
              BoxShadow(
                color: kpi.color.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kpi.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(kpi.icon, color: kpi.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kpi.title,
                    style: GoogleFonts.inter(
                      color: _kTextGray,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    kpi.value,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        kpi.positive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 11,
                        color: trendColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        kpi.change,
                        style: GoogleFonts.inter(
                          color: trendColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data models mapping
class _TrafficStats {
  final String pageViews;
  final String pageViewsChange;
  final bool pageViewsPositive;

  final String uniqueVisitors;
  final String uniqueVisitorsChange;
  final bool uniqueVisitorsPositive;

  final String bounceRate;
  final String bounceRateChange;
  final bool bounceRatePositive;

  final String avgSession;
  final String avgSessionChange;
  final bool avgSessionPositive;

  final List<int> monthlyTraffic;

  final int directPercent;
  final int referralPercent;
  final int searchPercent;
  final int socialPercent;

  final List<_PageInfo> topPages;

  _TrafficStats({
    required this.pageViews,
    required this.pageViewsChange,
    required this.pageViewsPositive,
    required this.uniqueVisitors,
    required this.uniqueVisitorsChange,
    required this.uniqueVisitorsPositive,
    required this.bounceRate,
    required this.bounceRateChange,
    required this.bounceRatePositive,
    required this.avgSession,
    required this.avgSessionChange,
    required this.avgSessionPositive,
    required this.monthlyTraffic,
    required this.directPercent,
    required this.referralPercent,
    required this.searchPercent,
    required this.socialPercent,
    required this.topPages,
  });
}

class _PageInfo {
  final String path;
  final String views;
  final String unique;
  final String bounce;
  final String avgTime;

  _PageInfo({
    required this.path,
    required this.views,
    required this.unique,
    required this.bounce,
    required this.avgTime,
  });
}

class _KPICardItem {
  final String title;
  final String value;
  final String change;
  final bool positive;
  final IconData icon;
  final Color color;
  final bool isBounceRate;

  _KPICardItem({
    required this.title,
    required this.value,
    required this.change,
    required this.positive,
    required this.icon,
    required this.color,
    this.isBounceRate = false,
  });
}

class _AllPagesDialog extends StatefulWidget {
  final Color themeBg;
  final Color themeBorderColor;
  final Color textGray;
  final Color brandBlue;
  final List<_PageInfo> initialPages;
  final String selectedTimeframe;

  const _AllPagesDialog({
    required this.themeBg,
    required this.themeBorderColor,
    required this.textGray,
    required this.brandBlue,
    required this.initialPages,
    required this.selectedTimeframe,
  });

  @override
  State<_AllPagesDialog> createState() => _AllPagesDialogState();
}

class _AllPagesDialogState extends State<_AllPagesDialog> {
  late List<_PageInfo> _allPages;
  late List<_PageInfo> _filteredPages;
  final TextEditingController _searchController = TextEditingController();
  String _sortColumn = 'views';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _allPages = List.from(widget.initialPages);
    
    final extraPages = [
      _PageInfo(path: '/prescriptions', views: '6,420', unique: '1,890', bounce: '22.1%', avgTime: '3m 15s'),
      _PageInfo(path: '/lab-results', views: '5,890', unique: '1,720', bounce: '19.4%', avgTime: '4m 02s'),
      _PageInfo(path: '/settings/profile', views: '4,120', unique: '980', bounce: '35.8%', avgTime: '1m 55s'),
      _PageInfo(path: '/messages', views: '3,840', unique: '890', bounce: '12.4%', avgTime: '7m 45s'),
      _PageInfo(path: '/insurance', views: '2,910', unique: '740', bounce: '28.9%', avgTime: '3m 30s'),
      _PageInfo(path: '/help-center', views: '1,750', unique: '610', bounce: '44.2%', avgTime: '2m 12s'),
      _PageInfo(path: '/notifications', views: '980', unique: '430', bounce: '10.5%', avgTime: '0m 45s'),
    ];

    if (widget.selectedTimeframe == 'Today') {
      _allPages = widget.initialPages.map((p) => p).toList();
      _allPages.addAll([
        _PageInfo(path: '/prescriptions', views: '120', unique: '35', bounce: '20.0%', avgTime: '3m 05s'),
        _PageInfo(path: '/lab-results', views: '98', unique: '28', bounce: '18.2%', avgTime: '3m 50s'),
        _PageInfo(path: '/settings/profile', views: '76', unique: '15', bounce: '32.1%', avgTime: '1m 40s'),
        _PageInfo(path: '/messages', views: '62', unique: '20', bounce: '11.5%', avgTime: '6m 20s'),
      ]);
    } else if (widget.selectedTimeframe == 'Last 7 days') {
      _allPages = widget.initialPages.map((p) => p).toList();
      _allPages.addAll([
        _PageInfo(path: '/prescriptions', views: '520', unique: '145', bounce: '21.5%', avgTime: '3m 10s'),
        _PageInfo(path: '/lab-results', views: '430', unique: '110', bounce: '19.0%', avgTime: '3m 55s'),
        _PageInfo(path: '/settings/profile', views: '310', unique: '80', bounce: '34.5%', avgTime: '1m 48s'),
        _PageInfo(path: '/messages', views: '280', unique: '75', bounce: '12.0%', avgTime: '7m 10s'),
      ]);
    } else {
      _allPages.addAll(extraPages);
    }

    _filteredPages = List.from(_allPages);
    _sortPages();
    _searchController.addListener(_filterPages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPages = _allPages.where((page) {
        return page.path.toLowerCase().contains(query);
      }).toList();
      _sortPages();
    });
  }

  void _sort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = false;
      }
      _sortPages();
    });
  }

  int _parseNumber(String val) {
    return int.tryParse(val.replaceAll(',', '')) ?? 0;
  }

  double _parsePercent(String val) {
    return double.tryParse(val.replaceAll('%', '')) ?? 0.0;
  }

  int _parseDuration(String val) {
    final parts = val.split(' ');
    int seconds = 0;
    for (var part in parts) {
      if (part.contains('m')) {
        seconds += (int.tryParse(part.replaceAll('m', '')) ?? 0) * 60;
      } else if (part.contains('s')) {
        seconds += int.tryParse(part.replaceAll('s', '')) ?? 0;
      }
    }
    return seconds;
  }

  void _sortPages() {
    _filteredPages.sort((a, b) {
      int cmp = 0;
      switch (_sortColumn) {
        case 'path':
          cmp = a.path.compareTo(b.path);
          break;
        case 'views':
          cmp = _parseNumber(a.views).compareTo(_parseNumber(b.views));
          break;
        case 'unique':
          cmp = _parseNumber(a.unique).compareTo(_parseNumber(b.unique));
          break;
        case 'bounce':
          cmp = _parsePercent(a.bounce).compareTo(_parsePercent(b.bounce));
          break;
        case 'avgTime':
          cmp = _parseDuration(a.avgTime).compareTo(_parseDuration(b.avgTime));
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = width > 950 ? 900.0 : width * 0.92;

    return Dialog(
      backgroundColor: widget.themeBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.themeBorderColor),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.80,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Pages Performance',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Detailed view of page path settlements (${widget.selectedTimeframe})',
                      style: GoogleFonts.inter(color: widget.textGray, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                hintText: 'Filter by page path (e.g. /appointments)...',
                hintStyle: GoogleFonts.inter(color: widget.textGray.withOpacity(0.6), fontSize: 13),
                prefixIcon: Icon(Icons.search, color: widget.textGray, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.themeBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.brandBlue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: dialogWidth - 48),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.white.withOpacity(0.08),
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 8,
                        headingRowHeight: 40,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 48,
                        sortColumnIndex: _sortColumn == 'path' ? 0 : (_sortColumn == 'views' ? 1 : (_sortColumn == 'unique' ? 2 : (_sortColumn == 'bounce' ? 3 : 4))),
                        sortAscending: _sortAscending,
                        columns: [
                          DataColumn(
                            onSort: (_, __) => _sort('path'),
                            label: Row(
                              children: [
                                Text('PAGE PATH', style: GoogleFonts.inter(color: widget.textGray, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(_sortColumn == 'path' ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more, size: 12, color: widget.textGray),
                              ],
                            ),
                          ),
                          DataColumn(
                            onSort: (_, __) => _sort('views'),
                            label: Row(
                              children: [
                                Text('PAGE VIEWS', style: GoogleFonts.inter(color: widget.textGray, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(_sortColumn == 'views' ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more, size: 12, color: widget.textGray),
                              ],
                            ),
                          ),
                          DataColumn(
                            onSort: (_, __) => _sort('unique'),
                            label: Row(
                              children: [
                                Text('UNIQUE VISITORS', style: GoogleFonts.inter(color: widget.textGray, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(_sortColumn == 'unique' ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more, size: 12, color: widget.textGray),
                              ],
                            ),
                          ),
                          DataColumn(
                            onSort: (_, __) => _sort('bounce'),
                            label: Row(
                              children: [
                                Text('BOUNCE RATE', style: GoogleFonts.inter(color: widget.textGray, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(_sortColumn == 'bounce' ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more, size: 12, color: widget.textGray),
                              ],
                            ),
                          ),
                          DataColumn(
                            onSort: (_, __) => _sort('avgTime'),
                            label: Row(
                              children: [
                                Text('AVG. TIME', style: GoogleFonts.inter(color: widget.textGray, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(_sortColumn == 'avgTime' ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more, size: 12, color: widget.textGray),
                              ],
                            ),
                          ),
                        ],
                        rows: _filteredPages.map((page) {
                          return DataRow(
                            cells: [
                              DataCell(Text(page.path, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600))),
                              DataCell(Text(page.views, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                              DataCell(Text(page.unique, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                              DataCell(Text(page.bounce, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                              DataCell(Text(page.avgTime, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
