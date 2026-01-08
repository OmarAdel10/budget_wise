import 'package:budget_wise/home/data/models/category_model.dart';
import 'package:equatable/equatable.dart';

sealed class CategoryState extends Equatable {
  final List<CategoryModel> categoriesList;
  const CategoryState({required this.categoriesList});
}

class CategoryStateInitial extends CategoryState {
  const CategoryStateInitial({required super.categoriesList});

  @override
  List<Object?> get props => [categoriesList];
}

class CategoryStateSuccess extends CategoryState {
  const CategoryStateSuccess({required super.categoriesList});

  @override
  List<Object?> get props => [categoriesList];
}

class CategoryStateError extends CategoryState {
  final String message;

  const CategoryStateError({required this.message, required super.categoriesList});

  @override
  List<Object?> get props => [message, categoriesList];
}
