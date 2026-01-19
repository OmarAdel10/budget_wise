# Implementation Plan: Add Account Screen UI

## 1. Objective

The goal is to create a new screen for adding a bank account and an associated card. The screen will consist of two parts, displayed sequentially within a single screen/widget. All text will be localized for English and Arabic.

## 2. Prerequisites

- A Flutter project environment is already set up.
- The project has an existing localization setup (`.arb` files).

## 3. Step-by-Step Implementation

### Step 1: Add Dependency

- Add the `flutter_credit_card` package to the `pubspec.yaml` file under `dependencies`.
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    flutter_credit_card: ^4.0.1 # Use the latest version
  ```
- Run `flutter pub get` in the terminal to install the package.

### Step 2: Add Localization Strings

- Identify all hardcoded text from the UI mockups.
- Add the following key-value pairs to `lib/l10n/app_en.arb`:
  ```json
  {
    "addNewAccount": "Add New Account",
    "bankName": "Bank Name",
    "enterBankName": "Enter bank name",
    "accountHolderName": "Account Holder Name",
    "enterAccountHolderName": "Enter account holder name",
    "accountNumber": "Account Number",
    "enterAccountNumber": "Enter account number",
    "addAccount": "Add Account",
    "addNewCard": "Add New Card",
    "cardHolderName": "Card Holder Name",
    "cardNumber": "Card Number",
    "expiryDate": "Expiry Date",
    "save": "Save"
  }
  ```
- Add the corresponding translations to `lib/l10n/app_ar.arb`:
  ```json
  {
    "addNewAccount": "إضافة حساب جديد",
    "bankName": "اسم البنك",
    "enterBankName": "أدخل اسم البنك",
    "accountHolderName": "اسم صاحب الحساب",
    "enterAccountHolderName": "أدخل اسم صاحب الحساب",
    "accountNumber": "رقم الحساب",
    "enterAccountNumber": "أدخل رقم الحساب",
    "addAccount": "إضافة حساب",
    "addNewCard": "إضافة بطاقة جديدة",
    "cardHolderName": "اسم صاحب البطاقة",
    "cardNumber": "رقم البطاقة",
    "expiryDate": "تاريخ الانتهاء",
    "save": "حفظ"
  }
  ```
- Run `flutter gen-l10n` to generate the localization delegates.

### Step 3: Create the Screen File

- Create a new file at `lib/accounts/view/screens/add_account_screen.dart`.

### Step 4: Implement the Add Account Screen UI

- In `add_account_screen.dart`, create a `StatefulWidget` named `AddAccountScreen`.
- Use a boolean state variable, `_isCardUiVisible`, initialized to `false`, to toggle between the two parts of the screen.
- The `build` method will return a `Scaffold` containing an `AppBar` and a body that conditionally renders the appropriate UI based on `_isCardUiVisible`.

#### Part 1: Account Details Form (`_isCardUiVisible == false`)

- The `AppBar` title will be `S.of(context).addNewAccount`.
- The body will be a `SingleChildScrollView` containing a `Form` with:
  - `TextFormField` for "Bank Name".
  - `TextFormField` for "Account Holder Name".
  - `TextFormField` for "Account Number".
- An `ElevatedButton` with the label `S.of(context).addAccount`.
- The button's `onPressed` callback will call `setState(() { _isCardUiVisible = true; })`.

#### Part 2: Card Details Form (`_isCardUiVisible == true`)

- The `AppBar` title will be `S.of(context).addNewCard`.
- The body will contain:
  - A `CreditCardWidget` from the `flutter_credit_card` package to display the card preview. This will be linked to form field controllers.
  - A `CreditCardForm` widget (or custom `TextFormField`s) for:
    - Card Holder Name
    - Card Number
    - Expiry Date
  - **The CVV field will be explicitly hidden/excluded.**
  - An `ElevatedButton` with the label `S.of(context).save`. The `onPressed` logic will be empty for this UI-only task.

### Step 5: Add Navigation

- In `lib/accounts/view/screens/accounts_screen.dart`, add a `FloatingActionButton`.
- In its `onPressed` callback, use `Navigator.push` to navigate to the `AddAccountScreen`.

## 4. Exclusions

As per the requirements, the following will be **excluded** from the implementation:

- **CVV Field:** The input field for the card's CVV code will not be implemented.
- **Connect Banking Service:** The dotted container UI for connecting to a banking service will not be implemented.
- **Backend Logic:** No backend or data-saving logic will be implemented for the forms. This is a UI-only task.
