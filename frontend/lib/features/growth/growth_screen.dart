import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../dashboard/dashboard_screen.dart';
import 'dart:ui';
import '../dashboard/sidebar_drawer.dart';
import '../../providers/user_provider.dart';
import '../../providers/quest_provider.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key});

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final questsAsync = ref.watch(questProvider);

    return Scaffold(
      backgroundColor: IkoTheme.surface,
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: userAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator())),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (user) {
                return questsAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator())),
                  error: (err, st) => Center(child: Text('Error: $err')),
                  data: (quests) {
                    final completedQuests = quests.where((q) => q.isCompleted).toList();
                    final totalQuests = quests.length;
                    
                    final productivityIndex = totalQuests > 0 ? ((completedQuests.length / totalQuests) * 100).toInt() : 0;
                    
                    final completedFocus = completedQuests.where((q) => q.category == 'Focus').length;
                    final totalFocus = quests.where((q) => q.category == 'Focus').length;

                    final completedHealth = completedQuests.where((q) => q.category == 'Health').length;
                    final totalHealth = quests.where((q) => q.category == 'Health').length;

                    final completedGrowth = completedQuests.where((q) => q.category == 'Growth').length;
                    final totalGrowth = quests.where((q) => q.category == 'Growth').length;
                    
                    final overallEfficiency = totalQuests > 0 ? ((completedQuests.length / totalQuests) * 100).toInt() : 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildTopAppBar(context),
                        const SizedBox(height: 24),
                        const Text(
                          'Analytics Overview',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: IkoTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your performance and growth metrics over the last 30 days.',
                          style: TextStyle(
                            fontSize: 14,
                            color: IkoTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTotalXPCard(user.xp),
                        const SizedBox(height: 16),
                        _buildFocusStreakCard(user.currentStreak),
                        const SizedBox(height: 16),
                        _buildProductivityCard(productivityIndex),
                        const SizedBox(height: 16),
                        _buildTrajectoryCard(),
                        const SizedBox(height: 16),
                        _buildGoalCompletionCard(
                          completedFocus, totalFocus == 0 ? 1 : totalFocus,
                          completedHealth, totalHealth == 0 ? 1 : totalHealth,
                          completedGrowth, totalGrowth == 0 ? 1 : totalGrowth,
                          overallEfficiency,
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: DashboardScreen.buildSharedBottomNav(context, 3),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: IkoTheme.surfaceContainer,
            ),
            child: const Icon(Icons.person, size: 20, color: IkoTheme.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'IKO',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: IkoTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalXPCard(int xp) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL XP EARNED',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              Icon(Icons.workspace_premium_outlined, size: 20, color: IkoTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$xp',
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: IkoTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: IkoTheme.primary),
              const SizedBox(width: 4),
              const Text(
                '+14%',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: IkoTheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'vs last month',
                style: TextStyle(
                  fontSize: 12,
                  color: IkoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FOCUS STREAK',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: IkoTheme.textSecondary,
                ),
              ),
              Icon(Icons.local_fire_department_outlined, size: 20, color: IkoTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$streak',
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: IkoTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Days',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: IkoTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: streak > 30 ? 1.0 : streak / 30.0, // Assuming 30 days is a max visual scale
              minHeight: 6,
              backgroundColor: IkoTheme.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(IkoTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityCard(int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: IkoTheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PRODUCTIVITY INDEX',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.insights_outlined, size: 20, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$index',
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: CustomPaint(
                  painter: SparklinePainter(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrajectoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XP Growth\nTrajectory',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: IkoTheme.primary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Daily accumulation vs\ntarget baseline.',
                      style: TextStyle(
                        fontSize: 12,
                        color: IkoTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: IkoTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildTimeToggle('1M', true),
                    _buildTimeToggle('3M', false),
                    _buildTimeToggle('YTD', false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: AreaChartPainter(
                lineColor: IkoTheme.primary,
                fillColor: const Color(0xFFE2E2E2).withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Oct 1', style: TextStyle(fontSize: 10, color: IkoTheme.textSecondary)),
              Text('Oct 10', style: TextStyle(fontSize: 10, color: IkoTheme.textSecondary)),
              Text('Oct 20', style: TextStyle(fontSize: 10, color: IkoTheme.textSecondary)),
              Text('Oct 30', style: TextStyle(fontSize: 10, color: IkoTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeToggle(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)] : [],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? IkoTheme.primary : IkoTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGoalCompletionCard(int cF, int tF, int cH, int tH, int cG, int tG, int overall) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: IkoTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goal Completion',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: IkoTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildGoalBar('Deep Work Sessions (Focus)', cF, tF),
          const SizedBox(height: 16),
          _buildGoalBar('Health Quests', cH, tH, color: const Color(0xFF616161)),
          const SizedBox(height: 16),
          _buildGoalBar('Learning Modules (Growth)', cG, tG, color: const Color(0xFF9E9E9E)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Overall Efficiency',
                style: TextStyle(
                  fontSize: 14,
                  color: IkoTheme.textSecondary,
                ),
              ),
              Text(
                '$overall%',
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: IkoTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalBar(String label, int current, int total, {Color color = IkoTheme.primary}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: IkoTheme.primary,
              ),
            ),
            Text(
              '$current/$total',
              style: const TextStyle(
                fontSize: 12,
                color: IkoTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: total > 0 ? current / total : 0,
            minHeight: 4,
            backgroundColor: IkoTheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class SparklinePainter extends CustomPainter {
  final Color color;
  SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, 0, size.width * 0.8, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.6, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AreaChartPainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;

  AreaChartPainter({required this.lineColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashedPaint = Paint()
      ..color = IkoTheme.textSecondary.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.75, size.width * 0.4, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.4, size.width * 0.7, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.1, size.width, size.height * 0.2);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Target baseline dashed line
    final dashPath = Path();
    dashPath.moveTo(0, size.height * 0.85);
    dashPath.lineTo(size.width, size.height * 0.4);

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double distance = 0.0;
    for (PathMetric measurePath in dashPath.computeMetrics()) {
      while (distance < measurePath.length) {
        final pathSegment = measurePath.extractPath(distance, distance + dashWidth);
        canvas.drawPath(pathSegment, dashedPaint);
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
