class ExportDateState {
  final DateTime start;
  final DateTime end;
  final bool isRange;

  ExportDateState({
    required this.start,
    required this.end,
    this.isRange = false,
  });

  ExportDateState copyWith({DateTime? start, DateTime? end, bool? isRange}) {
    return ExportDateState(
      start: start ?? this.start,
      end: end ?? this.end,
      isRange: isRange ?? this.isRange,
    );
  }
}
