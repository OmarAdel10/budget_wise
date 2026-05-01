part of 'csv_bloc.dart';

abstract class CsvEvent {
  const CsvEvent();
}

class CsvExportRequested extends CsvEvent {
  final DateTime start;
  final DateTime end;

  const CsvExportRequested({required this.start, required this.end});
}

class CsvImportRequested extends CsvEvent {
  const CsvImportRequested();
}
