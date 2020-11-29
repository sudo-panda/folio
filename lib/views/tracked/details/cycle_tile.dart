import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:folio/models/trade/cycle.dart';

class CycleTile extends StatelessWidget {
  final TradeCycle cycle;
  final DateFormat dateFormatter = DateFormat('dd MMM y');

  CycleTile(
    this.cycle,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      color: Theme.of(context).backgroundColor,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "SOLD ON: ",
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  dateFormatter.format(cycle.date),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "SELL",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    "",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    "BUY",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    "",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    "CHARGE",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            cycle.sellQty.toString(),
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            " x",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                      Text(
                        cycle.sellRate.toStringAsFixed(2),
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    "—",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.from(
                      cycle.invoices.map(
                        (element) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  element.qty.toString(),
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                Text(
                                  " x",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            Text(element.rate.toStringAsFixed(2),
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodyText1)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    "—",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    cycle.brokerage.toStringAsFixed(2),
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(""),
                ),
                Text(
                  "Net:",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: cycle.net > 0
                              ? Colors.lightGreen
                              : cycle.net < 0
                                  ? Colors.redAccent
                                  : Colors.transparent,
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Text(
                          cycle.net.abs().toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
