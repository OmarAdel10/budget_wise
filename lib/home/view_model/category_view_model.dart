import 'package:budget_wise/home/data/repositories/category_repository.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryStateInitial()) {
    final categoryRepository = CategoryRepository(); 
    on<CategoryEventCreateCategory>((event, emit) {
      emit(CategoryStateLoading());
      try {
        categoryRepository.addCategory(event.category);
        emit(CategoryStateSuccess());
      } catch (e) {
        emit(CategoryStateError(e.toString()));
      }
    });

    on<CategoryEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly>((event, emit) {
      emit(CategoryStateLoading());
      try {
        categoryRepository.updateUserIdInAllCategoriesAfterFirstTimeLoginOnly();
        emit(CategoryStateSuccess());
      } catch (e) {
        emit(CategoryStateError(e.toString()));
      }
    });
  }
}