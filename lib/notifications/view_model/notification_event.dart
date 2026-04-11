import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationPayloadReceived extends NotificationEvent {
  final String payload;
  const NotificationPayloadReceived(this.payload);

  @override
  List<Object?> get props => [payload];
}

class NotificationHandled extends NotificationEvent {
  const NotificationHandled();
}
