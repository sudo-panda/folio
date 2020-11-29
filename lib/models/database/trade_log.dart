import 'package:folio/helpers/database.dart';

class TradeLog {
  DateTime date;
  int id;
  String code;
  String exchange;
  bool bought;
  int qty;
  double rate;

  TradeLog(this.date, this.id, this.code, this.exchange, this.bought, this.qty,
      this.rate);

  TradeLog.fromDbTuple(Map<String, dynamic> tuple) {
    id = tuple[Db.colStockID];
    code = tuple[Db.colCode];
    exchange = tuple[Db.colExch];
    bought = tuple[Db.colBought] > 0;
    qty = tuple[Db.colQty];
    rate = tuple[Db.colRate];
    date = DateTime.utc(
      int.parse(
        tuple[Db.colDate].substring(
          0,
          tuple[Db.colDate].indexOf('-'),
        ),
      ),
      int.parse(
        tuple[Db.colDate].substring(
          tuple[Db.colDate].indexOf('-') + 1,
          tuple[Db.colDate].lastIndexOf('-'),
        ),
      ),
      int.parse(
        tuple[Db.colDate].substring(tuple[Db.colDate].lastIndexOf('-') + 1),
      ),
    );
  }

  Map<String, dynamic> toDbTuple() {
    return {
      Db.colStockID: id,
      Db.colCode: code,
      Db.colExch: exchange,
      Db.colBought: bought ? 1 : 0,
      Db.colQty: qty,
      Db.colRate: rate,
      Db.colDate: date.year.toString().padLeft(4, '0') +
          '-' +
          date.month.toString().padLeft(2, '0') +
          '-' +
          date.day.toString().padLeft(2, '0'),
    };
  }

  @override
  String toString() {
    return this.toDbTuple().toString();
  }
}
