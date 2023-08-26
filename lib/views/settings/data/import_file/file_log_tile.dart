import 'package:flutter/material.dart';
import 'package:folio/models/trade/parsed_file_logs.dart';

class FileLogTile extends StatefulWidget {
  final FileLog _log;
  final int index;
  final Function(int, FileLog)? updateLog;
  final bool isLogValid;

  FileLogTile(this._log,
      {this.index = -1, this.updateLog, this.isLogValid = false});

  @override
  State<StatefulWidget> createState() => _InvalidFileLogTile();
}

class _InvalidFileLogTile extends State<FileLogTile>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _dateCtl;
  late TextEditingController _bseCodeCtl;
  late TextEditingController _nseCodeCtl;
  late TextEditingController _rateCtl;
  late TextEditingController _qtyCtl;
  final _formKey = GlobalKey<FormState>();
  late FileLog correctedLog;

  final _exchanges = ["BSE", "NSE"];
  final _buyStates = ["BUY", "SELL"];

  @override
  void initState() {
    super.initState();
    correctedLog = widget._log;
    _dateCtl = TextEditingController(
        text: correctedLog.date?.toIso8601String().substring(0, 10));
    _bseCodeCtl = TextEditingController(text: correctedLog.bseCode);
    _nseCodeCtl = TextEditingController(text: correctedLog.nseCode);
    _rateCtl =
        TextEditingController(text: correctedLog.rate?.toStringAsFixed(2));
    _qtyCtl = TextEditingController(text: correctedLog.qty?.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget._log.name == null && widget.isLogValid
                    ? SizedBox(height: 15)
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        child: Center(
                          child: Text(
                            widget._log.name ?? "UNKNOWN",
                            textAlign: TextAlign.center,
                            style: widget._log.name == null
                                ? Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w200,
                                        fontStyle: FontStyle.italic)
                                : Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Date",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          enabled:
                              widget._log.date == null && !widget.isLogValid,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: Theme.of(context).textTheme.bodyLarge,
                          keyboardType: TextInputType.datetime,
                          onTap: () async {
                            DateTime? date = DateTime(1900);
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());

                            date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );

                            if (date != null) {
                              _dateCtl.text =
                                  date.toIso8601String().substring(0, 10);
                              correctedLog.date = date;
                              updateLog();
                            }
                          },
                          controller: _dateCtl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: widget._log.exchange == null
                                  ? BorderSide(color: Colors.red, width: 2)
                                  : BorderSide(
                                      color: Colors.transparent, width: 2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                                disabledColor: Theme.of(context).primaryColor),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                elevation: 2,
                                dropdownColor:
                                    Theme.of(context).colorScheme.background,
                                iconDisabledColor: Colors.transparent,
                                isDense: true,
                                value: correctedLog.exchange,
                                onChanged: widget._log.exchange == null &&
                                        !widget.isLogValid
                                    ? (newValue) {
                                        setState(() {
                                          correctedLog.exchange = newValue;
                                        });
                                      }
                                    : null,
                                hint: Text("Exch"),
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
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: widget._log.bought == null
                                  ? BorderSide(color: Colors.red, width: 2)
                                  : BorderSide(
                                      color: Colors.transparent, width: 2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                                disabledColor: Theme.of(context).primaryColor),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                elevation: 2,
                                dropdownColor:
                                    Theme.of(context).colorScheme.background,
                                iconDisabledColor: Colors.transparent,
                                isDense: true,
                                value: correctedLog.bought == null
                                    ? null
                                    : correctedLog.bought!
                                        ? _buyStates.first
                                        : _buyStates.last,
                                onChanged: widget._log.bought == null &&
                                        !widget.isLogValid
                                    ? (newValue) {
                                        setState(() {
                                          correctedLog.bought =
                                              newValue == _buyStates.first;
                                        });
                                      }
                                    : null,
                                hint: Text("Type"),
                                items: _buyStates.map(
                                  (value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "NSE Code",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: correctedLog.isNSECodeRequired
                                    ? Colors.red
                                    : Colors.grey,
                                width: correctedLog.isNSECodeRequired ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: correctedLog.isNSECodeRequired
                                    ? Colors.red
                                    : Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          enabled:
                              widget._log.nseCode == null && !widget.isLogValid,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: Theme.of(context).textTheme.bodyLarge,
                          keyboardType: TextInputType.text,
                          controller: _nseCodeCtl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              if (correctedLog.isNSECodeRequired)
                                return 'Required';
                              return null;
                            }
                            correctedLog.nseCode = value;
                            updateLog();
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "BSE Code",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 0,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: correctedLog.isBSECodeRequired
                                    ? Colors.red
                                    : Colors.grey,
                                width: correctedLog.isBSECodeRequired ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: correctedLog.isBSECodeRequired
                                    ? Colors.red
                                    : Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          enabled:
                              widget._log.bseCode == null && !widget.isLogValid,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: Theme.of(context).textTheme.bodyLarge,
                          keyboardType: TextInputType.text,
                          controller: _bseCodeCtl,
                          validator: (value) {
                            if ((value == null || value.isEmpty) &&
                                correctedLog.isBSECodeRequired) {
                              return 'Required';
                            }
                            correctedLog.bseCode = value;
                            updateLog();
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: "Quantity",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              )),
                          enabled:
                              widget._log.date == null && !widget.isLogValid,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: Theme.of(context).textTheme.bodyLarge,
                          keyboardType: TextInputType.number,
                          controller: _qtyCtl,
                          validator: (value) {
                            if (value == null || value.trim() == "") {
                              return "Required!";
                            }
                            if (RegExp(r"^[0-9]*?$").hasMatch(value.trim())) {
                              correctedLog.qty = int.parse(value.trim());
                              updateLog();
                              return null;
                            }
                            return "Invalid!";
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: "Rate",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              )),
                          enabled:
                              widget._log.date == null && !widget.isLogValid,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: Theme.of(context).textTheme.bodyLarge,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim() == "") {
                              return "Required!";
                            }
                            if (RegExp(r"^[0-9]*(\.[0-9][0-9]?)?$")
                                .hasMatch(value.trim())) {
                              correctedLog.rate = double.parse(value.trim());
                              updateLog();
                              return null;
                            }
                            return "Invalid!";
                          },
                          controller: _rateCtl,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateLog() {
    if (widget.updateLog != null) widget.updateLog!(widget.index, correctedLog);
  }

  @override
  bool get wantKeepAlive => true;
}
