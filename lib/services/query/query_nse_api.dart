import 'dart:convert';
import 'dart:developer' as dev;

import 'package:folio/models/stock/latest.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  Map<String, String> cookies = {};

  void _updateCookie(http.Response response) {
    String? allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var index = rawCookie.indexOf('=');
      if (index != -1 && index != rawCookie.length - 1) {
        var key = rawCookie.substring(0, index).trim();
        var keyLC = key.toLowerCase();
        var value = rawCookie.substring(index + 1).trim();

        // ignore keys that aren't cookies
        if (keyLC == 'samesite' ||
            keyLC == 'domain' ||
            keyLC == 'max-age' ||
            keyLC == 'expires' ||
            keyLC == 'path' ||
            keyLC == 'expires') return;

        this.cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += "; ";
      cookie += key + "=" + cookies[key]!;
    }

    return cookie;
  }

  Future<String> get(Uri uri, Map<String, String> headers) async {
    headers['cookie'] = _generateCookieHeader();

    http.Response response = await http.get(uri, headers: headers);
    final String res = response.body;
    final int statusCode = response.statusCode;

    _updateCookie(response);

    if (statusCode < 200 || statusCode > 400) {
      throw new Exception("Error while fetching data: " +
          statusCode.toString() +
          "\n\n" +
          (response.request?.headers?.toString() ??
              "<<< Headers  are NULL >>>"));
    }
    return res;
  }
}

class QueryNSEAPI {
  static final Map<String, String> headers = {
    'User-Agent'.toLowerCase():
        'Mozilla/5.0 (X11; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0',
    'Accept'.toLowerCase(): '*/*',
    'Accept-Language'.toLowerCase(): 'en-US,en;q=0.5',
    'Accept-Encoding'.toLowerCase(): 'gzip, deflate, br',
    'DNT'.toLowerCase(): '1',
    'Connection'.toLowerCase(): 'keep-alive',
    'Upgrade-Insecure-Requests'.toLowerCase(): '1',
  };

  static Future<Latest?> getCurrentData(String code) async {
    var session = NetworkService();
    var uri = Uri.https(
      'www.nseindia.com',
      '/get-quotes/equity',
      {
        "symbol": code,
      },
    );

    try {
      await session.get(uri, headers);
    } catch (e) {
      dev.log(
          "query_nse_api.getCurrentData($code) => \nNSE: Error getting cookies : " +
              e.toString());
    }

    uri = Uri.https(
      'www.nseindia.com',
      '/api/quote-equity',
      {
        "symbol": code,
      },
    );

    String r;

    try {
      r = await session.get(uri, headers);
    } catch (e) {
      dev.log("query_nse_api.getCurrentData($code) try 1 => \n" + e.toString());
      return null;
    }

    try {
      var data = jsonDecode(r);
      var ret = Latest.fromData(
          double.parse(data['priceInfo']['lastPrice'].toString()),
          double.parse(data['priceInfo']['change'].toString())
              .abs()
              .toStringAsFixed(2),
          double.parse(data['priceInfo']['pChange'].toString())
              .abs()
              .toStringAsFixed(2),
          double.parse(data['priceInfo']['change'].toString()).sign.round(),
          data['metadata']['lastUpdateTime'].toString());
      return ret;
    } catch (e) {
      dev.log("query_nse_api.getCurrentData() try 2 => \n" + e.toString());
      return null;
    }
  }

  static Future<String?> getName(String code) async {
    var session = NetworkService();
    var uri = Uri.https(
      'www.nseindia.com',
      '/get-quotes/equity',
      {
        "symbol": code,
      },
    );

    try {
      await session.get(uri, headers);
    } catch (e) {
      dev.log(
          "query_nse_api.getCurrentData($code) => \nNSE: Error getting cookies : " +
              e.toString());
    }

    uri = Uri.https(
      'www.nseindia.com',
      '/api/quote-equity',
      {
        "symbol": code,
      },
    );

    String r;

    try {
      r = await session.get(uri, headers);
    } catch (e) {
      dev.log("query_nse_api.getName($code) => try 1 \n" + e.toString());
      return null;
    }
    var data = jsonDecode(r);
    try {
      String ret = data['info']['companyName'].toString();
      return ret;
    } catch (e) {
      dev.log("query_nse_api.getName($code) => try 2 \n" + e.toString());
      return null;
    }
  }
}
