import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FinPlanAppHomeScreenWidget extends StatelessWidget {
  // declare the widget attributes
  final Key? key;
  final int tabCount;
  final List<String> tabNames;
  final String title;
  final List<IconButton> actions;
  final List<Widget> tabBarViews;

  Logger log = Logger();

  static List<IconButton> defaultActions = [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {},
    ),
    IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {},
    ),
  ];

  // default constructor
  FinPlanAppHomeScreenWidget({
    this.key,
    required this.tabCount,
    required this.tabNames,
    required this.title,
    required this.tabBarViews,
    required String caller,
    List<IconButton>? actions,
  })  : actions = actions ?? defaultActions,
        super(key: key)
  // {
  //    add constructor body here
  // }
  ;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        body: TabBarView(
          children: tabBarViews
          ),
        bottomNavigationBar: Visibility(
          visible: tabCount > 1,
          child: Container(
            margin: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50, // White background
              borderRadius:
                  BorderRadius.circular(15.0), // Adjust the border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.1), // Add a shadow for a bit of depth
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    1.0), // Border radius for the indicator
                color: Colors.transparent, // White color for the indicator
              ),
              labelColor: Theme.of(context)
                  .primaryColor, // Pink text for the selected tab
              unselectedLabelColor:
                  Colors.grey.shade500, // BlRack text for unselected tabs
              tabs: _buildTabsFromNames(tabNames),
              // isScrollable: true,
            ),
          ),
        ),
      ),
    );
  }

  // Utility method
  List<Tab> _buildTabsFromNames(List<String> tabNames) {
    List<Tab> availableTabs = [];
    for (String tabName in tabNames) {
      Tab eachTab = Tab(text: tabName);
      availableTabs.add(eachTab);
    }
    return availableTabs;
  }
}
