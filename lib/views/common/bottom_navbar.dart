import 'package:flutter/material.dart';
import 'package:folio/views/trades/trades.dart';
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
      elevation: 4,
      iconSize: 30,
      selectedFontSize: 18,
      unselectedFontSize: 18,
      backgroundColor: Theme.of(context).colorScheme.background,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
      currentIndex: widget.index,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Tracked',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Trades',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_rows_outlined),
          label: 'Portfolio',
        ),
      ],
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
              MaterialPageRoute(builder: (context) => TradesView()),
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
