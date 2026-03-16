import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object> get props => [];
}

class LoadOrders extends OrdersEvent {}

class LoadActiveRentals extends OrdersEvent {}
