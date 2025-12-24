import 'dart:async';
import 'dart:developer';

import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthStateInitial()) {
    on<AuthEventSignUp>(_onAuthEventSignUp);
    on<AuthEventSignIn>(_onAuthEventSignIn);
    on<AuthEventSignOut>(_onAuthEventSignOut);
    on<AuthEventResetPassword>(_onAuthEventResetPassword);
    on<AuthEventSignInWithGoogle>(_onAuthEventSignInWithGoogle);
  }

  final AuthRepository _authRepository = AuthRepository();

  Future<void> _onAuthEventSignUp(
    AuthEventSignUp event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      await _authRepository.currentUser!.updateDisplayName(event.name);
      emit(AuthStateSuccess(user: _authRepository.currentUser));
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }

  Future<void> _onAuthEventSignIn(
    AuthEventSignIn event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthStateSuccess(user: _authRepository.currentUser));
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }

  Future<void> _onAuthEventSignOut(
    AuthEventSignOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await _authRepository.signOut();
      emit(AuthStateSuccess());
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }

  Future<void> _onAuthEventResetPassword(
    AuthEventResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await _authRepository.resetPassword(email: event.email);
      emit(AuthStateSuccess());
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }

  Future<void> _onAuthEventSignInWithGoogle(
    AuthEventSignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await _authRepository.signInWithGoogle();
      emit(AuthStateSuccess(user: _authRepository.currentUser));
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }
}
