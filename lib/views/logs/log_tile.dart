import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:folio/models/database/trade_log.dart';

class LogTile extends StatelessWidget {
  final TradeLog _tradeLog;
  final DateFormat _dateFormatter = DateFormat('dd MMM y');

  LogTile(this._tradeLog);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).backgroundColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          topLeft: Radius.circular(50),
          bottomRight: Radius.circular(10),
          topRight: Radius.circular(10)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: _tradeLog?.bought == null
                    ? Colors.transparent
                    : _tradeLog.bought
                        ? Colors.lightGreen[600]
                        : Colors.redAccent,
                
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (_tradeLog?.exchange ?? "-"),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Text(
                          _tradeLog?.date == null
                              ? "-"
                              : _dateFormatter.format(_tradeLog.date),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            (_tradeLog?.code ?? "-"),
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.normal),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _tradeLog?.qty?.toString() ?? "-",
                            style: Theme.of(context)
                                .textTheme
                                .headline6,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _tradeLog?.rate?.toStringAsFixed(2) ?? "-",
                            style: Theme.of(context)
                                .textTheme
                                .headline6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
