import 'package:folio/models/tradelog.dart';

abstract class Parser {
  String _file;
  Parser(this._file);

  List<TradeLog> get statementsList;
}
