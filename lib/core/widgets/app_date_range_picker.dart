import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class AppDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const AppDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  /// Hiển thị bộ chọn ngày
  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppDateRangePicker(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
      ),
    );
  }

  @override
  State<AppDateRangePicker> createState() => _AppDateRangePickerState();
}

class _AppDateRangePickerState extends State<AppDateRangePicker> {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _onDayTapped(DateTime date) {
    // Không cho chọn ngày quá khứ
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    if (date.isBefore(todayMidnight)) {
      return;
    }

    setState(() {
      if (_startDate == null) {
        _startDate = date;
      } else if (_endDate == null) {
        if (date.isBefore(_startDate!)) {
          // Bắt đầu lại nếu chọn trước số cũ
          _startDate = date;
        } else {
          _endDate = date;
        }
      } else {
        // Cả 2 đã chọn => reset lại từ đầu
        _startDate = date;
        _endDate = null;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _prevMonth() {
    setState(() {
      final now = DateTime.now();
      // Không cho lùi về tháng trước của quá khứ
      if (_currentMonth.year > now.year ||
          (_currentMonth.year == now.year && _currentMonth.month > now.month)) {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      }
    });
  }

  Widget _buildCalendarGrid() {
    final int daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    
    // weekday is 1 for Mon, 7 for Sun
    final int firstDayOffset = firstDayOfMonth.weekday - 1;

    List<Widget> dayWidgets = [];

    // Ô trống đầu tháng
    for (int i = 0; i < firstDayOffset; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, i);
      final isPast = date.isBefore(todayMidnight);

      bool isSelectedStart = _startDate != null && date.isAtSameMomentAs(_startDate!);
      bool isSelectedEnd = _endDate != null && date.isAtSameMomentAs(_endDate!);
      bool isInRange = _startDate != null && _endDate != null && date.isAfter(_startDate!) && date.isBefore(_endDate!);

      Color textColor = AppTheme.textPrimary;
      if (isSelectedStart || isSelectedEnd) {
        textColor = Colors.white;
      } else if (isInRange) {
        textColor = AppTheme.primaryGoldDark;
      } else if (isPast) {
        textColor = AppTheme.textSecondary.withOpacity(0.4);
      } else if (date.weekday == 7) {
        textColor = Colors.red.shade400; // CN màu đỏ nhẹ
      }

      Widget content = Center(
        child: Text(
          '$i',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: (isSelectedStart || isSelectedEnd) ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );

      // Hiệu ứng nối range
      Widget dayCell;
      if (isSelectedStart || isSelectedEnd || isInRange) {
        bool showLeftConnector = false;
        bool showRightConnector = false;

        if (isInRange) {
           showLeftConnector = true;
           showRightConnector = true;
           // Không vẽ nối ra ngoài tuần (cột 0 hoặc cột 6)
           if (date.weekday == 1) showLeftConnector = false;
           if (date.weekday == 7) showRightConnector = false;
        } else if (isSelectedStart && _endDate != null) {
           showRightConnector = date.weekday != 7; // Chỉ nối bên phải nếu ko phải CN
        } else if (isSelectedEnd && _startDate != null) {
           showLeftConnector = date.weekday != 1; // Chỉ nối bên trái nếu ko phải T2
        }

        dayCell = Stack(
          alignment: Alignment.center,
          children: [
            if (showLeftConnector)
              Positioned(
                left: 0,
                right: 20, // 20 roughly halfway
                top: 8, bottom: 8,
                child: Container(color: AppTheme.primaryGold.withOpacity(0.15)),
              ),
            if (showRightConnector)
              Positioned(
                left: 20,
                right: 0,
                top: 8, bottom: 8,
                child: Container(color: AppTheme.primaryGold.withOpacity(0.15)),
              ),
              
            if (isSelectedStart || isSelectedEnd)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: content,
              )
            else if (isInRange)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: AppTheme.primaryGold.withOpacity(0.15),
                child: content,
              )
            else
              content,
          ],
        );
      } else {
        dayCell = content;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: isPast ? null : () => _onDayTapped(date),
          behavior: HitTestBehavior.opaque,
          child: dayCell,
        ),
      );
    }

    return Column(
      children: [
        // Header Tháng
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
              onPressed: _prevMonth,
              splashRadius: 24,
            ),
            Text(
              'Tháng ${_currentMonth.month}, ${_currentMonth.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
              onPressed: _nextMonth,
              splashRadius: 24,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Ngày trong tuần
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _weekDays.map((d) => Expanded(
            child: Center(
              child: Text(
                d, 
                style: TextStyle(
                  color: d == 'CN' ? Colors.red.shade300 : AppTheme.textSecondary, 
                  fontWeight: FontWeight.w600, 
                  fontSize: 13,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),
        // Lưới ngày
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          children: dayWidgets,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh kéo (Handle bar)
              Center(
                child: Container(
                  width: 48, height: 5,
                  decoration: BoxDecoration(color: AppTheme.dividerColor, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Chọn thời gian thuê',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Ô hiển thị TỪ - ĐẾN
              Row(
                children: [
                   Expanded(child: _buildDateDisplay('Bắt đầu', _startDate)),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 16),
                     child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGold, size: 24),
                   ),
                   Expanded(child: _buildDateDisplay('Kết thúc', _endDate)),
                ],
              ),
              const SizedBox(height: 24),

              // Nội dung Calendar
              _buildCalendarGrid(),
              
              const SizedBox(height: 32),

              // Các nút hành động
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                         setState(() {
                           _startDate = null;
                           _endDate = null;
                         });
                      },
                      child: const Text('Xoá chọn'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: (_startDate != null && _endDate != null)
                          ? () {
                              Navigator.pop(context, DateTimeRange(start: _startDate!, end: _endDate!));
                            }
                          : null,
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDisplay(String label, DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: date != null ? AppTheme.primaryGold : AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            date != null ? DateFormat('dd/MM/yyyy').format(date) : '--/--/----',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: date != null ? AppTheme.primaryGoldDark : AppTheme.textPrimary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
