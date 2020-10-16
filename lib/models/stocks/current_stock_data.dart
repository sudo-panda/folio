class CurrentStockData {
  double value;
  String change;
  String percentageChange;
  int sign;
  String updated;

  CurrentStockData(); //TODO: remove

  CurrentStockData.fromData(
      this.value, this.change, this.percentageChange, this.sign, this.updated);

  @override
  String toString() {
    return 'value: ' +
        value.toStringAsFixed(2) +
        '\nchange: ' +
        change +
        '\npercentageChange: ' +
        percentageChange +
        '\nsign: ' +
        sign.toString() +
        '\ntime: ' +
        updated;
  }
}
