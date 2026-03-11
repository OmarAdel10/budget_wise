import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsRepository {
  final AuthRepository authRepo;
  const SavingsRepository({required this.authRepo});

  CollectionReference<SavingsModel> getSavingsCollection() => FirebaseFirestore
      .instance
      .collection('savings')
      .withConverter<SavingsModel>(
        fromFirestore: (snapshot, options) =>
            SavingsModel.fromMap(snapshot.data()!),
        toFirestore: (savingGoalModel, options) => savingGoalModel.toMap(),
      );

  Future<void> addSavingGoal(SavingsModel model) async {
    final CollectionReference<SavingsModel> collection = getSavingsCollection();
    final DocumentReference<SavingsModel> doc = collection.doc(model.id);
    await doc.set(model);
  }

  Future<List<SavingsModel>> fetchAllSavingGoals() async {
    final CollectionReference<SavingsModel> collection = getSavingsCollection();
    final user = authRepo.currentUser;

    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<void> updateSavingGoal(SavingsModel model) async {
    final CollectionReference<SavingsModel> collection = getSavingsCollection();
    await collection.doc(model.id).update(model.toMap());
  }

  Future<void> deleteSavingGoal(String goalId) async {
    final CollectionReference<SavingsModel> collection = getSavingsCollection();
    await collection.doc(goalId).delete();
  }

  Future<void> updateContribution(
    String goalId,
    double newAmount,
    List<int> completedDays,
    Map<int, double> customAmounts,
    DateTime updatedAt,
  ) async {
    final CollectionReference<SavingsModel> collection =
        getSavingsCollection();
    await collection.doc(goalId).update({
      'currentAmount': newAmount,
      'completedDays': completedDays,
      'customAmounts': customAmounts.map((k, v) => MapEntry(k.toString(), v)),
      'updatedAt': updatedAt.toIso8601String(),
    });
  }
}
