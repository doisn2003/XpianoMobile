import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSendOtpRequested>(_onAuthSendOtpRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthPasswordLoginRequested>(_onAuthPasswordLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSendOtpRequested(
      AuthSendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.sendOtp(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpSent(event.email)),
    );
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.loginWithOtp(event.email, event.otp, event.role);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthPasswordLoginRequested(
      AuthPasswordLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.login(event.email, event.password, event.role);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.registerWithOtp(
      event.email,
      event.otp,
      event.password,
      event.fullName,
      event.phone,
      event.role,
      event.dob,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
