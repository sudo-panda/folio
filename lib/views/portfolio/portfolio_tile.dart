import 'package:folio/models/database/portfolio.dart';
import 'package:folio/views/tracked/details/details.dart';

import 'package:flutter/material.dart';

class PortfolioTile extends StatelessWidget {
  final Portfolio _portfolio;

  PortfolioTile(this._portfolio);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: [
                  _portfolio?.bseCode != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "BSE - " + (_portfolio?.bseCode)!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.edit,
                                  size: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          !.fontSize! +
                                      3,
                                ),
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditCodeDialog(
                                        _portfolio!.bseCode!,
                                        "BSE",
                                        updateBSECode),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: 0,
                        ),
                  _portfolio?.nseCode != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "NSE - " + _portfolio!.nseCode,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.edit,
                                  size: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          !.fontSize! +
                                      3,
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditCodeDialog(
                                        _portfolio!.nseCode!,
                                        "NSE",
                                        updateNSECode),
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      : Container(
                          width: 0,
                        ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    _portfolio?.qty?.toString() ?? "N/A",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _portfolio?.msr?.toStringAsFixed(2) ?? "N/A",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _portfolio?.esr?.toStringAsFixed(2) ?? "N/A",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "QTY",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "MSR",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "ESR",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateBSECode(String code) {
    _portfolio.bseCode = code;
  }

  void updateNSECode(String code) {
    _portfolio.nseCode = code;
  }
}
