import 'dart:convert';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:budget_wise/home/data/models/home_model.dart';

enum StatisticsSorting { highestAmount, lowestAmount, alphabetical }

class StatisticsModel extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final double totalSubscriptions;
  final List<CategoriesWithSpending> incomeBreakdown;
  final List<CategoriesWithSpending> expenseBreakdown;
  final List<double> dailyIncomeTrend;
  final List<double> dailyExpenseTrend;
  final StatisticsSorting sortingType;
  final DateTime selectedMonth;
  final ToggleOption toggleType;

  const StatisticsModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.totalSubscriptions,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.dailyIncomeTrend,
    required this.dailyExpenseTrend,
    required this.sortingType,
    required this.selectedMonth,
    this.toggleType = ToggleOption.expense,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    totalSavings,
    totalSubscriptions,
    incomeBreakdown,
    expenseBreakdown,
    dailyIncomeTrend,
    dailyExpenseTrend,
    sortingType,
    selectedMonth,
    toggleType,
  ];

  StatisticsModel copyWith({
    double? totalIncome,
    double? totalExpenses,
    double? totalSavings,
    double? totalSubscriptions,
    List<CategoriesWithSpending>? incomeBreakdown,
    List<CategoriesWithSpending>? expenseBreakdown,
    List<double>? dailyIncomeTrend,
    List<double>? dailyExpenseTrend,
    StatisticsSorting? sortingType,
    DateTime? selectedMonth,
    ToggleOption? toggleType,
  }) {
    return StatisticsModel(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalSavings: totalSavings ?? this.totalSavings,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
      incomeBreakdown: incomeBreakdown ?? this.incomeBreakdown,
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
      dailyIncomeTrend: dailyIncomeTrend ?? this.dailyIncomeTrend,
      dailyExpenseTrend: dailyExpenseTrend ?? this.dailyExpenseTrend,
      sortingType: sortingType ?? this.sortingType,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      toggleType: toggleType ?? this.toggleType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'totalSavings': totalSavings,
      'totalSubscriptions': totalSubscriptions,
      'incomeBreakdown': incomeBreakdown.map((x) => x.toMap()).toList(),
      'expenseBreakdown': expenseBreakdown.map((x) => x.toMap()).toList(),
      'dailyIncomeTrend': dailyIncomeTrend,
      'dailyExpenseTrend': dailyExpenseTrend,
      'sortingType': sortingType.index,
      'selectedMonth': selectedMonth.millisecondsSinceEpoch,
      'toggleType': toggleType.index,
    };
  }

  factory StatisticsModel.fromMap(Map<String, dynamic> map) {
    return StatisticsModel(
      totalIncome: (map['totalIncome'] as num).toDouble(),
      totalExpenses: (map['totalExpenses'] as num).toDouble(),
      totalSavings: (map['totalSavings'] as num).toDouble(),
      totalSubscriptions: (map['totalSubscriptions'] as num).toDouble(),
      incomeBreakdown: List<CategoriesWithSpending>.from(
        (map['incomeBreakdown'] as List<dynamic>).map<CategoriesWithSpending>(
          (x) => CategoriesWithSpending.fromMap(x as Map<String, dynamic>),
        ),
      ),
      expenseBreakdown: List<CategoriesWithSpending>.from(
        (map['expenseBreakdown'] as List<dynamic>).map<CategoriesWithSpending>(
          (x) => CategoriesWithSpending.fromMap(x as Map<String, dynamic>),
        ),
      ),
      dailyIncomeTrend: List<double>.from(map['dailyIncomeTrend'] as List),
      dailyExpenseTrend: List<double>.from(map['dailyExpenseTrend'] as List),
      sortingType: StatisticsSorting.values[map['sortingType'] as int],
      selectedMonth: DateTime.fromMillisecondsSinceEpoch(
        map['selectedMonth'] as int,
      ),
      toggleType:
          map['toggleType'] != null &&
              (map['toggleType'] as num).toInt() < ToggleOption.values.length
          ? ToggleOption.values[(map['toggleType'] as num).toInt()]
          : ToggleOption.expense,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatisticsModel.fromJson(String source) =>
      StatisticsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
