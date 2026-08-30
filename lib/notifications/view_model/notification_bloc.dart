import 'dart:async';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  StreamSubscription<String?>? _payloadSubscription;

  NotificationBloc() : super(const NotificationInitial()) {
    on<NotificationPayloadReceived>(_onPayloadReceived);
    on<NotificationHandled>(_onHandled);

    _listenToPayloads();
    _checkInitialPayload();
  }

  void _onPayloadReceived(
    NotificationPayloadReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationPending(event.payload));
  }

  void _onHandled(NotificationHandled event, Emitter<NotificationState> emit) {
    emit(const NotificationInitial());
  }

  void _listenToPayloads() {
    _payloadSubscription?.cancel();
    _payloadSubscription = NotificationRepository.payloadStream.listen((
      payload,
    ) {
      if (payload != null) {
        add(NotificationPayloadReceived(payload));
      }
    });
  }

  Future<void> _checkInitialPayload() async {
    final details = await NotificationRepository.notifications
        .getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final payload = details?.notificationResponse?.payload;
      if (payload != null) {
        add(NotificationPayloadReceived(payload));
      }
    }
  }

  @override
  Future<void> close() {
    _payloadSubscription?.cancel();
    return super.close();
  }
}
