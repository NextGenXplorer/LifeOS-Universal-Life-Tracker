import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class XpGrowthChart extends StatelessWidget {
  final List<double> data;
  final List<String>? labels;

  const XpGrowthChart({
    super.key,
    required this.data,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: data.reduce((a, b) => a > b ? a : b) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.glassDark,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (labels != null && value.toInt() < labels!.length) {
                  return Text(
                    labels![value.toInt()],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkillRadarChart extends StatelessWidget {
  final List<String> skills;
  final List<double> values;
  final Color? color;

  const SkillRadarChart({
    super.key,
    required this.skills,
    required this.values,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty || values.isEmpty) {
      return const Center(child: Text('No skills data'));
    }

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarBorderData: BorderSide(color: AppColors.glassDark),
        gridBorderData: BorderSide(color: AppColors.glassDark),
        tickCount: 4,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        tickBorderData: const BorderSide(color: Colors.transparent),
        getTitle: (index, angle) {
          if (index < skills.length) {
            return RadarChartTitle(
              text: skills[index],
              angle: 0,
            );
          }
          return const RadarChartTitle(text: '');
        },
        dataSets: [
          RadarDataSet(
            fillColor: (color ?? AppColors.primary).withOpacity(0.2),
            borderColor: color ?? AppColors.primary,
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
          ),
        ],
      ),
    );
  }
}
