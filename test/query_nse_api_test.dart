import 'dart:developer';
import 'dart:io';

import 'package:folio/services/query/query_nse_api.dart';

var codes = ['ONGC', 'AUROPHARMA', 'HOVS', 'BPCL'];

void main() async {
  for (var code in codes) {
    var res = await QueryNSEAPI.getCurrentData(code);
    log(res.toString());
    sleep(const Duration(minutes: 1));
  }
}
