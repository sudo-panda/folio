class Latest {
  double value = 0.0;
  String change = "";
  String percentageChange = "";
  int sign = 0;
  String updated = "";

  Latest();

  Latest.fromData(
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
