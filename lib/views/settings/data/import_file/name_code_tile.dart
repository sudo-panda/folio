import 'package:flutter/material.dart';
import 'package:folio/views/settings/data/import_file/get_missing_codes.dart';

class NameCodeTile extends StatefulWidget {
  final int index;
  final NameCode nameCode;
  final void Function(int, String?, String?) updateCode;

  NameCodeTile({
    required this.index,
    required this.nameCode,
    required this.updateCode,
  });

  @override
  State<StatefulWidget> createState() => _NameCodeTileState();
}

class _NameCodeTileState extends State<NameCodeTile>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _bseCodeCtl;
  late TextEditingController _nseCodeCtl;
  final _formKey = GlobalKey<FormState>();
  String? bseCode, nseCode;

  @override
  void initState() {
    super.initState();
    bseCode = widget.nameCode.bseCode;
    nseCode = widget.nameCode.nseCode;
    _bseCodeCtl = TextEditingController(text: bseCode);
    _nseCodeCtl = TextEditingController(text: nseCode);
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Center(
                    child: Text(
                      widget.nameCode.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
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
                                color: widget.nameCode.isNSECodeRequired
                                    ? Colors.red
                                    : Colors.grey,
                                width: widget.nameCode.isNSECodeRequired ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.nameCode.isNSECodeRequired
                                    ? Colors.red
                                    : Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          enabled: widget.nameCode.nseCode == null,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: Theme.of(context).textTheme.bodyLarge,
                          keyboardType: TextInputType.text,
                          controller: _nseCodeCtl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              if (widget.nameCode.isNSECodeRequired) return 'Required';
                              return null;
                            }
                            nseCode = value;
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
                                color: widget.nameCode.isBSECodeRequired
                                    ? Colors.red
                                    : Colors.grey,
                                width: widget.nameCode.isBSECodeRequired ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.nameCode.isBSECodeRequired
                                    ? Colors.red
                                    : Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          enabled: widget.nameCode.bseCode == null,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: Theme.of(context).textTheme.bodyLarge,
                          keyboardType: TextInputType.text,
                          controller: _bseCodeCtl,
                          validator: (value) {
                            if ((value == null || value.isEmpty) &&
                                widget.nameCode.isBSECodeRequired) {
                              return 'Required';
                            }
                            bseCode = value;
                            updateLog();
                            return null;
                          },
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
    widget.updateCode(widget.index, bseCode, nseCode);
  }

  @override
  bool get wantKeepAlive => true;
}
