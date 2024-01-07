// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FinPlanDatepickerPanelWidget2 extends StatefulWidget {

  bool showFavoriteRanges = true;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final Function(DateTime, DateTime) onDateRangeSelected;
  
  FinPlanDatepickerPanelWidget2({
    Key? key,
    showFavoriteRanges,
    startDate,
    endDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  FinPlanDatepickerPanelWidget2State createState() => FinPlanDatepickerPanelWidget2State();
  
}

class FinPlanDatepickerPanelWidget2State extends State<FinPlanDatepickerPanelWidget2> {

  late bool showFavoriteRanges;
  late DateTime startDate;
  late DateTime endDate;
  late Function(DateTime, DateTime) onDateRangeSelected;
  final Logger log = Logger();
  final String DATE_FORMAT_IN = 'dd-MM-yyyy';
  late bool showDatePanel = true;

  @override
  void initState() {
    super.initState();

    // Pass on the params from parent to child
    showFavoriteRanges = widget.showFavoriteRanges;
    startDate = widget.startDate;
    endDate = widget.endDate;
    onDateRangeSelected = widget.onDateRangeSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the date ranges buttons if calling widget requires.
          Visibility(
            visible: showFavoriteRanges,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: getFavoriteDateRangedButtons(),
              ),
            ),
          ),

          // Show the start date picker
          Visibility(
            visible: showDatePanel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Start Date:'),
                  TextButton(
                    onPressed: () => _selectDate(context, startDate, widget.onDateRangeSelected, startOrEndDate: 'start'),
                    child: Text(
                      DateFormat(DATE_FORMAT_IN).format(startDate), // Format the date
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ) ,
            )
          ),

          // Show the end date picker
          Visibility(
            visible: showDatePanel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('End Date:'),
                  TextButton(
                    onPressed: () => _selectDate(context, endDate, widget.onDateRangeSelected, startOrEndDate: 'end'),
                    child: Text(
                      DateFormat(DATE_FORMAT_IN).format(endDate), // Format the date
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime selectedDate, Function(DateTime, DateTime) onDateRangeSelected, {required String startOrEndDate}) async {
    final DateTime? picked;

    if (startOrEndDate == 'start') {
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().add(const Duration(days : -365)),
        lastDate: DateTime.now(),
      );
    } else {
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: startDate,
        lastDate: DateTime.now(),
      );
    }

    if (picked != null) {
      // Update the selected date in the parent widget when a dte is chosen
      if (startOrEndDate == 'start') {
        onDateRangeSelected(picked, endDate);
      } else {
        onDateRangeSelected(startDate, picked);
      }
      setState(() {}); 
      // Trigger a rebuild of the widget when the date changes
    }
  }

  // A specialized function to show specific date ranges like `Today`, `Tomorrow`, `Last 7 days` etc.
  dynamic getFavoriteDateRangedButtons() {
    
    List<String> favoriteDateRanges = ['Today', 'Yesterday', 'Last 7 days', 'Custom'];
    List<Widget> rangedButtons = [];
    ElevatedButton eButton;
    SizedBox sBox = const SizedBox(width: 8);

    for(String dateRange in favoriteDateRanges){
      // Add the elevated button
      eButton = ElevatedButton(
        onPressed: () { handleFavoriteDateRangeButtonClick(dateRange); }, 
        // style: ElevatedButton.styleFrom(
        //   padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
        // ),
        child: Text(
          dateRange, 
          style: const TextStyle(fontSize: 12) // Adjust font size as needed
        )
      );
      rangedButtons.add(eButton);

      // Add the sized box to keep gap between buttons
      rangedButtons.add(sBox);
    }
    return rangedButtons;
  }

  // An utility function to update the state variables e.g. `selectedStartDate`, `selectedEndDate`, `showDatePickerPanel`, `data` etc..
  handleFavoriteDateRangeButtonClick(String range){
    Logger().d('I am here');
    DateTime sDate, eDate;
    bool show = false;
    switch (range) {
      case 'Today':
        sDate = DateTime.now();
        eDate = DateTime.now();
        show = false;
        break;
      case 'Yesterday':
        sDate = DateTime.now().add(const Duration(days: -1));
        eDate = DateTime.now().add(const Duration(days: -1));
        show = false;
        break;
      case 'Last 7 days':
        sDate = DateTime.now().add(const Duration(days: -7));
        eDate = DateTime.now();
        show = false;
        break;
      case 'Custom':
        sDate = DateTime.now();
        eDate = DateTime.now();
        show = true;
        break;
      default:  
        sDate = DateTime.now();
        eDate = DateTime.now();
        show = true;
        break;
    }
    
    setState(() {
      startDate = sDate;
      endDate = eDate;
      showDatePanel = show;
      // showDatePanel = true; // for debug
      // if(range != 'Custom'){ // Refresh the data only when any date range other than `Custom` is chosen
      //   data = Future.value(DataGenerator.generateDataForExpenseScreen0(startDate : selectedStartDate, endDate : selectedEndDate)); 
      // }
      // else{
      //   data = Future.value([]); // If custom is chosen blank out existing data so user can manually search
      // }
    });   
  }

}