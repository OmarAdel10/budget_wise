import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionRepository {
  final AuthRepository _authRepository = AuthRepository();

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
    final CollectionReference<TransactionModel> collection = getTransactionsCollection();
    final DocumentReference<TransactionModel> doc = collection.doc();
    transactionModel.id = doc.id;
    if(_authRepository.currentUser != null){transactionModel.userId = _authRepository.currentUser!.uid;}
    await doc.set(transactionModel);
  }

  Future<void> updateUserIdInAllTransactionsAfterFirstTimeLoginOnly() async {
    final CollectionReference<TransactionModel> collection = getTransactionsCollection();
    final QuerySnapshot<TransactionModel> querySnapshot = await collection.get();
    if(_authRepository.currentUser != null){
      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'userId': _authRepository.currentUser!.uid});
      }
    }
  }
}
