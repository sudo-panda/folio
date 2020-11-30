import 'package:flutter/material.dart';
import 'package:folio/helpers/database_actions.dart';

class AddPortfolioDialog extends StatefulWidget {
  @override
  _AddPortfolioDialogState createState() => _AddPortfolioDialogState();
}

class _AddPortfolioDialogState extends State<AddPortfolioDialog> {
  TextEditingController _nseCodeCtl;
  TextEditingController _bseCodeCtl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nseCodeCtl = TextEditingController();
    _bseCodeCtl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nseCodeCtl.dispose();
    _bseCodeCtl.dispose();
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
                  "Codes",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "NSE Code",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    helperText: "NSE Code",
                  ),
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.text,
                  controller: _nseCodeCtl,
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
                    labelText: "BSE Code",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    helperText: "BSE Code",
                  ),
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.text,
                  controller: _bseCodeCtl,
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
                          DatabaseActions.linkCodes({
                            'NSE': _nseCodeCtl.text,
                            'BSE': _bseCodeCtl.text,
                          });
                          Navigator.pop(context);
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
