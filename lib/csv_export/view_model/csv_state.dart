part of 'csv_bloc.dart';

abstract class CsvState {
  const CsvState();
}

class CsvInitial extends CsvState {
  const CsvInitial();
}

class CsvLoading extends CsvState {
  final String message;
  const CsvLoading(this.message);
}

class CsvExportSuccess extends CsvState {
  const CsvExportSuccess();
}

class CsvImportSuccess extends CsvState {
  final int count;
  final int skipped;
  const CsvImportSuccess(this.count, {this.skipped = 0});
}

class CsvFailure extends CsvState {
  final String message;
  const CsvFailure(this.message);
}
