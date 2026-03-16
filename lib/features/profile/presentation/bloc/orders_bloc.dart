import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final ProfileRepository repository;

  OrdersBloc({required this.repository}) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadActiveRentals>(_onLoadActiveRentals);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final orders = await repository.getMyOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onLoadActiveRentals(LoadActiveRentals event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final rentals = await repository.getActiveRentals();
      emit(ActiveRentalsLoaded(rentals));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
