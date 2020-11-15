import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:folio/models/trades/trade_log.dart';
import 'package:intl/intl.dart';

class TradeTable extends StatelessWidget {
  final List<TradeLog> _statementsList;
  final DateFormat dayMonth = DateFormat('dd MMM');

  TradeTable(List<TradeLog> list) : _statementsList = list;

  @override
  Widget build(BuildContext context) {
    List<TableRow> tradeRows = [];
    _statementsList.forEach((ele) {
      tradeRows.add(tradeRow(ele));
    });
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: InteractiveViewer(
          child: Table(
            border: TableBorder.all(color: Theme.of(context).dividerColor),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {0: FixedColumnWidth(70), 1: FlexColumnWidth()},
            children: tradeRows,
          ),
        ),
      ),
    );
  }

  TableRow tradeRow(TradeLog log) {
    return TableRow(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(dayMonth.format(log.date)),
            Text(log.date.year.toString())
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  log.code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w100,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  log.exchange,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  log.qty.toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: log.bought ? Colors.green : Colors.red,
                  ),
                ),
              ),
              Text(
                "    @    ",
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontSize: 10,
                ),
              ),
              Text(
                log.rate.toStringAsFixed(2),
                style: TextStyle(
                  color: log.bought ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
