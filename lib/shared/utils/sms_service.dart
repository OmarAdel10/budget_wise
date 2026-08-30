import 'dart:convert';
import 'package:budget_wise/shared/vendor/telephony/telephony.dart';
import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/shared/utils/sms_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// This is a top-level function that runs in a separate background isolate.
/// It MUST be top-level and annotated with @pragma('vm:entry-point') to be
/// correctly invoked by the OS when the app is in the background or killed.
@pragma('vm:entry-point')
void onBackgroundMessage(SmsMessage message) async {
  // Ensure the Flutter environment is ready in this isolate.
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("Background SMS received from: ${message.address}");

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 0. Duplicate prevention with sliding window
    final String smsId = "${message.address}_${message.body}_${message.date}";
    List<String> processedIds = prefs.getStringList('processed_sms_ids') ?? [];
    if (processedIds.contains(smsId)) {
      debugPrint("SMS already processed in background: $smsId");
      return;
    }

    processedIds.add(smsId);
    if (processedIds.length > 100) {
      processedIds = processedIds.sublist(processedIds.length - 100);
    }
    await prefs.setStringList('processed_sms_ids', processedIds);

    // 1. Load cached accounts for matching
    final String? accountsJson = prefs.getString('cached_accounts_for_sms');
    if (accountsJson == null) {
      debugPrint("No cached accounts found for background SMS matching.");
      return;
    }

    final List<dynamic> decodedAccounts = json.decode(accountsJson);
    final List<AccountModel> accounts = decodedAccounts
        .map((item) => AccountModel.fromMap(item as Map<String, dynamic>))
        .toList();

    // 2. Parse the message
    final SmsParser parser = SmsParser();
    final List<String> senderIds = accounts
        .where(
          (acc) => acc.smsSenderIds != null && acc.smsSenderIds!.isNotEmpty,
        )
        .expand((acc) => acc.smsSenderIds!)
        .toSet()
        .toList();

    final SmsDraftModel? smsDraft = parser.parseSms(
      sender: message.address ?? 'UNKNOWN',
      body: message.body ?? '',
      potentialSenderIds: senderIds,
      messageDate: DateTime.fromMillisecondsSinceEpoch(message.date ?? 0),
    );

    if (smsDraft == null) {
      debugPrint("SMS not recognized as a transaction or sender not relevant.");
      return;
    }

    // 3. Match with account
    String? matchedAccountId;
    String? transferFromAccountId;
    String? transferToAccountId;
    for (final account in accounts) {
      if (smsDraft.transactionType == TransactionType.transfer) {
        if (smsDraft.transferSourceLastFour != null &&
            account.smsIdentifier == smsDraft.transferSourceLastFour) {
          transferFromAccountId = account.id;
          if (smsDraft.transferDirection == SmsTransferDirection.outgoing) {
            matchedAccountId ??= account.id;
          }
        }
        if (smsDraft.transferDestinationLastFour != null &&
            account.smsIdentifier == smsDraft.transferDestinationLastFour) {
          transferToAccountId = account.id;
          if (smsDraft.transferDirection == SmsTransferDirection.incoming) {
            matchedAccountId ??= account.id;
          }
        }
      }

      final bool hasMatchingCardDigits =
          smsDraft.extractedCardLastFour != null &&
          account.smsIdentifier != null &&
          smsDraft.extractedCardLastFour == account.smsIdentifier;

      if (hasMatchingCardDigits) {
        matchedAccountId = account.id;
        break;
      }

      final bool hasMatchingSenderId =
          account.smsSenderIds != null &&
          account.smsSenderIds!.any(
            (id) =>
                (message.address ?? '').toUpperCase().contains(
                  id.toUpperCase(),
                ) ||
                id.toUpperCase().contains(
                  (message.address ?? '').toUpperCase(),
                ),
          );

      if (hasMatchingSenderId) {
        matchedAccountId = account.id;
        break;
      }
    }

    final finalDraft = smsDraft.copyWith(
      id: const Uuid().v4(),
      matchedAccountId: matchedAccountId,
      transferFromAccountId: transferFromAccountId,
      transferToAccountId: transferToAccountId,
    );

    // 4. Save to pending background drafts
    final List<String> existingDraftsJson =
        prefs.getStringList('pending_background_drafts') ?? [];
    existingDraftsJson.add(finalDraft.toJson());
    await prefs.setStringList('pending_background_drafts', existingDraftsJson);

    // 5. Trigger Notification
    final String amountStr =
        "${finalDraft.extractedAmount?.toStringAsFixed(2)} ${finalDraft.extractedCurrency}";
    final String merchantStr =
        finalDraft.extractedMerchant ?? "Unknown Merchant";

    final bool allEnabled = prefs.getBool('all_notifications_enabled') ?? true;
    final bool smsEnabled = prefs.getBool('sms_notifications_enabled') ?? true;

    if (allEnabled && smsEnabled) {
      await NotificationRepository.instantNotification(
        id: finalDraft.timestamp.millisecondsSinceEpoch ~/ 1000,
        channelId: 'sms_transactions',
        channelName: 'SMS Transactions',
        channelDescription: 'Notifications for detected bank SMS transactions',
        title: 'New Transaction Detected',
        body:
            'Detected $amountStr ${smsDraft.transactionType == TransactionType.income ? 'from' : 'at'} $merchantStr. Tap to confirm.',
        payload: 'sms_draft_confirm',
      );
    }

    debugPrint("Background SMS processed and draft saved: ${finalDraft.id}");
  } catch (e) {
    debugPrint("Error in background SMS handler: $e");
  }
}

class SmsService {
  final Telephony _anotherTelephony = Telephony.instance;
  final SmsParser _smsParser = SmsParser();
  SmsParser get smsParser => _smsParser;

  Future<bool> requestPermissions() async {
    bool? permissionsGranted =
        await _anotherTelephony.requestPhoneAndSmsPermissions;
    return permissionsGranted ?? false;
  }

  void listenForSms({required Function(SmsMessage message) onNewMessage}) {
    _anotherTelephony.listenIncomingSms(
      onNewMessage: onNewMessage,
      onBackgroundMessage: onBackgroundMessage,
      listenInBackground: true,
    );
  }

  /// Registers only the background handler. Useful for early app initialization (e.g. in main).
  void initializeBackgroundHandler() {
    _anotherTelephony.listenIncomingSms(
      onNewMessage: (message) {}, // No-op for foreground in this context
      onBackgroundMessage: onBackgroundMessage,
      listenInBackground: true,
    );
  }

  /// Processes a single [SmsMessage] and attempts to match it to an [AccountModel].
  /// Returns an [SmsDraftModel] if parsing is successful, even without an account match.
  SmsDraftModel? processMessage({
    required SmsMessage message,
    required List<AccountModel> accounts,
    List<String>? allPotentialSenderIds,
  }) {
    final List<String> senderIds =
        allPotentialSenderIds ??
        accounts
            .where(
              (acc) => acc.smsSenderIds != null && acc.smsSenderIds!.isNotEmpty,
            )
            .expand((acc) => acc.smsSenderIds!)
            .toSet()
            .toList();

    final SmsDraftModel? smsDraft = _smsParser.parseSms(
      sender: message.address ?? 'UNKNOWN',
      body: message.body ?? '',
      potentialSenderIds: senderIds,
      messageDate: DateTime.fromMillisecondsSinceEpoch(message.date ?? 0),
    );

    if (smsDraft == null) return null;

    String? matchedAccountId;
    String? transferFromAccountId;
    String? transferToAccountId;
    for (final account in accounts) {
      if (smsDraft.transactionType == TransactionType.transfer) {
        if (smsDraft.transferSourceLastFour != null &&
            account.smsIdentifier == smsDraft.transferSourceLastFour) {
          transferFromAccountId = account.id;
          if (smsDraft.transferDirection == SmsTransferDirection.outgoing) {
            matchedAccountId ??= account.id;
          }
        }
        if (smsDraft.transferDestinationLastFour != null &&
            account.smsIdentifier == smsDraft.transferDestinationLastFour) {
          transferToAccountId = account.id;
          if (smsDraft.transferDirection == SmsTransferDirection.incoming) {
            matchedAccountId ??= account.id;
          }
        }
      }

      // Decision Flow:
      // 1. Check if last 4 card digits available in SMS and matches account.smsIdentifier
      final bool hasMatchingCardDigits =
          smsDraft.extractedCardLastFour != null &&
          account.smsIdentifier != null &&
          smsDraft.extractedCardLastFour == account.smsIdentifier;

      if (hasMatchingCardDigits) {
        matchedAccountId = account.id;
        break;
      }

      // 2. If no matching card digits, check if account.smsSenderIds contains message.address
      final bool hasMatchingSenderId =
          account.smsSenderIds != null &&
          account.smsSenderIds!.any(
            (id) =>
                (message.address ?? '').toUpperCase().contains(
                  id.toUpperCase(),
                ) ||
                id.toUpperCase().contains(
                  (message.address ?? '').toUpperCase(),
                ),
          );

      if (hasMatchingSenderId) {
        matchedAccountId = account.id;
        break;
      }
    }

    return smsDraft.copyWith(
      matchedAccountId: matchedAccountId,
      transferFromAccountId: transferFromAccountId,
      transferToAccountId: transferToAccountId,
    );
  }

  /// Scans the inbox for messages received after [sinceDateTime].
  Future<int> scanInboxSince({
    required DateTime sinceDateTime,
    required List<AccountModel> accounts,
    required TransactionBloc transactionBloc,
  }) async {
    List<SmsMessage> messages = await _anotherTelephony.getInboxSms();
    int count = 0;

    // Pre-calculate all potential sender IDs once for the loop
    final List<String> allPotentialSenderIds = accounts
        .where(
          (acc) => acc.smsSenderIds != null && acc.smsSenderIds!.isNotEmpty,
        )
        .expand((acc) => acc.smsSenderIds!)
        .toSet()
        .toList();

    // Filter messages older than sinceDateTime
    final List<SmsMessage> relevantMessages = messages.where((message) {
      // message.date is in milliseconds since epoch
      final messageDate = DateTime.fromMillisecondsSinceEpoch(
        message.date ?? 0,
      );
      return messageDate.isAfter(sinceDateTime);
    }).toList();

    for (final SmsMessage message in relevantMessages) {
      final SmsDraftModel? finalDraft = processMessage(
        message: message,
        accounts: accounts,
        allPotentialSenderIds: allPotentialSenderIds,
      );

      if (finalDraft != null) {
        transactionBloc.add(TransactionEventAddSmsDraft(smsDraft: finalDraft));
        count++;
      }
    }
    return count;
  }
}
