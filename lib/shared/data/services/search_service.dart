import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../utils/sms_text_normalizer.dart';

/// A generic, reusable search service that manages search state using
/// [ValueNotifier] for reactive filtering.
///
/// Generic [T] allows use with any data type. Configure [searchFieldsExtractor]
/// to define which fields of [T] to search against, and [textNormalizer] to
/// control text normalization (defaults to [SmsTextNormalizer.normalizeForSearch]
/// for Arabic + English support).
///
/// Features:
/// - Debounced search (configurable via [debounceDuration])
/// - Multi-field search (OR logic)
/// - Text normalization (Arabic digits, characters, diacritics, etc.)
/// - Reactive [filteredListNotifier] for efficient UI rebuilds
///
/// Usage:
/// ```dart
/// final search = SearchService<CategoryModel>(
///   searchFieldsExtractor: (cat) => [cat.categoryTitle],
/// );
///
/// // In build:
/// BottomSheetService.headerWithSearch(
///   searchController: search.searchController,
///   ...
/// ),
/// ValueListenableBuilder<List<CategoryModel>>(
///   valueListenable: search.filteredListNotifier,
///   builder: (context, filtered, _) => renderList(filtered),
/// );
/// ```
class SearchService<T> {
  /// Controller bound to the search input field.
  /// Pass this to [BottomSheetService.searchBar] or similar widgets.
  final TextEditingController searchController = TextEditingController();

  /// Exposes the current raw (unnormalized) query text.
  /// Use this when you need the original user input (e.g., for highlighting).
  final ValueNotifier<String> queryNotifier = ValueNotifier<String>('');

  /// Exposes the filtered result list.
  /// Listen to this in the UI via [ValueListenableBuilder] for reactive rebuilds.
  final ValueNotifier<List<T>> filteredListNotifier = ValueNotifier<List<T>>(
    [],
  );

  /// Returns the fields of [item] to search against.
  /// Multiple fields are combined with OR logic — an item matches if **any**
  /// of its extracted fields contains the normalized query.
  final Iterable<String> Function(T item) searchFieldsExtractor;

  /// Normalizes text before matching. Applied to **both** the query and
  /// each extracted field, ensuring they are in the same normalized space.
  ///
  /// Defaults to [SmsTextNormalizer.normalizeForSearch] which handles:
  /// - Arabic digit normalization (٠١٢٣ → 0123)
  /// - Arabic character variants (إأآ → ا, ى → ي, etc.)
  /// - Diacritics (tashkeel) removal
  /// - Non-word character replacement
  /// - Whitespace normalization
  /// - Lowercasing
  final String Function(String) textNormalizer;

  /// Debounce duration applied to search input changes.
  ///
  /// - `Duration(milliseconds: 300)` (default) — filters 300ms after the user
  ///   stops typing, reducing unnecessary filtering on every keystroke.
  /// - `Duration.zero` — filters immediately on every change.
  /// - `null` — also disables debouncing.
  final Duration? debounceDuration;

  /// Internal source data.
  List<T> _source = [];

  /// Timer for debouncing.
  Timer? _debounceTimer;

  /// Cached normalized query to avoid re-normalizing per item during filtering.
  String _normalizedQuery = '';

  SearchService({
    required this.searchFieldsExtractor,
    List<T> initialSource = const [],
    this.debounceDuration = const Duration(milliseconds: 300),
    String Function(String)? textNormalizer,
  }) : textNormalizer = textNormalizer ?? SmsTextNormalizer.normalizeForSearch {
    _source = initialSource;
    searchController.addListener(_onSearchChanged);
    _filter();
  }

  /// Called whenever the search controller's text changes.
  void _onSearchChanged() {
    queryNotifier.value = searchController.text;

    if (debounceDuration != null && debounceDuration! > Duration.zero) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounceDuration!, _filter);
    } else {
      _filter();
    }
  }

  /// Filters [_source] based on the current query and updates
  /// [filteredListNotifier].
  void _filter() {
    final rawQuery = searchController.text;
    _normalizedQuery = textNormalizer(rawQuery);

    if (_normalizedQuery.isEmpty) {
      filteredListNotifier.value = List<T>.from(_source);
      return;
    }

    filteredListNotifier.value = _source.where((item) {
      final fields = searchFieldsExtractor(item);
      return fields.any((field) {
        final normalizedField = textNormalizer(field);
        return normalizedField.contains(_normalizedQuery);
      });
    }).toList();
  }

  /// Replaces the source data and re-filters using the current query.
  ///
  /// Call this when the underlying data changes (e.g., when a Bloc emits
  /// a new state with an updated list).
  void updateSource(List<T> source) {
    _source = source;
    _filter();
  }

  /// Clears the search query and resets [filteredListNotifier] to the full
  /// source list.
  void clear() {
    searchController.clear();
    // _onSearchChanged fires → _filter() → full source
  }

  /// Releases all resources.
  ///
  /// Call this in [State.dispose] when the owning widget is destroyed.
  void dispose() {
    _debounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    queryNotifier.dispose();
    filteredListNotifier.dispose();
  }
}
