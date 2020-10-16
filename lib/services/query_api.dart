import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:folio/database/database_helper.dart';
import 'package:folio/models/stocks/current_stock_data.dart';
import 'package:folio/services/query/query_bse_api.dart';
import 'package:flutter/foundation.dart';
import 'package:folio/services/query/query_nse_api.dart';
import 'package:folio/services/search.dart';

class QueryAPI {
  static Future<CurrentStockData> getCurrentData(
      {@required String exchange, @required String code, String key}) async {
    assert(exchange != null && code != null);
    switch (exchange) {
      case "BSE":
        return QueryBSEAPI.getCurrentData(code);
      case "NSE":
        return QueryNSEAPI.getCurrentData(code);
    }
    if (key == null) {
      key = await searchAPIKey(code, exchange);
      DatabaseHelper().updateKey(exchange: exchange, code: code, key: key);
    }

    var dio = Dio()
      ..options.headers = {
        'User-Agent'.toLowerCase():
            'Mozilla/5.0 (X11; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0'
      };

    try {
      Response<String> r = await dio.get(
        "https://www.google.com/async/finance_wholepage_price_updates",
        queryParameters: {
          "async": "mids:" + key + ",_fmt:json",
        },
      );

      if (r.statusCode == 200) {
        log(jsonDecode(r.data.substring(4))['PriceUpdate']['entities']
            .first['financial_entity']['common_entity_data']['name']
            .toString());
        var data = jsonDecode(r.data.substring(4))['PriceUpdate']['entities']
            .first['financial_entity']['common_entity_data'];

        var ret = CurrentStockData.fromData(
            double.parse(data['last_value']),
            data['value_change'].toString().substring(1),
            data['percent_change']
                .toString()
                .substring(0, data['percent_change'].toString().length - 1),
            data['change'] == 'NEGATIVE'
                ? -1
                : data['change'] == 'POSITIVE'
                    ? 1
                    : 0,
            data['last_updated_time']);
        return ret;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<String> getName(
      {@required String exchange, @required String code, String key}) async {
    assert(exchange != null && code != null);
    switch (exchange) {
      case "BSE":
        return QueryBSEAPI.getName(code);
      case "NSE":
        return QueryNSEAPI.getName(code);
    }
    if (key == null) {
      key = await searchAPIKey(code, exchange);
      DatabaseHelper().updateKey(exchange: exchange, code: code, key: key);
    }
    
    var dio = Dio()
      ..options.headers = {
        'User-Agent'.toLowerCase():
            'Mozilla/5.0 (X11; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0'
      };

    try {
      Response<String> r = await dio.get(
        "https://www.google.com/async/finance_wholepage_price_updates",
        queryParameters: {
          "async": "mids:" + key + ",_fmt:json",
        },
      );

      if (r.statusCode == 200) {
        var ret = jsonDecode(r.data.substring(4))['PriceUpdate']['entities']
            .first['financial_entity']['common_entity_data']['name']
            .toString();
        return ret;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
