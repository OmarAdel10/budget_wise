import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';

sealed class MerchantCategoryLearningEvent extends Equatable {
  const MerchantCategoryLearningEvent();
}

class MerchantCategoryLearningEventLoadRequested
    extends MerchantCategoryLearningEvent {
  const MerchantCategoryLearningEventLoadRequested();

  @override
  List<Object?> get props => [];
}

class MerchantCategoryLearningEventMappingSaved
    extends MerchantCategoryLearningEvent {
  final String merchantName;
  final String categoryId;
  final String categoryTitle;
  final TransactionType transactionType;

  const MerchantCategoryLearningEventMappingSaved({
    required this.merchantName,
    required this.categoryId,
    required this.categoryTitle,
    required this.transactionType,
  });

  @override
  List<Object?> get props => [
    merchantName,
    categoryId,
    categoryTitle,
    transactionType,
  ];
}

class MerchantCategoryLearningEventMappingDeleted
    extends MerchantCategoryLearningEvent {
  final String id;

  const MerchantCategoryLearningEventMappingDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}
