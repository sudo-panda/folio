class Statement {
  DateTime date;
  String bseCode;
  String nseCode;
  String exchange;
  bool bought;
  int qty;
  double rate;

  Statement(this.date, this.bseCode, this.nseCode, this.exchange, this.bought,
      this.qty, this.rate);
}
