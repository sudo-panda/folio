import 'package:flutter/material.dart';

class ParsedScrip {
  String name;
  String? newCode;
  List<String> oldCodes;

  ParsedScrip(this.name, this.newCode, [List<String>? oldCodes])
      : oldCodes = oldCodes ?? [];

  ParsedScrip.from(ParsedScrip scrip)
      : name = scrip.name, newCode = scrip.newCode, oldCodes = [] {
    for (var oldCode in scrip.oldCodes){
      oldCodes.add(oldCode);
    }
  }
}

class ParsedScripsList {
  final String exchange;
  List<ParsedScrip> newScrips = [];

  ParsedScripsList(this.exchange);

  Future<void> addNew(ParsedScrip scrip) async {
    newScrips.add(scrip);
  }
}

class ParsedScripTile extends StatelessWidget {
  final ParsedScrip _scrip;

  ParsedScripTile(this._scrip);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(child: Text("Name ")),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(child: Text("Code ")),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        _scrip.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _scrip.newCode == null
                          ? Text("INACTIVE",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w100),)
                          : CodeChip(
                              code: _scrip.newCode!,
                            ),
                    ),
                  ),
                ],
              ),
              _scrip.oldCodes.length == 0
                  ? SizedBox()
                  : Column(
                    children: [
                      Divider(thickness: 2,),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 5, right: 8.0, bottom: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(_scrip.newCode == null ? "Old Codes: " : "Replaces: "),
                              Expanded(
                                child: Wrap(
                                  spacing: 5,
                                  alignment: WrapAlignment.end,
                                  children: _scrip.oldCodes
                                      .map((code) => CodeChip(code: code))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
            ],
          ),
        ),
      ),
    );
  }
}

class CodeChip extends StatelessWidget {
  const CodeChip({
    required String code,
  }) : _code = code;

  final String _code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          _code,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).cardColor),
        ),
      ),
    );
  }
}
