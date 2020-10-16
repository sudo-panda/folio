import 'package:folio/models/statement.dart';

abstract class Parser {
  String _file;
  Parser(this._file);

  List<Statement> get statementsList;
}
