import 'dart:developer' show log;
import 'package:dio/dio.dart';
import 'package:requests/requests.dart' show Requests;
import 'package:html/parser.dart';

Future<String> searchAPIKey(String code, String exchange) async {
  var dio = Dio()
    ..options.headers = {
      'User-Agent'.toLowerCase():
          'Mozilla/5.0 (X11; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0',
      'Accept'.toLowerCase():
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language'.toLowerCase(): 'en-US,en;q=0.5',
      'DNT'.toLowerCase(): '1',
      'Upgrade-Insecure-Requests'.toLowerCase(): '1'
    };
  switch (exchange) {
    case "BSE":
      code = "BOM:" + code;
      break;
  }
  try {
    Response<String> r = await dio.get(
      "https://www.google.com/search",
      queryParameters: {
        "client": "firefox-b-d",
        "q": code + " " + exchange + " share price",
        "tbm": "fin",
      },
    );

    if (r.statusCode == 200) {
      var match =
          RegExp(r'data-mid="([a-zA-Z0-9\/]*)"').firstMatch(r.data).group(1);

      return match;
    }
  } on Exception {
    return null;
  }
}

void searchAPIKeyReq(String code, String exchange) async {
  var uri = Uri.http(
    "www.google.com",
    "/search",
    {
      "client": "firefox-b-d",
      "q": code + " " + exchange + " share price",
      "tbm": "fin",
    },
  );
  print(uri);

  var r = await Requests.get(
    uri.toString(),
    headers: {
      'User-Agent'.toLowerCase():
          'Mozilla/5.0 (X11; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0',
      'Accept'.toLowerCase():
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language'.toLowerCase(): 'en-US,en;q=0.5',
      'DNT'.toLowerCase(): '1',
      'Upgrade-Insecure-Requests'.toLowerCase(): '1',
    },
  );
  log(r.content());
  // var match =
  //     RegExp(r'data-mid="([a-zA-Z0-9\/]*)"').firstMatch(r.content()).group(0);

  // print(match);
  // return match;
}

void queryStockData(String code, String exchange) {
  
}