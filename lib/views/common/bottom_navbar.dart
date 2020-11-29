import 'package:flutter/material.dart';
import 'package:folio/views/logs/logs.dart';
import 'package:folio/views/portfolio/portfolio.dart';
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
        BottomNavigationBarItem(
          icon: Icon(Icons.table_rows_outlined),
          label: 'Portfolio',
        ),
      ],
      currentIndex: widget.index,
      backgroundColor: Theme.of(context).backgroundColor,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
      onTap: (index) {
        // if (index == widget.index) return;
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TrackedView()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LogsView()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PortfolioView()),
            );
            break;
        }
      },
    );
  }
}
