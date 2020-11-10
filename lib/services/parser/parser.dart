import 'package:folio/models/trades/trade_log.dart';

abstract class Parser {
  String _file;
  Parser(this._file);

  List<TradeLog> get statementsList;
}
