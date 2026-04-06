import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryRepository {
  final AuthRepository authRepository;
  const CategoryRepository({required this.authRepository});

  CollectionReference<CategoryModel> getCategoriesCollection() =>
      FirebaseFirestore.instance
          .collection('categories')
          .withConverter<CategoryModel>(
            fromFirestore: (snapshot, options) =>
                CategoryModel.fromMap(snapshot.data()!),
            toFirestore: (categoryModel, options) => categoryModel.toMap(),
          );

  Future<void> addCategory(CategoryModel categoryModel) async {
    final CollectionReference<CategoryModel> collection =
        getCategoriesCollection();
    final DocumentReference<CategoryModel> doc = collection.doc(
      categoryModel.id,
    );
    await doc.set(categoryModel);
  }

  Future<void> updateUserIdInAllCategoriesAfterFirstTimeLoginOnly() async {
    final CollectionReference<CategoryModel> collection =
        getCategoriesCollection();
    final QuerySnapshot<CategoryModel> querySnapshot = await collection.get();
    if (authRepository.currentUser != null) {
      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'userId': authRepository.currentUser!.uid});
      }
    }
  }

  // Future<List<CategoryModel>> getAllCategories() async {
  //   final CollectionReference<CategoryModel> collection =
  //       getCategoriesCollection();
  //   final user = authRepository.currentUser;
  //   if (user != null) {
  //     final querySnapShot = await collection
  //         .where('userId', isEqualTo: user.uid)
  //         .where('type', isEqualTo: 'expense')
  //         .orderBy('index')
  //         .get();
  //     return querySnapShot.docs.map((doc) => doc.data()).toList();
  //   }
  //   return [];
  // }

  Future<List<CategoryModel>> fetchAllCategories() async {
    final CollectionReference<CategoryModel> collection =
        getCategoriesCollection();
    final user = authRepository.currentUser;
    if (user != null) {
      final querySnapShot = await collection
          .where('userId', isEqualTo: user.uid)
          .orderBy('index')
          .get();
      return querySnapShot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<void> updateCategoryIndexes(List<CategoryModel> categories) async {
    final batch = FirebaseFirestore.instance.batch();
    final collection = getCategoriesCollection();

    for (var category in categories) {
      batch.update(collection.doc(category.id), {'index': category.index});
    }

    await batch.commit();
  }

  Future<void> deleteCategory(String categoryId) async {
    final CollectionReference<CategoryModel> collection =
        getCategoriesCollection();
    await collection.doc(categoryId).delete();
  }

  Future<CategoryModel?> fetchCategoryById(String categoryId) async {
    final doc = await getCategoriesCollection().doc(categoryId).get();
    return doc.data();
  }
}
