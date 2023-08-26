import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:folio/models/database/trade_log.dart';

import '../../assets/app_theme.dart';

class LogTile extends StatelessWidget {
  final TradeLog _tradeLog;
  final DateFormat _dateFormatter = DateFormat('dd MMM y');

  LogTile(this._tradeLog);

  @override
  Widget build(BuildContext context) {
    final MyColors myColors = Theme.of(context).extension<MyColors>()!;
    return Card(
      color: Theme.of(context).colorScheme.background,
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
              child: _tradeLog.bought == null
                  ? Icon(Icons.circle_outlined)
                  : _tradeLog.bought
                  ? Icon(Icons.add_circle, color: myColors.positiveColor,)
                  : Icon(Icons.add_circle, color: myColors.negativeColor,),
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
                          (_tradeLog.exchange ?? "-"),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          _tradeLog.date == null
                              ? "-"
                              : _dateFormatter.format(_tradeLog.date),
                          style: Theme.of(context).textTheme.bodyLarge,
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
                            (_tradeLog.code ?? "-"),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.normal),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _tradeLog.qty.toString() ?? "-",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _tradeLog.rate.toStringAsFixed(2) ?? "-",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
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
