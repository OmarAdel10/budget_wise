import 'dart:async';
import 'dart:developer';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthStateInitial()) {
    on<AuthEventSignUp>(_onAuthEventSignUp);
    on<AuthEventSignIn>(_onAuthEventSignIn);
    on<AuthEventSignOut>(_onAuthEventSignOut);
    on<AuthEventResetPassword>(_onAuthEventResetPassword);
    on<AuthEventSignInWithGoogle>(_onAuthEventSignInWithGoogle);
    on<AuthEventLocalAuth>(_onAuthEventLocalAuth);
    on<AuthEventEditProfileChangeName>(_onAuthEventEditProfileChangeName);
    on<AuthEventEditProfileChangePassword>(
      _onAuthEventEditProfileChangePassword,
    );
  }

  Future<void> _onAuthEventSignUp(
    AuthEventSignUp event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await authRepository.signUp(email: event.email, password: event.password);
      await authRepository.currentUser!.updateDisplayName(event.name);
      emit(AuthStateSuccess(user: authRepository.currentUser));
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
      await authRepository.signIn(email: event.email, password: event.password);
      emit(AuthStateSuccess(user: authRepository.currentUser));
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
      await authRepository.signOut();
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
      await authRepository.resetPassword(email: event.email);
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
      await authRepository.signInWithGoogle();
      emit(AuthStateSuccess(user: authRepository.currentUser));
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }

  Future<void> _onAuthEventLocalAuth(
    AuthEventLocalAuth event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await authRepository.localAuth(
        localizedReason: event.localizedReason,
        biometricNotAvailableErrorMessage:
            event.biometricNotAvailableErrorMessage,
      );
      emit(AuthStateSuccess(user: authRepository.currentUser));
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }

  Future<void> _onAuthEventEditProfileChangeName(
    AuthEventEditProfileChangeName event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await authRepository.updateProfileUserName(name: event.name);
      emit(AuthStateSuccess(user: authRepository.currentUser));
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }

  Future<void> _onAuthEventEditProfileChangePassword(
    AuthEventEditProfileChangePassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await authRepository.updateProfileUserPassword(password: event.password);
      emit(AuthStateSuccess(user: authRepository.currentUser));
    } on Exception catch (e) {
      emit(AuthStateError(message: e.toString()));
      log(e.toString());
    }
  }
}
