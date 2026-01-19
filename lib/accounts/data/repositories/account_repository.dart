import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountRepository {
  final AuthRepository authRepo = AuthRepository();

  CollectionReference<AccountModel> getAccountCollection() => FirebaseFirestore
      .instance
      .collection('accounts')
      .withConverter<AccountModel>(
        fromFirestore: (snapshot, options) =>
            AccountModel.fromMap(snapshot.data()!),
        toFirestore: (accountModel, options) => accountModel.toMap(),
      );

  Future<void> addAccount(AccountModel model) async {
    final CollectionReference<AccountModel> collection = getAccountCollection();
    final DocumentReference<AccountModel> doc = collection.doc(model.id);
    await doc.set(model);
  }

  Future<void> updateAccountUpdatedAt(String accountId, DateTime newDate) async {
    final CollectionReference<AccountModel> collection = getAccountCollection();
    final QuerySnapshot<AccountModel> querySnapshot =
        await collection.where('id', isEqualTo: accountId).get();
    for (final doc in querySnapshot.docs) {
      await doc.reference.update({'updatedAt': newDate.toIso8601String()});
    }
  }

  Future<void> updateAccountBalance(
    String accountId,
    double newBalance,
    DateTime updatedAt,
  ) async {
    final CollectionReference<AccountModel> collection = getAccountCollection();
    final QuerySnapshot<AccountModel> querySnapshot =
        await collection.where('id', isEqualTo: accountId).get();
    for (final doc in querySnapshot.docs) {
      await doc.reference.update({
        'balance': newBalance,
        'updatedAt': updatedAt.toIso8601String(),
      });
    }
  }

  Future<List<AccountModel>> fetchAllAccounts() async {
    final CollectionReference<AccountModel> collection = getAccountCollection();
    final user = authRepo.currentUser;

    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<void> deleteAccount(String accountId) async {
    final CollectionReference<AccountModel> collection = getAccountCollection();
    await collection.doc(accountId).delete();
  }
}
