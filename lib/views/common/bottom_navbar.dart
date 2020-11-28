import 'package:flutter/material.dart';
import 'package:folio/views/logs/logs.dart';
import 'package:folio/views/tracked/tracked.dart';

class BottomNavbar extends StatefulWidget {
  final int index;
  const BottomNavbar(this.index);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Tracked',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Logs',
        ),
      ],
      currentIndex: widget.index,
      backgroundColor: Theme.of(context).backgroundColor,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
      onTap: (index) {
        if (index == widget.index) return;
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TrackedView()),
          );
        } else if(index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LogsView()),
          );
        }
      },
    );
  }
}
