import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationPending extends NotificationState {
  final String payload;
  const NotificationPending(this.payload);

  @override
  List<Object?> get props => [payload];
}
