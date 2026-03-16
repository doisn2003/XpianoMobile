abstract class CourseOrderState {}

class CourseOrderInitial extends CourseOrderState {}

class CourseOrderLoading extends CourseOrderState {}

class CourseOrderSuccess extends CourseOrderState {
  final Map<String, dynamic> orderData;

  CourseOrderSuccess(this.orderData);

  String? get qrUrl => orderData['qr_url'] as String?;
}

class CourseOrderError extends CourseOrderState {
  final String message;
  CourseOrderError(this.message);
}
