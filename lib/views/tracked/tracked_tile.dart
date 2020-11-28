import 'dart:async';

import 'package:flutter/material.dart';
import 'package:folio/helpers/stock_repository.dart';
import 'package:folio/models/stock/latest.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/views/common/text_loading_indicator.dart';
import 'package:folio/views/tracked/tracked_bottom_sheet.dart';

class TrackedTile extends StatefulWidget {
  final Stock stock;

  TrackedTile(this.stock);

  @override
  _TrackedTileState createState() => _TrackedTileState();
}

class _TrackedTileState extends State<TrackedTile> {
  Stock _stock;
  StreamSubscription<Latest> _latestStreamSub;
  GlobalKey _scaffold = GlobalKey();

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _latestStreamSub =
        StockRepository.getPeriodicLatest(_stock.code, _stock.exchange)
            .listen((value) {
      setState(() {
        _stock.latest = value;
      });
    });
    if (_stock.name == null) {
      StockRepository.getName(_stock.code, _stock.exchange).then((value) {
        setState(() {
          _stock.name = value;
        });
      });
    }
  }

  @override
  void dispose() {
    _latestStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: _scaffold,
      color: Theme.of(context).backgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: InkWell(
        onTap: _modalBottomSheetMenu,
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 20,
                decoration: BoxDecoration(
                  color: (_stock?.lastValue ?? double.negativeInfinity) >
                          (_stock?.msr ?? double.infinity)
                      ? Colors.lightGreen[600]
                      : (_stock?.lastValue ?? double.infinity) <
                              (_stock?.msr ?? double.negativeInfinity)
                          ? Colors.redAccent
                          : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: (_stock?.lastValue ?? 0) > (_stock?.esr ?? 0)
                      ? Colors.lightGreen[600]
                      : Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stock == null
                            ? TextLoadingIndicator(
                                width: 100,
                                height: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .fontSize)
                            : Text(
                                (_stock?.exchange ?? "") +
                                    " - " +
                                    (_stock?.code ?? ""),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        _stock?.name == null
                            ? TextLoadingIndicator(
                                width: 200,
                                height: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .fontSize)
                            : Text(
                                (_stock?.name == "NULL" ? "-" : _stock?.name),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryVariant,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _stock?.lastValue == null
                            ? TextLoadingIndicator(
                                width: 70,
                                height: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .fontSize +
                                    5,
                              )
                            : Text(
                                _stock?.lastValue?.toStringAsFixed(2) ?? "",
                                style: Theme.of(context).textTheme.headline4,
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.end,
                          children: <Widget>[
                            _stock?.percentChange == null
                                ? TextLoadingIndicator(
                                    width: 30,
                                    height: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .fontSize,
                                  )
                                : Text(
                                    "${_stock?.percentChange}%",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                            SizedBox(width: 10),
                            _stock?.change == null
                                ? TextLoadingIndicator(
                                    width: 40,
                                    height: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .fontSize,
                                  )
                                : Text(
                                    _stock?.change,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          color: _stock?.changeSign == 1
                                              ? Colors.green
                                              : (_stock?.changeSign == -1
                                                  ? Colors.red
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                        ),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: _scaffold.currentContext,
        builder: (builder) {
          return TrackedBottomSheet(_stock);
        });
  }
}
