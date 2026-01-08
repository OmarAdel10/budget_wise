import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:equatable/equatable.dart';

sealed class HomeState extends Equatable {
  final HomeModel model;
  const HomeState({required this.model});

  @override
  List<Object?> get props => [model];
}

class HomeStateInitial extends HomeState {
  const HomeStateInitial({required super.model});

  @override
  List<Object?> get props => [model];
}

class HomeStateSuccess extends HomeState {
  const HomeStateSuccess({required super.model});

  @override
  List<Object?> get props => [model];
}

class HomeStateError extends HomeState {
  final String message;

  const HomeStateError({required this.message, required super.model});

  @override
  List<Object?> get props => [message, model];
}
