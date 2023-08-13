import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:folio/models/stock/latest.dart';

class QueryBSEAPI {
  static Future<Latest?> getCurrentData(String code) async {
    var dio = Dio()
      ..options.headers = {
        'User-Agent'.toLowerCase():
            'Mozilla/5.0 (X11; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0',
        'Accept'.toLowerCase(): 'application/json, text/plain, */*',
        'Accept-Language'.toLowerCase(): 'en-US,en;q=0.5',
        'Origin'.toLowerCase(): ' https://www.bseindia.com',
      };
    try {
      Response<String> r = await dio.get(
        "https://api.bseindia.com/BseIndiaAPI/api/StockReachGraph/w",
        queryParameters: {
          "scripcode": code,
          "flag": "0",
          "fromdate": "",
          "todate": "",
          "seriesid": "",
        },
      );
      if (r.statusCode == 200 && r.data != null) {
        var data = jsonDecode(r.data!);
        double currVal = double.parse(data['CurrVal']);
        double prevClose = double.parse(data['PrevClose']);
        double change = (currVal - prevClose);
        double? percentChange = (prevClose == 0) ? null : ((change * 100.0) / prevClose);
        var sign = change.sign.round();
        var ret = Latest.fromData(
            double.parse(data['CurrVal']),
            change.abs().toStringAsFixed(2),
            percentChange?.abs().toStringAsFixed(2) ?? "-",
            sign,
            data['CurrDate']);
        return ret;
      } else {
        log("query_bse_api.getCurrentData($code) => \n " +
            r.statusCode.toString() +
            ": " +
            (r.statusMessage ?? ""));
        return null;
      }
    } catch (e) {
      log("query_bse_api.getCurrentData($code) => \n " + e.toString());
      return null;
    }
  }

  static Future<String?> getName(String code) async {
    var dio = Dio()
      ..options.headers = {
        'User-Agent'.toLowerCase():
            'Mozilla/5.0 (X11; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0',
        'Accept'.toLowerCase(): 'application/json, text/plain, */*',
        'Accept-Language'.toLowerCase(): 'en-US,en;q=0.5',
        'Origin'.toLowerCase(): ' https://www.bseindia.com',
      };
    try {
      Response<String> r = await dio.get(
        "https://api.bseindia.com/BseIndiaAPI/api/getScripHeaderData/w",
        queryParameters: {
          "Debtflag": "",
          "scripcode": code,
          "seriesid": "",
        },
      );
      if (r.statusCode == 200 && r.data != null) {
        return jsonDecode(r.data!)['Cmpname']['FullN'].toString();
      } else {
        log("query_bse_api.getName($code) => \n " +
            r.statusCode.toString() +
            ": " +
            (r.statusMessage ?? ""));
        return null;
      }
    } catch (e) {
      log("query_bse_api.getName($code) => \n " + e.toString());
      return null;
    }
  }
}
