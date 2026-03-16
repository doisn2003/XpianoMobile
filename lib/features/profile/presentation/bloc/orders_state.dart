import 'package:equatable/equatable.dart';
import '../../domain/entities/active_rental.dart';
import '../../domain/entities/order.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderItem> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class ActiveRentalsLoaded extends OrdersState {
  final List<ActiveRental> rentals;

  const ActiveRentalsLoaded(this.rentals);

  @override
  List<Object> get props => [rentals];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object> get props => [message];
}
