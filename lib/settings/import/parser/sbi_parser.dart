import 'dart:developer';

import 'package:folio/settings/import/parser/parser.dart';
import 'package:folio/models/statement.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class SBIParser extends Parser {
  Document _html;
  SBIParser(String file) : super(file) {
    this._html = parse(file);
  }

  @override
  List<Statement> get statementsList {
    List<String> headers = [];

    for (var cell in this
        ._html
        .querySelector("#grdViewTradeDetail")
        .querySelectorAll("tr")
        .first
        .querySelectorAll("th")) {
      headers.add(cell.innerHtml);
    }
    log(headers.toString());
    List<Statement> statements = [];

    for (var row in this
        ._html
        .querySelector("#grdViewTradeDetail")
        .querySelectorAll("tr")
        .skip(1)) {
      String exchange, code, scripCode, scripName;
      int qty = 0;
      double rate = 0;

      int i = 0;
      for (var cell in row.querySelectorAll("td")) {
        switch (headers[i]) {
          case "Exch":
            exchange = cell.innerHtml;
            break;
          case "Scrip Code":
            scripCode = cell.innerHtml;
            break;
          case "Scrip Name":
            scripName =
                parse(parse(cell.innerHtml).body.text).documentElement.text;
            break;
          case "Buy Qty":
            qty += int.parse(cell.innerHtml);
            break;
          case "Sold Qty":
            qty += -int.parse(cell.innerHtml);
            break;
          case "Buy Rate":
            rate += double.parse(cell.innerHtml);
            break;
          case "Sold Rate":
            rate += double.parse(cell.innerHtml);
            break;
          default:
            break;
        }
        i++;
      }
      switch (exchange) {
        case "BSE":
          code = scripCode.substring(1).trim();
          break;
        case "NSE":
          code = scripName;
          break;
      }
      statements.add(Statement(code, exchange, qty, rate));
    }

    return statements;
  }
}
