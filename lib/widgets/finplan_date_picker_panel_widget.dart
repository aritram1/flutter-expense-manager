// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FinPlanDatepickerPanelWidget extends StatefulWidget {

  final List<String> dateRanges;
  final void Function (DateTime sDate, DateTime eDate) onDateRangeSelected;

  final List<String> validDateRanges = ['All', 'Today', 'Yesterday', 'Last 7 days', 'Last 30 days', 'Last 6 months', 'Last 12 months', 'Custom'];
  
  FinPlanDatepickerPanelWidget({
    Key? key,
    this.dateRanges = const ['All', 'Today', 'Yesterday', 'Last 7 days', 'Last 30 days'],
    required this.onDateRangeSelected,
  }) : super(key: key){
    assert(() {
      for (var range in dateRanges) {
        if (!validDateRanges.contains(range)) {
          throw AssertionError('Invalid date range: $range. Please provide any of these ranges : $validDateRanges');
        }
      }
      return true;
    }());
  }
  
  @override
  FinPlanDatepickerPanelWidgetState createState() => FinPlanDatepickerPanelWidgetState();
  
}

class FinPlanDatepickerPanelWidgetState extends State<FinPlanDatepickerPanelWidget> {

  // Class variables
  late DateTime startDate; // = DateTime.now();
  late DateTime endDate; // = DateTime.now();
  late bool showDatePanel; // = true;

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');
  
  final String DATE_FORMAT_IN = 'dd-MM-yyyy';
      
  @override
  void initState() {
    super.initState();
    startDate = DateTime.now(); // default dates
    endDate = DateTime.now(); // default dates
    showDatePanel = true;
    if(detaildebug) log.d('The init state has run');
  }
  
  @override
  Widget build(BuildContext context) {
    if(detaildebug) log.d('The build method has run');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the date ranges buttons if calling widget requires.
          Visibility(
            visible: widget.dateRanges.isNotEmpty,
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
                      DateFormat(DATE_FORMAT_IN ).format(startDate), // DATE_FORMAT_IN is MM-DD-YYYY
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
                      DateFormat(DATE_FORMAT_IN).format(endDate), // DATE_FORMAT_IN is MM-DD-YYYY
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
        firstDate: DateTime.now().add(const Duration(days : -365)), // Can select date upto one year back
        lastDate: endDate,
      );
    } else {
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: startDate,
        lastDate: DateTime.now(),
      );
    }

    log.d('picked date is $picked');


    if (picked != null) {
      setState(() {
        if (startOrEndDate == 'start') {
          log.d('start picked date is $picked');
          startDate = picked!;
        } else {
          log.d('end picked date is $picked');
          endDate = picked!;
        }
        // showDatePanel = true;
      });
      if(debug){
        log.d('Manually changed StartDate $startDate');
        log.d('Manually changed EndDate $endDate');
      }
      widget.onDateRangeSelected(startDate, endDate);
    }
  }

  // A specialized function to show specific date ranges like `Today`, `Tomorrow`, `Last 7 days`, `Last 30 days` etc.
  dynamic getFavoriteDateRangedButtons() {
    
    List<String> favoriteDateRanges = widget.dateRanges; 
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
    log.d('I am here with range $range');
    DateTime sDate, eDate;
    bool show;
    switch (range) {
      case 'All':
        sDate = DateTime.now().add(const Duration(days: -365));
        eDate = DateTime.now();
        show = false;
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
      case 'Last 30 days':
        sDate = DateTime.now().add(const Duration(days: -30));
        eDate = DateTime.now();
        show = false;
        break;
      case 'Last 6 months':
        sDate = DateTime.now().add(const Duration(days: -180));
        eDate = DateTime.now();
        show = false;
        break;
      case 'Last 12 months':
        sDate = DateTime.now().add(const Duration(days: -360));
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
      // showDatePanel = show; // TBD if it will be helpful
      // showDatePanel = true; // for debug
      widget.onDateRangeSelected(startDate, endDate); 
    });  
  }

}
