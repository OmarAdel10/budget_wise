import 'dart:developer';

import 'package:budget_wise/transaction/data/repositories/merchant_category_learning_repository.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_event.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MerchantCategoryLearningBloc
    extends Bloc<MerchantCategoryLearningEvent, MerchantCategoryLearningState> {
  final MerchantCategoryLearningRepository repository;

  MerchantCategoryLearningBloc({required this.repository})
    : super(const MerchantCategoryLearningState()) {
    on<MerchantCategoryLearningEventLoadRequested>((event, emit) {
      emit(state.copyWith(mappings: repository.loadLocalMappings()));
    });

    on<MerchantCategoryLearningEventMappingSaved>((event, emit) async {
      if (event.merchantName.trim().isEmpty) return;

      try {
        await repository.saveMapping(
          merchantName: event.merchantName,
          categoryId: event.categoryId,
          categoryTitle: event.categoryTitle,
          transactionType: event.transactionType,
        );
        emit(state.copyWith(mappings: repository.loadLocalMappings()));
      } catch (e) {
        log('Merchant category learning failed: $e');
        emit(state.copyWith(errorMessage: e.toString()));
      }
    });

    on<MerchantCategoryLearningEventMappingDeleted>((event, emit) async {
      try {
        await repository.deleteMapping(event.id);
        emit(state.copyWith(mappings: repository.loadLocalMappings()));
      } catch (e) {
        log('Merchant category mapping deletion failed: $e');
        emit(state.copyWith(errorMessage: e.toString()));
      }
    });
  }
}
