import 'package:flutter/material.dart';

import 'package:folio/assets/folio_icons.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/helpers/stock_repository.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/views/common/text_loading_indicator.dart';
import 'package:folio/views/tracked/details/details.dart';

class TrackedBottomSheet extends StatefulWidget {
  final Stock stock;
  const TrackedBottomSheet(this.stock);

  @override
  _TrackedBottomSheetState createState() => _TrackedBottomSheetState();
}

class _TrackedBottomSheetState extends State<TrackedBottomSheet> {
  late Stock _stock;
  bool _isRefreshing = true;

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _isRefreshing = _stock.lastValue == null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20.0),
          topRight: const Radius.circular(20.0),
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 10,
                width: 40,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ButtonBar(
              mainAxisSize: MainAxisSize.max,
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 27.0,
                  width: 50.0,
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: _isRefreshing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Icon(Icons.refresh),
                    disabledColor: Colors.grey,
                    iconSize: 25.0,
                    splashRadius: 25.0,
                    onPressed: _isRefreshing
                        ? null
                        : () {
                            setState(() {
                              _isRefreshing = true;
                            });

                            StockRepository.getOnceLatest(
                                    _stock.code, _stock.exchange)
                                .then((value) {
                              setState(() {
                                _stock.latest = value;
                                _isRefreshing = false;
                              });
                            });
                          },
                    tooltip: "Refresh",
                  ),
                ),
                SizedBox(
                  height: 27.0,
                  width: 50.0,
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon:
                        Icon(_stock.pinned ? Folio.unpin : Folio.pin),
                    iconSize: 25.0,
                    splashRadius: 25.0,
                    onPressed: () {
                      DatabaseActions.updatePinned(
                        _stock.code,
                        _stock.exchange,
                        !_stock.pinned,
                      ).then((value) {
                        if (value) {
                          setState(() {
                            _stock.pinned = !_stock.pinned;
                          });
                        }
                      });
                    },
                    tooltip: _stock.pinned ? "Unpin" : "Pin",
                  ),
                ),
                SizedBox(
                  height: 27.0,
                  width: 50.0,
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: _stock.isVisible
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                    iconSize: 25.0,
                    splashRadius: 25.0,
                    onPressed: () {
                      if (_stock.isVisible) {
                        DatabaseActions.deleteTracked(
                            _stock.code, _stock.exchange);
                      } else {
                        DatabaseActions.addTracked(
                          _stock.code,
                          _stock.exchange,
                          _stock.pinned,
                        );
                      }
                      setState(() {
                        _stock.isVisible = !_stock.isVisible;
                      });
                    },
                    tooltip: _stock.isVisible ? "Untrack" : "Retrack",
                  ),
                ),
                SizedBox(
                  height: 27.0,
                  width: 50.0,
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.table_view),
                    iconSize: 25.0,
                    splashRadius: 25.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return DetailsView(_stock);
                        }),
                      );
                    },
                    tooltip: "Details",
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 75,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  MapTile(
                    name: "PRICE",
                    value: _stock.lastValue?.toStringAsFixed(2) ?? "—",
                  ),
                  MapTile(
                    name: "QTY",
                    value: _stock.qty?.toString() ?? "—",
                  ),
                  MapTile(
                    name: "ESR",
                    value: _stock.esr?.toStringAsFixed(2) ?? "—",
                  ),
                  MapTile(
                    name: "MSR",
                    value: _stock.msr?.toStringAsFixed(2) ?? "—",
                  ),
                  MapTile(
                    name: "NET",
                    value: _stock.netAmount?.toStringAsFixed(2) ?? "—",
                  ),
                  MapTile(
                    name: "NET/STK",
                    value: _stock.netPerStock?.toStringAsFixed(2) ?? "—",
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stock.name == null
                    ? TextLoadingIndicator(
                        width: 200,
                        height: Theme.of(context).textTheme.titleLarge!.fontSize!)
                    : Flexible(
                        child: Text(
                          _stock.name!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                        _stock.exchange + "-" + _stock.code,
                        style: Theme.of(context).textTheme.bodyLarge,
                ),
                _stock.lastUpdated == null
                    ? TextLoadingIndicator(
                        width: 150,
                        height: Theme.of(context).textTheme.bodyLarge!.fontSize!)
                    : Text(
                        _stock.lastUpdated!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapTile extends StatelessWidget {
  const MapTile({
    required String name,
    required String value,
  })  : _name = name,
        _value = value;

  final String _name;
  final String _value;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 110),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.background),
              ),
              Text(
                _name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground),
              )
            ],
          ),
        ),
      ),
    );
  }
}
