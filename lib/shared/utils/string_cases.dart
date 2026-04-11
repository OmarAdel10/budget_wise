extension StringCases on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : word,
        )
        .join(' ');
  }

  String initialChars() {
    if (isEmpty) return this;
    return split(' ')
        .where((word) => word.toLowerCase() != 'of')
        .map((word) {
          return word.isNotEmpty ? word[0].toUpperCase() : word;
        })
        .where((initial) => initial.isNotEmpty)
        .join('.');
  }
}
