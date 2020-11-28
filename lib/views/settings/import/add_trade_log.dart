import 'package:flutter/material.dart';
import 'package:folio/views/settings/import/database_actions.dart';

class AddTradeLogRoute extends StatefulWidget {
  @override
  _AddTradeLogRouteState createState() => _AddTradeLogRouteState();
}

class _AddTradeLogRouteState extends State<AddTradeLogRoute> {
  TextEditingController _dateCtl;
  TextEditingController _codeCtl;
  TextEditingController _rateCtl;
  TextEditingController _qtyCtl;
  final _formKey = GlobalKey<FormState>();

  List<bool> _isSelected;
  var _exchanges = ["BSE", "NSE"];
  String _selectedExch = 'BSE';

  @override
  void initState() {
    super.initState();
    _dateCtl = TextEditingController();
    _codeCtl = TextEditingController();
    _rateCtl = TextEditingController();
    _qtyCtl = TextEditingController();
    _isSelected = [true, false];
  }

  @override
  void dispose() {
    super.dispose();
    _dateCtl.dispose();
    _codeCtl.dispose();
    _rateCtl.dispose();
    _qtyCtl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Trade Log"),
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          var res = await DatabaseActions.setTradeLog(
                            _codeCtl.text.trim(),
                            _selectedExch,
                            _dateCtl.text.trim(),
                            _isSelected[0],
                            int.parse(_qtyCtl.text.trim()),
                            double.parse(
                              _rateCtl.text.trim(),
                            ),
                          );
                          if (res) {
                            Navigator.pop(context);
                          } else {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Couldn't add!"),
                                  actions: [
                                    FlatButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.center,
                child: ToggleButtons(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 100),
                      child: Text(
                        "BUY",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              color: _isSelected[0]
                                  ? Theme.of(context).backgroundColor
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 100),
                      child: Text(
                        "SELL",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              color: _isSelected[1]
                                  ? Theme.of(context).backgroundColor
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < _isSelected.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          _isSelected[buttonIndex] = true;
                        } else {
                          _isSelected[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  isSelected: _isSelected,
                  selectedColor: _isSelected[0] ? Colors.lightGreen[600] : Colors.redAccent,
                  fillColor: _isSelected[0] ? Colors.lightGreen[600] : Colors.redAccent,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Code",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    helperText: "Code",
                  ),
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.text,
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
                padding: const EdgeInsets.all(8.0),
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelStyle: Theme.of(context).textTheme.bodyText2,
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16.0,
                        ),
                        helperText: 'Exchange',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      isEmpty: false,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          style: Theme.of(context).textTheme.bodyText2,
                          dropdownColor: Theme.of(context).backgroundColor,
                          value: _selectedExch,
                          isDense: true,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedExch = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: _exchanges.map(
                            (value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
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
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Date",
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    helperText: "Date",
                  ),
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.datetime,
                  onTap: () async {
                    DateTime date = DateTime(1900);
                    FocusScope.of(context).requestFocus(new FocusNode());

                    date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );

                    _dateCtl.text = date?.toIso8601String()?.substring(0, 10);
                  },
                  controller: _dateCtl,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    helperText: "Quantity",
                  ),
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.number,
                  controller: _qtyCtl,
                  validator: (value) {
                    if (value.trim() == "") {
                      return "Required";
                    }
                    if (RegExp(r"^[0-9]*?$").hasMatch(value.trim())) {
                      return null;
                    }
                    return "Enter valid rate";
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Rate",
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    helperText: "Rate",
                  ),
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value.trim() == "") {
                      return "Required";
                    }
                    if (RegExp(r"^[0-9]*(\.[0-9][0-9]?)?$")
                        .hasMatch(value.trim())) {
                      return null;
                    }
                    return "Enter valid rate";
                  },
                  controller: _rateCtl,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
