import 'package:budget_wise/transaction/data/models/merchant_category_mapping.dart';
import 'package:equatable/equatable.dart';

class MerchantCategoryLearningState extends Equatable {
  final List<MerchantCategoryMapping> mappings;
  final String? errorMessage;

  const MerchantCategoryLearningState({
    this.mappings = const [],
    this.errorMessage,
  });

  MerchantCategoryLearningState copyWith({
    List<MerchantCategoryMapping>? mappings,
    String? errorMessage,
  }) {
    return MerchantCategoryLearningState(
      mappings: mappings ?? this.mappings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [mappings, errorMessage];
}
