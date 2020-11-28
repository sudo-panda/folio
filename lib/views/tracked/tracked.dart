import 'package:flutter/material.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/views/common/bottom_navbar.dart';
import 'package:folio/views/common/drawer.dart';
import 'package:folio/views/tracked/database_actions.dart';
import 'package:folio/views/tracked/tracked_list.dart';

class TrackedView extends StatefulWidget {
  @override
  _TrackedViewState createState() => _TrackedViewState();
}

class _TrackedViewState extends State<TrackedView> {
  Future<List<Stock>> _pinnedStockFuture;
  Future<List<Stock>> _unpinnedStockFuture;

  TextEditingController _codeCtl;
  var _exchanges = ["BSE", "NSE"];
  String _selectedExch = 'BSE';
  final _formKey = GlobalKey<FormState>();

  Future<bool> hasData() async {
    if (((await _pinnedStockFuture)?.length ?? 0) == 0 &&
        ((await _unpinnedStockFuture)?.length ?? 0) == 0) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    _pinnedStockFuture = DatabaseActions.getPinnedStocks();
    _unpinnedStockFuture = DatabaseActions.getUnpinnedStocks();
    _codeCtl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _codeCtl?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: new Icon(Icons.clear_all_outlined),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: FolioDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Tracked",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      RaisedButton(
                        shape: CircleBorder(),
                        child: Icon(Icons.add),
                        color: Theme.of(context).accentColor,
                        textColor: Theme.of(context).backgroundColor,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "Add stock to tracker",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  labelText: "Code",
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                  ),
                                                  helperText: "Code",
                                                ),
                                                cursorColor: Theme.of(context)
                                                    .accentColor,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                                keyboardType:
                                                    TextInputType.text,
                                                controller: _codeCtl,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: FormField<String>(
                                                builder: (FormFieldState<String>
                                                    state) {
                                                  return InputDecorator(
                                                    decoration: InputDecoration(
                                                      labelStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyText2,
                                                      errorStyle: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontSize: 16.0,
                                                      ),
                                                      helperText: 'Exchange',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                    ),
                                                    isEmpty: false,
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                          String>(
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2,
                                                        dropdownColor: Theme.of(
                                                                context)
                                                            .backgroundColor,
                                                        value: _selectedExch,
                                                        isDense: true,
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            _selectedExch =
                                                                newValue;
                                                            state.didChange(
                                                                newValue);
                                                          });
                                                        },
                                                        items: _exchanges.map(
                                                          (value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child:
                                                                  Text(value),
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  FlatButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                    child: Text("Cancel"),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  Spacer(),
                                                  FlatButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                    child: Text("Add"),
                                                    onPressed: () {
                                                      if (_formKey.currentState
                                                          .validate()) {
                                                        DatabaseActions
                                                                .addTracked(
                                                                    _codeCtl
                                                                        .text,
                                                                    _selectedExch,
                                                                    null,
                                                                    false)
                                                            .then((value) {
                                                          if (value) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                          return value;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          TrackedList(
            future: _pinnedStockFuture,
          ),
          FutureBuilder(
            future: hasData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    ),
                  ),
                );
              } else if (!snapshot.data) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No stocks tracked",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                );
              } else {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(
                      height: 20,
                    )
                  ]),
                );
              }
            },
          ),
          TrackedList(
            future: _unpinnedStockFuture,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(0),
    );
  }
}
