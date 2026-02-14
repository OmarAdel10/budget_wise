import 'package:another_telephony/telephony.dart';
import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/models/sms_draft_model.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/shared/utils/sms_parser.dart';

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
      listenInBackground: false, // Only listen in foreground here
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
    for (final account in accounts) {
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

    return smsDraft.copyWith(matchedAccountId: matchedAccountId);
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
