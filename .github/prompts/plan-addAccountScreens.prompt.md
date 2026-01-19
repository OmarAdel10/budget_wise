Plan: Implement Add Account UI Flow (Single-Screen)

TL;DR — Build one Flutter screen that contains both Part 1 (account identity/form) and Part 2 (card details preview and inputs). The screen toggles between parts using an internal boolean (e.g., showCardEntry). Use flutter_credit_card for the visual card preview in Part 2. Localize all text (English & Arabic) via ARB files. Do NOT implement CVV input or the dotted "Connect Banking Service" container.

Overview

- Single screen: `AddAccountScreen` at `lib/accounts/view/screens/add_account_screen.dart` (Stateful). It holds UI state including form fields, selected account type, and a boolean to switch views between Part 1 and Part 2.
- Behavior: In Part 1 the user picks account type (Cash, Visa, MasterCard, Bank). When the primary CTA is tapped, if the selected type is Visa/MasterCard/Bank then flip the boolean to show Part 2 (card entry). If Cash is selected, do NOT switch to Part 2 — instead show a UI-only success (SnackBar) and remain on Part 1.

Steps

1. Create the single UI file: implement `AddAccountScreen` in `lib/accounts/view/screens/add_account_screen.dart` (Stateful). It should render Part 1 and Part 2 content and toggle between them using a boolean state variable.
2. Create reusable widgets: `AccountTypeTile` at `lib/accounts/view/widgets/account_type_tile.dart` (Stateless) and `CreditCardPreview` at `lib/accounts/view/widgets/credit_card_preview.dart` (Stateless wrapper around `flutter_credit_card`).
3. Export a static `routeName` from `AddAccountScreen`; register the route in `lib/main.dart` to allow navigation from `accounts_screen.dart`.
4. Localization: add `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` including keys under the `addAccount` namespace for all hard-coded text; run `flutter gen-l10n` to regenerate `AppLocalizations`.
5. Wire up `accounts_screen.dart` to `Navigator.pushNamed(context, AddAccountScreen.routeName)` or `Navigator.push()` to open the single Add Account screen.
6. Validate minimal fields: account name required; initial balance parses as decimal. For card inputs, implement basic formatting and update the preview (no CVV input or handling).

Files to create (suggested paths)

- lib/accounts/view/screens/add_account_screen.dart
- lib/accounts/view/widgets/account_type_tile.dart
- lib/accounts/view/widgets/credit_card_preview.dart
- lib/l10n/app_en.arb
- lib/l10n/app_ar.arb

Localization keys (namespace `addAccount`)

- addAccount.title: "Add New Account" / "إضافة حساب جديد"
- addAccount.identity.header: "Account Identity" / "هوية الحساب"
- addAccount.setup.title: "Setup your source" / "إعداد مصدر الأموال"
- addAccount.setup.subtitle: "Enter your account details to start tracking your daily incremental savings." / "أدخل تفاصيل حسابك للبدء بتتبع مدخراتك اليومية."
- addAccount.accountName.label: "Account Name" / "اسم الحساب"
- addAccount.accountName.placeholder: "e.g. Main Checking" / "مثال: الحساب الجاري الرئيسي"
- addAccount.type.header: "Account Type" / "نوع الحساب"
- addAccount.type.cash: "Cash" / "نقدي"
- addAccount.type.visa: "Visa" / "فيزا"
- addAccount.type.mastercard: "MasterCard" / "ماستركارد"
- addAccount.type.bank: "Bank" / "بنك"
- addAccount.initialBalance.label: "Initial Balance" / "الرصيد الابتدائي"
- addAccount.initialBalance.placeholder: "0.00" / "0.00"
- addAccount.button.addAccount: "Add Account" / "إضافة حساب"
- addAccount.card.title: "Enter Card Details" / "إدخال تفاصيل البطاقة"
- addAccount.card.cardNumberLabel: "Card Number" / "رقم البطاقة"
- addAccount.card.cardholderLabel: "Cardholder" / "اسم حامل البطاقة"
- addAccount.card.cardholderNameLabel: "Cardholder Name" / "اسم حامل البطاقة"
- addAccount.card.cardholderName.placeholder: "Name as on card" / "الاسم كما هو على البطاقة"
- addAccount.card.expiryLabel: "Expiry Date" / "تاريخ الانتهاء"
- addAccount.card.expiry.placeholder: "MM/YY" / "MM/YY"
- addAccount.card.cvvLabel: "CVV" / "رمز التحقق" (preview only)
- addAccount.button.saveCard: "Save Card" / "حفظ البطاقة"
- addAccount.card.secureNote: "Your card information is encrypted and secure" / "معلومات بطاقتك مشفرة ومأمونة"

Implementation notes and constraints

- Single-screen behavior: a boolean state variable (e.g., `showCardEntry`) controls whether the UI displays Part 1 or Part 2. Use smooth animated transitions like the screen swiped from bottom to top, and remain a row with a summarized text to the pervoius part and a circleTrue Phosphoricon and mainAxisAlignment.spaceBetween for the row and a divider with an indent and endindent under the row.
- Only transition to Part 2 when selected account type is Visa, MasterCard, or Bank. If Cash is selected, pressing Add Account should not show Part 2 but instead provide UI feedback (SnackBar) and remain on Part 1.
- Use `flutter_credit_card` for the card preview and keep CVV masked or omitted; do NOT implement CVV input.
- Do NOT implement the dotted 'Connect Banking Service' container from the mockup.
- Localize every hard-coded string via ARB files and ensure RTL layout is respected for Arabic.
- Validation: account name required; initial balance accepts decimals; card number and expiry basic formatting only.
- Keep the implementation UI-only (no network calls or persistent storage).

Estimated time
Approximately 3 hours (180 minutes) for UI-only implementation including localization and wiring routes.

Next steps

- Implement the single-screen scaffold and widgets. I will scaffold the Dart files and ARB files next if you confirm.
