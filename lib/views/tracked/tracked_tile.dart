import 'dart:async';

import 'package:flutter/material.dart';
import 'package:folio/helpers/stock_repository.dart';
import 'package:folio/models/stock/latest.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/views/common/text_loading_indicator.dart';
import 'package:folio/views/tracked/tracked_bottom_sheet.dart';

import '../../assets/app_theme.dart';

class TrackedTile extends StatefulWidget {
  final Stock stock;

  TrackedTile(this.stock);

  @override
  _TrackedTileState createState() => _TrackedTileState();
}

class _TrackedTileState extends State<TrackedTile> {
  late Stock _stock;
  late StreamSubscription<Latest?> _latestStreamSub;
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
    if (_stock.name == null || _stock.name == "") {
      StockRepository.getName(_stock.code, _stock.exchange).then((value) {
        if (this.mounted && value != null) {
          setState(() {
            _stock.name = value;
          });
        }
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
    final MyColors myColors = Theme.of(context).extension<MyColors>()!;
    bool hasReachedESR = (_stock?.lastValue ?? double.negativeInfinity) >
        (_stock?.esr ?? double.infinity);
    bool hasReachedMSR = (_stock?.lastValue ?? double.negativeInfinity) >
        (_stock?.msr ?? double.infinity);
    bool isLessThanMSR = (_stock?.lastValue ?? double.infinity) <
        (_stock?.msr ?? double.negativeInfinity);
    return Card(
      key: _scaffold,
      color: hasReachedESR
          ? myColors.positiveColor
          : Theme.of(context).colorScheme.background,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
                  color: hasReachedMSR
                      ? myColors.positiveColor
                      : isLessThanMSR
                          ? myColors.negativeColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
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
                                height: (Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.fontSize)!,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onBackground,
                              )
                            : Text(
                                (_stock.exchange ?? "") +
                                    " - " +
                                    (_stock.code ?? ""),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        _stock.name == null
                            ? TextLoadingIndicator(
                                width: 200,
                                height: (Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.fontSize)!,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onBackground,
                              )
                            : Text(
                                (_stock.name == "NULL"
                                    ? "-"
                                    : _stock.name ?? "-"),
                                style: Theme.of(context).textTheme.titleLarge,
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
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
                                        .headlineMedium!
                                        .fontSize! +
                                    5,
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              )
                            : Text(
                                _stock?.lastValue?.toStringAsFixed(2) ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background),
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
                                    height: (Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize)!,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                                : Text(
                                    "${_stock?.percentChange}%",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background),
                                  ),
                            SizedBox(width: 10),
                            _stock.change == null
                                ? TextLoadingIndicator(
                                    width: 40,
                                    height: (Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize)!,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                                : Text(
                                    _stock.change!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: _stock.changeSign == 1
                                              ? myColors.positiveColor
                                              : (_stock.changeSign == -1
                                                  ? myColors.negativeColor
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
        context: (_scaffold.currentContext)!,
        builder: (builder) {
          return TrackedBottomSheet(_stock);
        });
  }
}
