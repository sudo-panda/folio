import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  const Dropdown(
    this.list,
    this.choice,
  );

  // the list for the dropdown
  final List<String> list;

  // the value to show initially in the dropdown
  final int choice;

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  var choice;

  @override
  void initState() {
    super.initState();
    choice = widget.choice;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.list[choice],
      isExpanded: true,
      icon: Align(
        child: Icon(Icons.arrow_drop_down_rounded),
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        color: Theme.of(context).accentColor,
      ),
      underline: Container(
        height: 2,
        color: Theme.of(context).dividerColor,
      ),
      onChanged: (String newValue) {
        setState(() {
          for (var i = 0; i < widget.list.length; i++) {
            if (newValue == widget.list[i]) {
              choice = i;
            }
          }
        });
      },
      items: widget.list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
