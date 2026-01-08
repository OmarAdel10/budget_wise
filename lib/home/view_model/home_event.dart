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