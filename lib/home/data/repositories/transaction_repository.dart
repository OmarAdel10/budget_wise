import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionRepository {
  final AuthRepository authRepository;
  const TransactionRepository({required this.authRepository});

  CollectionReference<TransactionModel> getTransactionsCollection() =>
      FirebaseFirestore.instance
          .collection('transactions')
          .withConverter<TransactionModel>(
            fromFirestore: (snapshot, options) =>
                TransactionModel.fromMap(snapshot.data()!),
            toFirestore: (transactionModel, options) =>
                transactionModel.toMap(),
          );

  Future<void> addTransaction(TransactionModel transactionModel) async {
    final CollectionReference<TransactionModel> collection =
        getTransactionsCollection();
    final DocumentReference<TransactionModel> doc = collection.doc(
      transactionModel.id,
    );
    await doc.set(transactionModel);
  }

  Future<void> updateUserIdInAllTransactionsAfterFirstTimeLoginOnly() async {
    final CollectionReference<TransactionModel> collection =
        getTransactionsCollection();
    final QuerySnapshot<TransactionModel> querySnapshot = await collection
        .get();
    if (authRepository.currentUser != null) {
      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'userId': authRepository.currentUser!.uid});
      }
    }
  }

  Future<List<TransactionModel>> getAllTransactionsByType(String type) async {
    final CollectionReference<TransactionModel> collection =
        getTransactionsCollection();
    final user = authRepository.currentUser;
    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: type)
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<List<TransactionModel>> getTransactionsByCategoryId(
    String categoryId,
  ) async {
    final CollectionReference<TransactionModel> collection =
        getTransactionsCollection();
    final user = authRepository.currentUser;
    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('transactionDate', descending: true)
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<List<TransactionModel>> getTransactionsByMonth(DateTime date) async {
    final CollectionReference<TransactionModel> collection =
        getTransactionsCollection();
    final user = authRepository.currentUser;
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .where(
            'transactionDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'transactionDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .orderBy('transactionDate', descending: true)
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<List<TransactionModel>> fetchAllTransactions() async {
    final CollectionReference<TransactionModel> collection =
        getTransactionsCollection();
    final user = authRepository.currentUser;

    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .orderBy('transactionDate', descending: true)
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<void> deleteTransaction(String transactionId) async {
    final CollectionReference<TransactionModel> collection =
        getTransactionsCollection();
    await collection.doc(transactionId).delete();
  }
}
