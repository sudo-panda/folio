import 'dart:developer';

import 'package:folio/services/parser/parser.dart';
import 'package:folio/models/trades/trade_log.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class SBIParser extends Parser {
  Document _html;
  SBIParser(String file) : super(file) {
    this._html = parse(file);
  }

  @override
  List<TradeLog> get statementsList {
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
    List<TradeLog> statements = [];

    for (var row in this
        ._html
        .querySelector("#grdViewTradeDetail")
        .querySelectorAll("tr")
        .skip(1)) {
      DateTime dateTime;
      String exchange, code, scripCode, scripName;
      int buyQty = 0, sellQty = 0;
      double buyRate = 0, sellRate = 0;

      int i = 0;
      for (var cell in row.querySelectorAll("td")) {
        switch (headers[i]) {
          case "Date":
            dateTime = DateTime.utc(
                int.parse(cell.innerHtml
                    .substring(cell.innerHtml.lastIndexOf('/') + 1)),
                int.parse(cell.innerHtml.substring(
                    cell.innerHtml.indexOf('/') + 1,
                    cell.innerHtml.lastIndexOf('/'))),
                int.parse(
                    cell.innerHtml.substring(0, cell.innerHtml.indexOf('/'))));
            break;
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
            buyQty = int.parse(cell.innerHtml);
            break;
          case "Sold Qty":
            sellQty = int.parse(cell.innerHtml);
            break;
          case "Buy Rate":
            buyRate = double.parse(cell.innerHtml);
            break;
          case "Sold Rate":
            sellRate = double.parse(cell.innerHtml);
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
      if (buyQty > 0)
        statements.add(TradeLog(dateTime, code, exchange, true, buyQty, buyRate));

      if (sellQty > 0)
        statements.add(TradeLog(dateTime, code, exchange, false, sellQty, sellRate));
    }

    return statements;
  }
}
