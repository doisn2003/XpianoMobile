import 'package:equatable/equatable.dart';

/// Một điểm dữ liệu trên biểu đồ doanh thu tháng.
class ChartPoint extends Equatable {
  final String month;
  final double revenue;
  final int students;

  const ChartPoint({
    required this.month,
    required this.revenue,
    required this.students,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      month: json['month'] as String? ?? '',
      revenue: _toDouble(json['revenue']),
      students: _toInt(json['students']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [month, revenue, students];
}

/// Tổng quan thống kê cho giáo viên.
class TeacherStats extends Equatable {
  final int totalCourses;
  final int totalStudents;
  final double totalRevenue;
  final List<ChartPoint> chartData;

  const TeacherStats({
    this.totalCourses = 0,
    this.totalStudents = 0,
    this.totalRevenue = 0,
    this.chartData = const [],
  });

  factory TeacherStats.fromJson(Map<String, dynamic> json) {
    final List chartRaw = json['chartData'] as List? ?? [];
    return TeacherStats(
      totalCourses: ChartPoint._toInt(json['totalCourses']),
      totalStudents: ChartPoint._toInt(json['totalStudents']),
      totalRevenue: ChartPoint._toDouble(json['totalRevenue']),
      chartData: chartRaw
          .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [totalCourses, totalStudents, totalRevenue, chartData];
}
