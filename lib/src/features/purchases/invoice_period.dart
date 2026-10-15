class InvoicePeriod {
  const InvoicePeriod._({required this.rocYear, required this.endMonth});

  factory InvoicePeriod.fromPurchaseDate(DateTime date) {
    final localDate = date.toLocal();
    final endMonth =
        localDate.month.isEven ? localDate.month : localDate.month + 1;
    return InvoicePeriod._(
      rocYear: localDate.year - 1911,
      endMonth: endMonth,
    );
  }

  factory InvoicePeriod.fromRocTerm(String value) {
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      throw const FormatException('發票期別必須是民國年 yyyMM');
    }
    final rocYear = int.parse(value.substring(0, 3));
    final endMonth = int.parse(value.substring(3));
    if (rocYear < 1 || !const {2, 4, 6, 8, 10, 12}.contains(endMonth)) {
      throw const FormatException('發票期別月份必須是 02 至 12 的雙數月');
    }
    return InvoicePeriod._(rocYear: rocYear, endMonth: endMonth);
  }

  final int rocYear;
  final int endMonth;

  int get gregorianYear => rocYear + 1911;
  String get rocTerm => '$rocYear${endMonth.toString().padLeft(2, '0')}';
  String get displayLabel => '$rocYear 年 ${endMonth - 1}–$endMonth 月';
  DateTime get startDate => DateTime(gregorianYear, endMonth - 1);
  DateTime get endExclusive => DateTime(gregorianYear, endMonth + 1);
  DateTime get drawDate => DateTime(gregorianYear, endMonth + 1, 25);
}
