class Latest {
  double? value;
  String? change;
  String? percentageChange;
  int sign = 0;
  String? updated;

  Latest();

  Latest.fromData(
      this.value, this.change, this.percentageChange, this.sign, this.updated);

  @override
  String toString() {
    return 'value: ' +
        (value?.toStringAsFixed(2) ?? "NULL") +
        '\nchange: ' +
        (change ?? "NULL") +
        '\npercentageChange: ' +
        (percentageChange ?? "NULL") +
        '\nsign: ' +
        sign.toString() +
        '\ntime: ' +
        (updated ?? "NULL");
  }
}
