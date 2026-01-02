import 'package:equatable/equatable.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();
}

class CategoryStateInitial extends CategoryState {
  const CategoryStateInitial();

  @override
  List<Object?> get props => [];
}

class CategoryStateLoading extends CategoryState {
  const CategoryStateLoading();

  @override
  List<Object?> get props => [];
}

class CategoryStateSuccess extends CategoryState {
  const CategoryStateSuccess();

  @override
  List<Object?> get props => [];
}

class CategoryStateError extends CategoryState {
  final String message;

  const CategoryStateError(this.message);

  @override
  List<Object?> get props => [message];
}
