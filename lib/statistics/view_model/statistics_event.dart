import 'package:equatable/equatable.dart';
import 'package:budget_wise/statistics/data/models/statistics_model.dart';

sealed class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsEventLoadRequested extends StatisticsEvent {
  final DateTime selectedMonth;

  const StatisticsEventLoadRequested(this.selectedMonth);

  @override
  List<Object?> get props => [selectedMonth];
}

class StatisticsEventSortChanged extends StatisticsEvent {
  final StatisticsSorting sortingType;

  const StatisticsEventSortChanged(this.sortingType);

  @override
  List<Object?> get props => [sortingType];
}
