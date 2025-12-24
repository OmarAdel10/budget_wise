import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable{
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthEventSignUp extends AuthEvent{
  final String name;
  final String email;
  final String password;

  const AuthEventSignUp({required this.name, required this.email, required this.password});

  @override
  List<Object?> get props => [name, email, password];
}

class AuthEventSignIn extends AuthEvent{
  final String email;
  final String password;

  const AuthEventSignIn({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthEventSignOut extends AuthEvent{
  const AuthEventSignOut();

  @override
  List<Object?> get props => [];
}

class AuthEventResetPassword extends AuthEvent{
  final String email;

  const AuthEventResetPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthEventSignInWithGoogle extends AuthEvent{
  const AuthEventSignInWithGoogle();

  @override
  List<Object?> get props => [];
}
