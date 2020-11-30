import 'package:flutter/material.dart';

import 'package:folio/helpers/database_actions.dart';

class TrackStockDialog extends StatefulWidget {
  @override
  _TrackStockDialogState createState() => _TrackStockDialogState();
}

class _TrackStockDialogState extends State<TrackStockDialog> {
  TextEditingController _codeCtl;
  var _exchanges = ["BSE", "NSE"];
  String _selectedExch = 'BSE';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _codeCtl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _codeCtl?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).backgroundColor,
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
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Add stock to tracker",
                  style: Theme.of(context).textTheme.headline6,
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
                child: Row(
                  children: [
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Text("Add"),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          DatabaseActions.addTracked(
                                  _codeCtl.text, _selectedExch, null, false)
                              .then(
                            (value) {
                              if (value) {
                                Navigator.pop(context);
                              }
                              return value;
                            },
                          );
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
    );
  }
}
