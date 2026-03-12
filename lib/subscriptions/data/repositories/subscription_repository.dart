import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionRepository {
  final AuthRepository authRepo;
  const SubscriptionRepository({required this.authRepo});

  CollectionReference<SubscriptionModel> getSubscriptionCollection() =>
      FirebaseFirestore.instance
          .collection('subscriptions')
          .withConverter<SubscriptionModel>(
            fromFirestore: (snapshot, options) =>
                SubscriptionModel.fromMap(snapshot.data()!),
            toFirestore: (model, options) => model.toMap(),
          );

  Future<void> addSubscription(SubscriptionModel model) async {
    final collection = getSubscriptionCollection();
    await collection.doc(model.id).set(model);
  }

  Future<void> updateSubscription(SubscriptionModel model) async {
    final collection = getSubscriptionCollection();
    await collection.doc(model.id).update(model.toMap());
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    final collection = getSubscriptionCollection();
    await collection.doc(subscriptionId).delete();
  }

  Future<List<SubscriptionModel>> fetchAllSubscriptions() async {
    final collection = getSubscriptionCollection();
    final user = authRepo.currentUser;

    if (user != null) {
      final querySnapshot = await collection
          .where('userId', isEqualTo: user.uid)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  /// Syncs local changes back to Firestore for specific subscription.
  Future<void> syncSubscription(SubscriptionModel model) async {
    await addSubscription(model.copyWith(isSynced: true));
  }
}
