import 'package:flutter/material.dart';
import 'package:folio/assets/folio_icons.dart';
import 'package:folio/helpers/stock_repository.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/views/common/text_loading_indicator.dart';
import 'package:folio/views/tracked/database_actions.dart';
import 'package:folio/views/tracked/details/details.dart';

class TrackedBottomSheet extends StatefulWidget {
  final Stock stock;
  const TrackedBottomSheet(this.stock);

  @override
  _TrackedBottomSheetState createState() => _TrackedBottomSheetState();
}

class _TrackedBottomSheetState extends State<TrackedBottomSheet> {
  Stock _stock;
  bool _isRefreshing = true;
  bool _isTracked = true;

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _isRefreshing = _stock?.lastValue == null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
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
                        Icon(_stock?.pinned ?? false ? Folio.unpin : Folio.pin),
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
                    tooltip: _stock?.pinned ?? false ? "Unpin" : "Pin",
                  ),
                ),
                SizedBox(
                  height: 27.0,
                  width: 50.0,
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: _isTracked
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                    iconSize: 25.0,
                    splashRadius: 25.0,
                    onPressed: () {
                      if (_isTracked) {
                        DatabaseActions.deleteTracked(
                            _stock.code, _stock.exchange);
                      } else {
                        DatabaseActions.addTracked(
                          _stock.code,
                          _stock.exchange,
                          _stock.name,
                          _stock.pinned,
                        );
                      }
                      setState(() {
                        _isTracked = !_isTracked;
                      });
                    },
                    tooltip: _isTracked ? "Untrack" : "Retrack",
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
                    tooltip: _isTracked ? "Untrack" : "Retrack",
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
                    value: _stock?.lastValue?.toStringAsFixed(2) ?? "N/A",
                  ),
                  MapTile(
                    name: "QTY",
                    value: _stock?.qty?.toString() ?? "N/A",
                  ),
                  MapTile(
                    name: "ESR",
                    value: _stock?.esr?.toStringAsFixed(2) ?? "N/A",
                  ),
                  MapTile(
                    name: "MSR",
                    value: _stock?.msr?.toStringAsFixed(2) ?? "N/A",
                  ),
                  MapTile(
                    name: "NET",
                    value: _stock?.netPerStock?.toStringAsFixed(2) ?? "N/A",
                  ),
                  MapTile(
                    name: "NET/STK",
                    value: _stock?.netPerStock?.toStringAsFixed(2) ?? "N/A",
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
                _stock?.name == null
                    ? TextLoadingIndicator(
                        width: 200,
                        height: Theme.of(context).textTheme.headline6.fontSize)
                    : Flexible(
                        child: Text(
                          _stock?.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
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
                _stock?.exchange == null || _stock?.code == null
                    ? TextLoadingIndicator(
                        width: 100,
                        height: Theme.of(context).textTheme.bodyText1.fontSize)
                    : Text(
                        (_stock?.exchange ?? "") + "-" + (_stock.code ?? ""),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                _stock?.lastUpdated == null
                    ? TextLoadingIndicator(
                        width: 150,
                        height: Theme.of(context).textTheme.bodyText1.fontSize)
                    : Text(
                        _stock?.lastUpdated,
                        style: Theme.of(context).textTheme.bodyText1,
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
    Key key,
    @required String name,
    @required String value,
  })  : _name = name,
        _value = value,
        super(key: key);

  final String _name;
  final String _value;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryVariant,
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
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                _name,
                style: Theme.of(context).textTheme.bodyText1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
