import 'package:folio/helpers/database.dart';
import 'package:folio/models/database/portfolio.dart';

class DatabaseActions {
  static Future<List<Portfolio>> getAllPortfolios() async {
    List<Map> tuples = await Db().getOrdered(
        Db.tblPortfolio, '${Db.colNSECode} DESC, ${Db.colBSECode} DESC');

    List<Portfolio> portfolio = [];
    tuples.forEach((row) => portfolio.add(Portfolio.fromDbTuple(row)));
    return portfolio;
  }
}
