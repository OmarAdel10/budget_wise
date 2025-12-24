import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

sealed class AuthState extends Equatable {
  final User? user;
  const AuthState({this.user});

  @override
  List<Object?> get props => [user];
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial({super.user});

  @override
  List<Object?> get props => [user];
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading({super.user});

  @override
  List<Object?> get props => [user];
}

class AuthStateSuccess extends AuthState {
  const AuthStateSuccess({super.user});

  @override
  List<Object?> get props => [user];
}

class AuthStateError extends AuthState {
  final String message;

  const AuthStateError({required this.message, super.user});

  @override
  List<Object?> get props => [message, user];
}
