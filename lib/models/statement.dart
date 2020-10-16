class Statement {
  String _code;
  String _exchange;
  int _qty;
  double _rate;

  Statement(this._code, this._exchange, this._qty, this._rate);

  String get code => _code;

  String get exchange => _exchange;

  int get qty => _qty;

  double get rate => _rate;
}
