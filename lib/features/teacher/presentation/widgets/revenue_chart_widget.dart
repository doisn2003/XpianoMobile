import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartPoint;
import 'package:intl/intl.dart';

import '../../data/models/teacher_stats_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget biểu đồ doanh thu 6 tháng gần đây.
///
/// - Series 1: ColumnSeries cho revenue (xanh dương, bo góc trên).
/// - Series 2: LineSeries cho students (xanh lá, nét dày 2).
/// - Trục X: month.
/// - Trục Y trái: revenue (format >= 1,000,000 => x.xM, còn lại xk).
/// - Trục Y phải: students (số nguyên), opposite=true.
/// - Có tooltip, legend, grid ngang nhẹ.
class RevenueChartWidget extends StatelessWidget {
  final List<ChartPoint> data;

  const RevenueChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: SfCartesianChart(
            title: const ChartTitle(
              text: 'Doanh thu & Học viên (6 tháng)',
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              shared: true,
              builder: (dynamic tooltipData, dynamic point, dynamic series,
                  int pointIdx, int seriesIdx) {
                if (pointIdx < 0 || pointIdx >= data.length) {
                  return const SizedBox.shrink();
                }
                final cp = data[pointIdx];
                final revenueFmt = NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'VNĐ',
                  decimalDigits: 0,
                ).format(cp.revenue);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cp.month,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Doanh thu: $revenueFmt',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Học viên: ${cp.students}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),

            // --- Trục X ---
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              labelStyle: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),

            // --- Trục Y trái (Revenue) ---
            primaryYAxis: NumericAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              majorGridLines: const MajorGridLines(
                width: 0.5,
                color: AppTheme.dividerColor,
                dashArray: [4, 4],
              ),
              labelStyle:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                return ChartAxisLabel(
                  _formatRevenueLabel(details.value.toDouble()),
                  details.textStyle,
                );
              },
            ),

            // --- Trục Y phải (Students) ---
            axes: <ChartAxis>[
              NumericAxis(
                name: 'studentsAxis',
                opposedPosition: true,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
                decimalPlaces: 0,
              ),
            ],

            series: <CartesianSeries<ChartPoint, String>>[
              // --- Series 1: Revenue (Column) ---
              ColumnSeries<ChartPoint, String>(
                name: 'Doanh thu',
                dataSource: data,
                xValueMapper: (ChartPoint cp, _) => cp.month,
                yValueMapper: (ChartPoint cp, _) => cp.revenue,
                color: const Color(0xFF4A90D9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                width: 0.5,
              ),

              // --- Series 2: Students (Line) ---
              LineSeries<ChartPoint, String>(
                name: 'Học viên',
                dataSource: data,
                xValueMapper: (ChartPoint cp, _) => cp.month,
                yValueMapper: (ChartPoint cp, _) => cp.students,
                yAxisName: 'studentsAxis',
                color: const Color(0xFF4CAF50),
                width: 2,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 6,
                  width: 6,
                  shape: DataMarkerType.circle,
                  borderColor: Color(0xFF4CAF50),
                  borderWidth: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format trục Y revenue: >= 1,000,000 => "1.0M", còn lại >= 1000 => "999k".
  String _formatRevenueLabel(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    if (value >= 1000) {
      final k = value / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
