import 'package:equatable/equatable.dart';

abstract class PianoOrderState extends Equatable {
  const PianoOrderState();
  @override
  List<Object?> get props => [];
}

class PianoOrderInitial extends PianoOrderState {}

class PianoOrderLoading extends PianoOrderState {}

class PianoOrderSuccess extends PianoOrderState {
  final Map<String, dynamic> orderData;

  const PianoOrderSuccess(this.orderData);

  /// URL mã QR thanh toán (nếu chọn QR)
  String? get qrUrl => orderData['qr_url'];

  /// Thông tin ngân hàng (nếu chọn QR)
  Map<String, dynamic>? get bankInfo =>
      orderData['bank_info'] is Map<String, dynamic> ? orderData['bank_info'] : null;

  @override
  List<Object?> get props => [orderData];
}

class PianoOrderError extends PianoOrderState {
  final String message;
  const PianoOrderError(this.message);
  @override
  List<Object> get props => [message];
}
