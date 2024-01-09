// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FinPlanDatepickerPanelWidget extends StatefulWidget {

  final bool showFavoriteRanges;
  final void Function (DateTime sDate, DateTime eDate) onDateRangeSelected;
  
  const FinPlanDatepickerPanelWidget({
    Key? key,
    required this.showFavoriteRanges,
    required this.onDateRangeSelected,
  }) : super(key: key);
  
  @override
  FinPlanDatepickerPanelWidgetState createState() => FinPlanDatepickerPanelWidgetState();
  
}

class FinPlanDatepickerPanelWidgetState extends State<FinPlanDatepickerPanelWidget> {

  // Class variables
  DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now();
  late bool showDatePanel = true;

  final Logger log = Logger();
  final String DATE_FORMAT_IN = 'dd-MM-yyyy';
  final List<String> FAVORITE_DATE_RANGES = ['Today', 'Yesterday', 'Last 7 days', 'Custom'];
  
  // @override
  // void initState() {
  //   super.initState();
  //   log.d('The init state has run');
  // }
  
  @override
  Widget build(BuildContext context) {
    log.d('The build method has run');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the date ranges buttons if calling widget requires.
          Visibility(
            visible: widget.showFavoriteRanges,
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
                    onPressed: () => _selectDate(context, startDate, startOrEndDate: 'start'),
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(startDate),
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
                    onPressed: () => _selectDate(context, endDate, startOrEndDate: 'end'),
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(endDate),
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

  Future<void> _selectDate(BuildContext context, DateTime selectedDate, {required String startOrEndDate}) async {
    
    DateTime? picked;

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
      setState(() {
        if (startOrEndDate == 'start') {
          startDate = picked!;
        } else {
          endDate = picked!;
        }
      });
      log.d('StartDate $startDate');
      log.d('EndDate $endDate');
      widget.onDateRangeSelected(startDate, endDate);
    }
  }

  // A specialized function to show specific date ranges like `Today`, `Tomorrow`, `Last 7 days` etc.
  dynamic getFavoriteDateRangedButtons() {
    
    List<String> favoriteDateRanges = FAVORITE_DATE_RANGES;
    List<Widget> rangedButtons = [];
    ElevatedButton eButton;
    SizedBox sBox = const SizedBox(width: 8);

    for(String dateRange in favoriteDateRanges){
      // Add the elevated button
      eButton = ElevatedButton(
        onPressed: () { 
          handleFavoriteDateRangeButtonClick(dateRange); 
        },
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

  // An utility function to update the state variables e.g. `startDate`, `endDate`, `showDatePickerPanel`, `data` etc..
  handleFavoriteDateRangeButtonClick(String range){
    Logger().d('I am here with range $range');
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
      showDatePanel = true; // for debug
      if(range != 'Custom'){ // Refresh the data only when any date range other than `Custom` is chosen
        widget.onDateRangeSelected(startDate, endDate); 
      }
    });  
  }

}
