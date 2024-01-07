import 'package:flutter/material.dart';
// import '../../utils/data_generator_local.dart';
import '../../utils/data_generator.dart';
import '../../widgets/finplan_date_picker_panel_widget.dart';
import '../../widgets/finplan_table_widget.dart';
import 'package:logger/logger.dart';

class ExpenseScreen0 extends StatefulWidget {

  const ExpenseScreen0({super.key});

  @override
  ExpenseScreen0State createState() => ExpenseScreen0State();
}

class ExpenseScreen0State extends State<ExpenseScreen0>{

  // Declare the required state variables for this page

  static final Logger log = Logger();
  static DateTime selectedStartDate = DateTime.now().add(const Duration(days: -30));
  static DateTime selectedEndDate = DateTime.now();
  static bool showDatePickerPanel = false;
  static late Future<List<Map<String, dynamic>>> data;
  // static final Future<List<Map<String, dynamic>>> immutableData = DataGenerator.generateDataForExpenseScreen0(startDate : selectedStartDate, endDate : selectedEndDate);

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from ExpenseScreen0 => $result');
  };

  @override
  Widget build(BuildContext context) {
    return 
      // The table panel
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0), 
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: getFavoriteDateRangedButtons(),
                  ),
                ),
              
                // The date picker panel, this is shown when date range is selected as `Custom`
                Visibility(
                  visible: (showDatePickerPanel == true), // same as `visible: showDatePickerPanel`
                  child: FinPlanDatepickerPanelWidget(
                    key: UniqueKey(),
                    onDateRangeSelected: handleDateRangeSelection,
                    startDate: selectedStartDate,
                    endDate: selectedEndDate,
                  ),
                ),
              ]
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: DataGenerator.generateDataForExpenseScreen0(),
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else if (snapshot.hasError) {
                  log.e('Error loading data => ${snapshot.error.toString()}');
                  return Center(
                    child: Text('Error loading data => ${snapshot.error.toString()}'),
                  );
                }
                else {
                  return FinPlanTableWidget(
                    key: widget.key,
                    headerNames: const ['Paid To', 'Amount', 'Date'],
                    noRecordFoundMessage: 'Nothing to approve',
                    caller: 'ExpenseScreen0',
                    columnWidths: const [0.3, 0.2, 0.2],
                    data: snapshot.data!,
                    onLoadComplete: onLoadComplete,
                    defaultSortcolumnName: 'Date',
                  );
                }
              },
            )
          ),
        ],
      );
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
    DateTime sDate = DateTime.now();
    DateTime eDate = DateTime.now();
    bool showPanel = false;
    switch (range) {
      case 'Today':
        // Dates are already initialized as Today, nothing to do
        break;
      case 'Yesterday':
        sDate = DateTime.now().add(const Duration(days: -1));
        eDate = sDate;
        break;
      case 'Last 7 days':
        sDate = DateTime.now().add(const Duration(days: -7));
        eDate = DateTime.now();
        break;
      case 'Custom':
        // Dates are already set , no need to update them, just show the panel now for manual date range selection
        showPanel = true;
        break;
      default:  
        // Default dates are already declared as today
        break;
    }
    
    setState(() {
      selectedStartDate = sDate;
      selectedEndDate = eDate;
      showDatePickerPanel = showPanel;
      showDatePickerPanel = true; // for debug
      if(range != 'Custom'){ // Refresh the data only when any date range other than `Custom` is chosen
        data = Future.value(DataGenerator.generateDataForExpenseScreen0(startDate : selectedStartDate, endDate : selectedEndDate)); 
      }
      else{
        data = Future.value([]); // If custom is chosen blank out existing data so user can manually search
      }
    });   
  }

  // A utility method to update the state once a button is clicked
  Future<void> handleDateRangeSelection(DateTime startDate, DateTime endDate) async {
    setState(() {
      selectedStartDate = startDate;
      selectedEndDate = endDate;
      data = Future.value(DataGenerator.generateDataForExpenseScreen0(startDate : selectedStartDate, endDate : selectedEndDate));
    });
  }
}