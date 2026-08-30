/// Fixed IDs for system categories (not shown in user-facing pickers).
abstract final class SystemCategoryIds {
  static const balanceAdjustment = 'balance_adjustment';
  static const accountTransfer = 'account_transfer';

  static bool isSystem(String categoryId) =>
      categoryId == balanceAdjustment || categoryId == accountTransfer;

  static bool isBalanceAdjustment(String categoryId) =>
      categoryId == balanceAdjustment;

  static bool isAccountTransfer(String categoryId) =>
      categoryId == accountTransfer;
}
