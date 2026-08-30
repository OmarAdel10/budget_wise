import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:equatable/equatable.dart';

sealed class CategoryState extends Equatable {
  final List<CategoryModel> categoriesList;
  final Map<String, double> totalSpentById;

  const CategoryState({
    required this.categoriesList,
    required this.totalSpentById,
  });
}

class CategoryStateInitial extends CategoryState {
  const CategoryStateInitial({
    required List<CategoryModel> categoriesList,
    Map<String, double> totalSpentById = const {},
  }) : super(categoriesList: categoriesList, totalSpentById: totalSpentById);

  @override
  List<Object?> get props => [categoriesList, totalSpentById];
}

class CategoryStateSuccess extends CategoryState {
  const CategoryStateSuccess({
    required super.categoriesList,
    required super.totalSpentById,
  });

  @override
  List<Object?> get props => [categoriesList, totalSpentById];
}

class CategoryStateError extends CategoryState {
  final String message;

  const CategoryStateError({
    required this.message,
    required super.categoriesList,
    required super.totalSpentById,
  });

  @override
  List<Object?> get props => [message, categoriesList, totalSpentById];
}
