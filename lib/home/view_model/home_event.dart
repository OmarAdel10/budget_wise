import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable{
  const HomeEvent();
}

class HomeEventLoadAllData extends HomeEvent{
  final DateTime monthDate;
  const HomeEventLoadAllData(this.monthDate);

  @override
  List<Object?> get props => [monthDate];
}

class HomeEventUpdateCategory extends HomeEvent {
  final dynamic category; // Using dynamic for now to match CategoryModel or Category entity, will refine if needed
  const HomeEventUpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class HomeEventUpdateTransaction extends HomeEvent {
  final dynamic transaction; // Using dynamic to match TransactionModel
  const HomeEventUpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}