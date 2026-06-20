import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/charts/sparkline_chart.dart';
import '../../domain/models/summary_card_model.dart';
import '../../data/dummy/dashboard_dummy.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 1100;
    final bool isTablet = screenWidth >= 650 && screenWidth < 1100;

    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left card: TOTAL APPOINTMENTS TODAY
            Expanded(
              flex: 3,
              child: _buildLargeMetricCard(
                card: DashboardDummy.totalAppointments,
                isDarkNavy: true,
              ),
            ),
            const SizedBox(width: 16),
            
            // Middle: 3x2 Grid of dark sub-cards (3 columns)
            Expanded(
              flex: 6,
              child: _buildSubCardsGrid(16, columns: 3),
            ),
            const SizedBox(width: 16),
            
            // Right card: UPCOMING THIS WEEK
            Expanded(
              flex: 3,
              child: _buildLargeMetricCard(
                card: DashboardDummy.upcomingThisWeek,
                isGreenGradient: true,
              ),
            ),
          ],
        ),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLargeMetricCard(
                  card: DashboardDummy.totalAppointments,
                  isDarkNavy: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLargeMetricCard(
                  card: DashboardDummy.upcomingThisWeek,
                  isGreenGradient: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSubCardsGrid(16, columns: 3),
        ],
      );
    } else {
      // Mobile
      return Column(
        children: [
          _buildLargeMetricCard(
            card: DashboardDummy.totalAppointments,
            isDarkNavy: true,
          ),
          const SizedBox(height: 16),
          _buildSubCardsGrid(16, columns: 2),
          const SizedBox(height: 16),
          _buildLargeMetricCard(
            card: DashboardDummy.upcomingThisWeek,
            isGreenGradient: true,
          ),
        ],
      );
    }
  }

  Widget _buildLargeMetricCard({
    required SummaryCardModel card,
    bool isDarkNavy = false,
    bool isGreenGradient = false,
  }) {
    return _InteractiveMetricCard(
      card: card,
      isDarkNavy: isDarkNavy,
      isGreenGradient: isGreenGradient,
    );
  }

  Widget _buildSubCardsGrid(double spacing, {required int columns}) {
    List<Widget> rows = [];
    List<SummaryCardModel> cards = DashboardDummy.middleCards;
    
    for (int i = 0; i < cards.length; i += columns) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < columns; j++) {
        if (i + j < cards.length) {
          if (j > 0) rowChildren.add(SizedBox(width: spacing));
          rowChildren.add(Expanded(child: _InteractiveSubCard(card: cards[i + j])));
        }
      }
      if (i > 0) rows.add(SizedBox(height: spacing));
      rows.add(Row(children: rowChildren));
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rows,
    );
  }
}

class _InteractiveMetricCard extends StatefulWidget {
  final SummaryCardModel card;
  final bool isDarkNavy;
  final bool isGreenGradient;

  const _InteractiveMetricCard({
    required this.card,
    this.isDarkNavy = false,
    this.isGreenGradient = false,
  });

  @override
  State<_InteractiveMetricCard> createState() => _InteractiveMetricCardState();
}

class _InteractiveMetricCardState extends State<_InteractiveMetricCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDarkNavy 
        ? const Color(0xFF315BFF) 
        : (widget.isGreenGradient ? Color(0xFF24C06F) : AppColors.primary);

    final titleColor = const Color(0xFF94A3B8);
    final valueColor = widget.isDarkNavy ? Colors.white : const Color(0xFF24C06F);

    final borderColor = _isHovered 
        ? cardColor.withOpacity(0.3) 
        : Colors.white.withOpacity(0.08);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0, 0.0)
          ..scale(_isHovered ? 1.012 : 1.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0E1F), // Unified Flat Dark Navy
          borderRadius: AppRadius.radius18,
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.22 : 0.15),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Side border glow stripe
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _isHovered ? 5.0 : 4.0,
                decoration: BoxDecoration(
                  color: cardColor, // Opaque stripe
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Icon + Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.card.icon,
                          color: cardColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.card.title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bottom Row: Value + Trend + Sparkline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animating Number on Load
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1.0 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              widget.card.value,
                              style: AppTypography.cardValue.copyWith(
                                color: valueColor,
                                fontSize: 38,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (_pulseController.value * 0.15),
                                    child: child,
                                  );
                                },
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Color(0xFF24C06F),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.isDarkNavy ? "+2 from yesterday" : "+8 from last week",
                                style: const TextStyle(
                                  color: Color(0xFF24C06F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.card.sparklineData.isNotEmpty)
                        SizedBox(
                          width: 70,
                          height: 32,
                          child: SparklineChart(
                            data: widget.card.sparklineData,
                            lineColor: const Color(0xFF24C06F),
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

class _InteractiveSubCard extends StatefulWidget {
  final SummaryCardModel card;

  const _InteractiveSubCard({required this.card});

  @override
  State<_InteractiveSubCard> createState() => _InteractiveSubCardState();
}

class _InteractiveSubCardState extends State<_InteractiveSubCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.card.iconColor;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0, 0.0)
          ..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0E1F), // Unified Flat Dark Navy
          borderRadius: AppRadius.radius18,
          border: Border.all(
            color: _isHovered 
                ? accentColor.withOpacity(0.3) 
                : Colors.white.withOpacity(0.08),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.15),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Soft colored left stripe (opaque)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isHovered ? 4.0 : 3.0,
                decoration: BoxDecoration(
                  color: accentColor, // Opaque stripe
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Title & Colored Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.card.title,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8), // Muted grey-blue title
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        widget.card.icon,
                        color: accentColor,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bottom Row: Value (with slide-up/fade-in on load)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1.0 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      widget.card.value,
                      style: AppTypography.cardValue.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
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
