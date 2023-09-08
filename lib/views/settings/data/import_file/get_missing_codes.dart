import 'package:flutter/material.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/models/trade/parsed_file_logs.dart';
import 'package:folio/views/settings/data/import_file/correct_invalid_logs.dart';
import 'package:folio/views/settings/data/import_file/name_code_tile.dart';

import 'package:folio/services/database/database.dart';
import 'package:folio/views/settings/data/import_file/show_valid_logs.dart';

class GetMissingCodes extends StatefulWidget {
  final ParsedFileLogs _logs;

  GetMissingCodes(this._logs);

  @override
  _GetMissingCodesState createState() => _GetMissingCodesState();
}

class _GetMissingCodesState extends State<GetMissingCodes> {
  late List<NameCode> correctedCodes;
  late Map<String, int> nameIndexMap;
  late Future<List<NameCode>> codesFuture;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    correctedCodes = [];
    nameIndexMap = {};
    codesFuture = getStocksWithInvalidCodes(widget._logs.invalidLogs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Correct Missing Fields"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                correctedCodes.length == 0 ? Icons.arrow_forward : Icons.check),
            onPressed: isLoading
                ? null
                : () async {
                    await nextPage(context);
                  },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          FutureBuilder(
            future: codesFuture,
            builder: (context, AsyncSnapshot<List<NameCode>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: LinearProgressIndicator(),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Error Occurred",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }
              if ((snapshot.data?.length ?? 0) == 0) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "All codes ok. Go to next page!",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return NameCodeTile(
                        index: index,
                        nameCode: snapshot.data![index],
                        updateCode: updateCode,
                      );
                    },
                    childCount: (snapshot.data?.length ?? 0),
                  ),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Total: ${correctedCodes.length}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }

  Future<void> nextPage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    bool areAllCorrect = true;
    List<String> invalidStocks = [];
    for (var nameCode in correctedCodes) {
      if (!(await nameCode.isCorrect())) {
        areAllCorrect = false;
        invalidStocks.add(nameCode.name);
      }
    }

    if (!areAllCorrect) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Please provide all required codes"),
            content: Text("Invalid: ${invalidStocks.join(", ")}"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () async => Navigator.pop(context),
              )
            ],
          );
        },
      );
    } else {
      validateLogs();
      if (widget._logs.invalidLogs.length != 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CorrectInvalidLogs(widget._logs),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShowValidLogs(widget._logs.validLogs),
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void validateLogs() {
    List<int> removeIndices = [];
    int i = 0;
    for (var nameCode in correctedCodes) {
      if (nameCode.bseCode != null)
        DatabaseActions.addToScripAKA("BSE", nameCode.name, nameCode.bseCode!);
      else if (nameCode.nseCode != null)
        DatabaseActions.addToScripAKA("NSE", nameCode.name, nameCode.nseCode!);
    }

    for (var log in widget._logs.invalidLogs) {
      i++;
      var index = nameIndexMap[log.name];

      if (index == null) continue;

      log.bseCode = correctedCodes[index].bseCode;
      log.nseCode = correctedCodes[index].nseCode;
      if (log.exchange != null &&
          log.bought != null &&
          log.date != null &&
          log.code != null) {
        widget._logs.validLogs.add(log);
        removeIndices.add(i - 1);
      }
    }

    for (var index in removeIndices.reversed)
      widget._logs.invalidLogs.removeAt(index);
  }

  void updateCode(int index, String? bseCode, String? nseCode) async {
    correctedCodes[index].bseCode = bseCode;
    correctedCodes[index].nseCode = nseCode;
  }

  Future<List<NameCode>> getStocksWithInvalidCodes(
      List<FileLog> invalidLogs) async {
    for (var log in invalidLogs) {
      if (log.code == null && log.name != null) {
        var index = nameIndexMap[log.name];
        if (index == null) {
          nameIndexMap[log.name!] = correctedCodes.length;
          correctedCodes.add(NameCode(log.name!));
          correctedCodes.last.isBSECodeRequired = log.isBSECodeRequired;
          correctedCodes.last.isNSECodeRequired = log.isNSECodeRequired;
        } else {
          correctedCodes[index].isBSECodeRequired =
              correctedCodes[index].isBSECodeRequired || log.isBSECodeRequired;
          correctedCodes[index].isNSECodeRequired =
              correctedCodes[index].isNSECodeRequired || log.isNSECodeRequired;
        }
      }
    }

    setState(() {
      isLoading = false;
    });
    return correctedCodes;
  }
}

class NameCode {
  late String name;
  String? bseCode;
  String? nseCode;
  bool isBSECodeRequired = false, isNSECodeRequired = false;

  NameCode(this.name, {this.bseCode, this.nseCode});

  Future<bool> isCorrect() async {
    List<Map<String, dynamic>>? bseScripsTuple, nseScripsTuple;
    if (bseCode == null) {
      if (isBSECodeRequired) return false;
    } else {
      bseScripsTuple = await DatabaseActions.getScripsFromCode("BSE", bseCode!);
      if (bseScripsTuple.length != 1) {
        return false;
      }
    }

    if (nseCode == null) {
      if (isNSECodeRequired) return false;
    } else {
      nseScripsTuple = await DatabaseActions.getScripsFromCode("NSE", nseCode!);
      if (nseScripsTuple.length != 1) {
        return false;
      }
    }

    if (nseScripsTuple?.length == 1 && bseScripsTuple?.length == 1) {
      if (bseScripsTuple?.first[Db.colRowID] != nseScripsTuple?.first[Db.colRowID]) {
        return false;
      }
    }

    return true;
  }
}
