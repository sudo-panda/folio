import 'package:flutter/material.dart';

import 'package:folio/models/database/scrip.dart';

import 'package:folio/helpers/database_actions.dart';

import 'import_scrips_list/parsed_scrips.dart';

class ScripTile extends StatefulWidget {
  final Scrip _scrip;
  final Function _refreshParent;

  ScripTile(Scrip scrip, {required void Function() refreshParent}) : this._scrip = scrip, this._refreshParent = refreshParent;

  @override
  State<ScripTile> createState() => _ScripTileState();
}

class _ScripTileState extends State<ScripTile> {
  bool _showOptions = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        borderOnForeground: false,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        elevation: 2,
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              color: Theme.of(context).cardColor,
              elevation: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showOptions = !_showOptions;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget._scrip.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "BSE",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "NSE",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          CodeWidget(code: widget._scrip.bseCode),
                          SizedBox(width: 10),
                          CodeWidget(code: widget._scrip.nseCode),
                        ],
                      ),
                      widget._scrip.oldBSECodes.length == 0 &&
                          widget._scrip.oldNSECodes.length == 0
                          ? SizedBox()
                          : Column(
                        children: [
                          Divider(
                            thickness: 1,
                          ),
                          Center(child: Text("OLD CODES")),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Wrap(
                                      spacing: 5,
                                      children: widget._scrip.oldBSECodes
                                          .map((code) =>
                                          CodeChip(code: code))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Wrap(
                                      spacing: 5,
                                      children: widget._scrip.oldNSECodes
                                          .map((code) =>
                                          CodeChip(code: code))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            _showOptions
                ? Row(
              children: [
                Expanded(
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blueAccent,
                      ),
                      onPressed: editScrip,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      onPressed: deleteScrip,
                    ),
                  ),
                )
              ],
            )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  editScrip() {}

  deleteScrip() async {
    String? result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(child: Text("WARNING")),
        content: Text(
          "Are you sure you want to delete ${widget._scrip.name}?",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size(88, 36),
              padding: EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, "Delete");
            },
            child: Text("Delete"),
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.background,
              minimumSize: Size(88, 36),
              padding: EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
            child: Text("Cancel"),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
    if (result == "Delete") {
      try {
        await DatabaseActions.deleteScrip(widget._scrip.stockID);
        widget._refreshParent();
      } catch (e) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Center(child: Text("Error")),
            content: Text(
              "Error Occurred: ${e.toString()}",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.justify,
            ),
            actions: [
              ElevatedButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.background,
                  minimumSize: Size(88, 36),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Ok"),
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        );
      }
    }
  }
}

class CodeWidget extends StatelessWidget {
  const CodeWidget({
    Key? key,
    required String? code,
  })  : _code = code,
        super(key: key);

  final String? _code;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Center(
        child: _code == null
            ? Text(
          "INACTIVE",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w100),
        )
            : CodeChip(code: _code!),
      ),
    );
  }
}