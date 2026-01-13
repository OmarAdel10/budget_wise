import 'package:equatable/equatable.dart';
import '../data/models/statistics_model.dart';

sealed class StatisticsState extends Equatable {
  final StatisticsModel model;
  const StatisticsState(this.model);

  @override
  List<Object?> get props => [model];
}

class StatisticsStateInitial extends StatisticsState {
  const StatisticsStateInitial(super.model);
}

class StatisticsStateSuccess extends StatisticsState {
  const StatisticsStateSuccess(super.model);
}

class StatisticsStateError extends StatisticsState {
  final String message;
  const StatisticsStateError(super.model, this.message);

  @override
  List<Object?> get props => [model, message];
}
