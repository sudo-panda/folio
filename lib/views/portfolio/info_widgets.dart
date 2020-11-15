import 'package:flutter/material.dart';

class InfoGroup extends StatelessWidget {
  const InfoGroup({
    Key key,
    @required String heading,
    @required List<Widget> info,
  })  : _heading = heading,
        _info = info,
        super(key: key);

  final String _heading;
  final List<Widget> _info;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _heading,
                style: TextStyle(
                  fontFamily: 'CarroisGothic',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                ),
              ),
            ),
          ] +
          _info,
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    Key key,
    @required String title,
    @required Widget child,
  })  : _title = title,
        _child = child,
        super(key: key);

  final String _title;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _title,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
        Text(
          "  :  ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15.0,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _child,
          ),
        )
      ],
    );
  }
}
