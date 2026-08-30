import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/transaction/data/models/merchant_category_mapping.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantCategoryLearningRepository {
  static const _prefsKey = 'merchant_category_mappings';

  final SharedPreferences prefs;
  final AuthRepository authRepository;
  final FirebaseFirestore firestore;

  MerchantCategoryLearningRepository({
    required this.prefs,
    required this.authRepository,
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  List<MerchantCategoryMapping> loadLocalMappings() {
    final rawMappings = prefs.getStringList(_prefsKey) ?? [];
    return rawMappings.map(MerchantCategoryMapping.fromJson).toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
  }

  Future<void> saveLocalMappings(List<MerchantCategoryMapping> mappings) async {
    await prefs.setStringList(
      _prefsKey,
      mappings.map((mapping) => mapping.toJson()).toList(),
    );
  }

  MerchantCategoryMapping? findBestMapping({
    required String merchantName,
    required TransactionType transactionType,
    List<MerchantCategoryMapping>? mappings,
  }) {
    final candidates =
        (mappings ?? loadLocalMappings())
            .where((mapping) => mapping.transactionType == transactionType)
            .where((mapping) => mapping.matchesMerchant(merchantName))
            .toList()
          ..sort((a, b) => b.useCount.compareTo(a.useCount));

    return candidates.firstOrNull;
  }

  Future<MerchantCategoryMapping> saveMapping({
    required String merchantName,
    required String categoryId,
    required String categoryTitle,
    required TransactionType transactionType,
  }) async {
    final userId = authRepository.currentUser?.uid ?? '';
    final mappings = loadLocalMappings();
    final existingIndex = mappings.indexWhere(
      (mapping) =>
          mapping.transactionType == transactionType &&
          mapping.matchesMerchant(merchantName),
    );

    final MerchantCategoryMapping saved;
    if (existingIndex == -1) {
      saved = MerchantCategoryMapping.create(
        merchantName: merchantName,
        categoryId: categoryId,
        categoryTitle: categoryTitle,
        transactionType: transactionType,
        userId: userId,
      );
      mappings.add(saved);
    } else {
      saved = mappings[existingIndex].incrementUse(
        categoryId: categoryId,
        categoryTitle: categoryTitle,
        transactionType: transactionType,
        userId: userId,
      );
      mappings[existingIndex] = saved;
    }

    await saveLocalMappings(mappings);
    try {
      await syncMappingIfLoggedIn(saved);
    } catch (_) {
      // Local learning must remain available even when cloud sync is offline.
    }
    return saved;
  }

  Future<void> syncMappingIfLoggedIn(MerchantCategoryMapping mapping) async {
    final user = authRepository.currentUser;
    if (user == null) return;

    final synced = mapping.copyWith(userId: user.uid, isSynced: true);
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('merchantCategoryMappings')
        .doc(mapping.id)
        .set(synced.toMap());

    final mappings = loadLocalMappings();
    final index = mappings.indexWhere((item) => item.id == mapping.id);
    if (index != -1) {
      mappings[index] = synced;
      await saveLocalMappings(mappings);
    }
  }

  Future<void> deleteMapping(String id) async {
    final mappings = loadLocalMappings();
    final index = mappings.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final removed = mappings.removeAt(index);
    await saveLocalMappings(mappings);

    try {
      final user = authRepository.currentUser;
      if (user != null && removed.isSynced) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('merchantCategoryMappings')
            .doc(id)
            .delete();
      }
    } catch (_) {
      // Local deletion must remain available even when cloud sync is offline.
    }
  }
}
