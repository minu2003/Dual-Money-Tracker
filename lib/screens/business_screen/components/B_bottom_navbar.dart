import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_app/screens/view/home_screen.dart';
import 'package:money_app/screens/view/pie_charts.dart';

import '../business_home_screen.dart';
import 'BusinessPiecharts.dart';

class B_BottomNavBar extends StatelessWidget {
  const B_BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
      child: SizedBox(
        height: 100,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.white38,
            elevation: 3,
            items: [
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => BusinessHomeScreen(onAccountChanged: (String account) {}))
                    );
                  },
                  child: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.home_filled,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => businessPiechartScreen())
                    );
                  },
                  child: Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Icon(
                        Icons.pie_chart,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                label: 'PieChart',
              ),

            ],
          ),
        ),
      ),
    );
  }
}