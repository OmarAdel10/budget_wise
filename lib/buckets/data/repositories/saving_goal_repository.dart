import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/repositories/account_repository.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/data/repositories/transaction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:uuid/uuid.dart';

class SavingGoalRepository {
  final AuthRepository authRepo;
  final AccountRepository accountRepo;
  final TransactionRepository transactionRepo;

  const SavingGoalRepository({
    required this.authRepo,
    required this.accountRepo,
    required this.transactionRepo,
  });

  CollectionReference<SavingGoalModel> getSavingGoalsCollection() => FirebaseFirestore
      .instance
      .collection('savings')
      .withConverter<SavingGoalModel>(
        fromFirestore: (snapshot, options) =>
            SavingGoalModel.fromMap(snapshot.data()!),
        toFirestore: (savingGoalModel, options) => savingGoalModel.toMap(),
      );

  Future<void> addSavingGoal(SavingGoalModel model) async {
    final CollectionReference<SavingGoalModel> collection = getSavingGoalsCollection();
    final DocumentReference<SavingGoalModel> doc = collection.doc(model.id);
    await doc.set(model);
  }

  Future<SavingGoalModel> createGoalWithAccount(SavingGoalModel model) async {
    // 1. Create the Saving Account
    final savingAccount = AccountModel(
      id: const Uuid().v4(),
      userId: model.userId,
      accountType: AccountType.saving,
      title: '${model.name} (Saving)',
      accountIcon: PhosphorIconsBold.tipJar,
      initialBalance: 0.0,
      balance: 0.0,
      currency: model.currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await accountRepo.addAccount(savingAccount);

    // 2. Add Saving Goal with the linked account ID
    final finalModel = model.copyWith(savingAccountId: savingAccount.id);
    await addSavingGoal(finalModel);
    return finalModel;
  }

  Future<List<SavingGoalModel>> bulkCreateGoalsWithAccounts(
    List<SavingGoalModel> models,
  ) async {
    final createdGoals = <SavingGoalModel>[];

    for (final model in models) {
      createdGoals.add(await createGoalWithAccount(model));
    }

    return createdGoals;
  }

  Future<List<SavingGoalModel>> fetchAllSavingGoals() async {
    final CollectionReference<SavingGoalModel> collection = getSavingGoalsCollection();
    final user = authRepo.currentUser;

    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<void> updateSavingGoal(SavingGoalModel model) async {
    final CollectionReference<SavingGoalModel> collection = getSavingGoalsCollection();
    await collection.doc(model.id).update(model.toMap());
  }

  Future<void> deleteSavingGoal(String goalId) async {
    final CollectionReference<SavingGoalModel> collection = getSavingGoalsCollection();
    await collection.doc(goalId).delete();
  }

  Future<void> processContribution({
    required SavingGoalModel goal,
    required int day,
    required double amount,
    required AccountModel sourceAccount,
    required AccountModel savingAccount,
  }) async {
    final now = DateTime.now();

    // 1. Create Expense Transaction from Source
    final expenseTrans = TransactionModel(
      id: const Uuid().v4(),
      userId: goal.userId,
      type: TransactionType.expense,
      description: 'Saving Contribution: ${goal.name}',
      transactionAmount: amount,
      transactionCurrency: goal.currency,
      categoryId: 'saving_contribution', // Special category ID
      accountId: sourceAccount.id,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
    );

    // 2. Create Income Transaction to Saving Account
    final incomeTrans = TransactionModel(
      id: const Uuid().v4(),
      userId: goal.userId,
      type: TransactionType.income,
      description: 'Saving Contribution: ${goal.name}',
      transactionAmount: amount,
      transactionCurrency: goal.currency,
      categoryId: 'saving_contribution',
      accountId: savingAccount.id,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
    );

    await transactionRepo.addTransaction(expenseTrans);
    await transactionRepo.addTransaction(incomeTrans);

    // 3. Update Account Balances
    await accountRepo.updateAccountBalance(
      sourceAccount.id,
      sourceAccount.balance - amount,
      now,
    );
    await accountRepo.updateAccountBalance(
      savingAccount.id,
      savingAccount.balance + amount,
      now,
    );

    // 4. Update Goal Progress
    final List<int> updatedDays = List.from(goal.completedDays)..add(day);
    final Map<int, DateTime> updatedDates = Map.from(goal.contributionDates)
      ..[day] = now;

    await updateContribution(
      goal.id,
      goal.currentAmount + amount,
      updatedDays,
      updatedDates,
      goal.customAmounts,
      now,
    );
  }

  Future<void> updateContribution(
    String goalId,
    double newAmount,
    List<int> completedDays,
    Map<int, DateTime> contributionDates,
    Map<int, double> customAmounts,
    DateTime updatedAt,
  ) async {
    final CollectionReference<SavingGoalModel> collection = getSavingGoalsCollection();
    await collection.doc(goalId).update({
      'currentAmount': newAmount,
      'completedDays': completedDays,
      'contributionDates': contributionDates.map(
        (k, v) => MapEntry(k.toString(), v.toIso8601String()),
      ),
      'customAmounts': customAmounts.map((k, v) => MapEntry(k.toString(), v)),
      'updatedAt': updatedAt.toIso8601String(),
    });
  }
}
