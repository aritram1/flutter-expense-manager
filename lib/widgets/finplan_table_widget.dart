import 'package:ExpenseManager/widgets/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../utils/finplan_exception.dart';

class FinPlanTableWidget extends StatefulWidget {
  final List<String> headerNames;
  final List<Map<String, dynamic>> data;
  final Function(String) onLoadComplete;
  final String noRecordFoundMessage;
  final String caller;
  final List<double> columnWidths;
  final String defaultSortcolumnName;
  final bool showSelectionBoxes;


  const FinPlanTableWidget({
    Key? key,
    required this.headerNames,
    required this.data,
    required this.onLoadComplete,
    required this.caller,
    required this.columnWidths,
    required this.defaultSortcolumnName,
    this.noRecordFoundMessage = 'Default Message for no records!',
    this.showSelectionBoxes = true,
  }) : super(key: key);

  @override
  FinPlanTableWidgetState createState() => FinPlanTableWidgetState();
}

class FinPlanTableWidgetState extends State<FinPlanTableWidget> {

  final List<String> numericColumns = ['Amount', 'Balance'];
  final List<String> dateColumns = ['Date'];
  final List<String> dateTimeColumns = ['Last Updated'];
  
  List<Map<String, dynamic>> tableData = [];
  List<String> selectedRowIds = [];
  final Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');
  bool isLoading = false;

  int sortColumnIndex = 0;
  bool _sortAscending = false;
  List<IconData?> _sortIcons = [];
  int onLoadDefaultDescendingColumnId = 2; // default order declared
  final int constNameColumnId = 0;
  final int constAmountColumnId = 1;
  final int constDateColumnId = 2;

  @override
  void initState() {

    super.initState();

    // If the `deafultSortColumn` is not present in passed `headernames`, throw an exception
    if(!widget.headerNames.contains(widget.defaultSortcolumnName)) {
      throw FinPlanException('default sorting column "${widget.defaultSortcolumnName}" is not present in table header !') ;
    }

    // Initialize tableData based on whether widget.data is empty or not
    tableData = widget.data.isNotEmpty ? widget.data : [];
    
    int defaultSortcolumnIndex = 0;
    _sortIcons = List.generate(widget.headerNames.length, (colIndex) {
      if (widget.headerNames[colIndex] == widget.defaultSortcolumnName) {
        defaultSortcolumnIndex = colIndex;
        // Set default sorting icon as ascending on load, so it will be reversed in the sortColumn method
        return Icons.arrow_upward;
      } 
      else {
        return null; // no specific rule for other columns
      }
    });
    
    if(debug) log.d('defaultSortcolumnIndex is=> $defaultSortcolumnIndex');
    sortColumn(defaultSortcolumnIndex); // Sort the table on load, based on `defaultColumnIndex`

    // Set error callback in case some error occurs while loading the widget
    FlutterError.onError = (FlutterErrorDetails details) {
      // Custom error handling logic
      String exceptionDetails = details.exception.toString();
      String errorStack = (details.stack != null) ? details.stack.toString() : 'N/A';
      widget.onLoadComplete('Error occurred while loading table : Details : $exceptionDetails | Stack : $errorStack');
    };

    // Notify onLoadComplete based on the initialization result
    widget.onLoadComplete(tableData.isNotEmpty ? 'SUCCESS' : 'Error: Empty data sent to table');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: widget.data.isEmpty
                ? _buildEmptyTableMessage()
                : isLoading
                  ? const Center(
                    child: CircularProgressIndicator(), // Show loading indicator
                  )
                  : SingleChildScrollView( 
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        showCheckboxColumn: widget.showSelectionBoxes,
                        columnSpacing: 0.0,
                        headingRowHeight: 40.0,
                        sortAscending: _sortAscending,
                        columns: _generateColumns(),
                        rows: _generateRows(),
                      ),
                    ),
            ),
          ],         
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
            visible: selectedRowIds.isNotEmpty,
            child : createApproveButton()
          ),
        ),
      ],
    );
  }

  createApproveButton(){
    return
      ElevatedButton.icon(
        onPressed: () async {
          await handleApproveSMS(selectedRowIds);
          setState(() {
            selectedRowIds.clear();
          });
        },
        icon: const Icon(Icons.approval), //, color: Color.fromARGB(255, 194, 127, 233)), // Set the icon color
        label: const Text('Approve'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              // Define the background color based on the button's state
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey; // Grey color when pressed
              }
              return Colors.blue.shade50; // Default background color
            },
          ),
          elevation: MaterialStateProperty.all<double>(0.0),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Adjust the border radius
            ),
          ),
        ),
      );
  }

  _generateColumns() {
    return List.generate(widget.headerNames.length, (index) {
      return DataColumn(
        label: SizedBox(
          width: MediaQuery.of(context).size.width *
              widget.columnWidths[index], // Use provided column width
          child: InkWell(
            onTap: () {
              log.d('I am here $index');
              sortColumn(index);
            },
            child: Row(
              children: [
                Text(widget.headerNames[index]),
                if (index < _sortIcons.length && _sortIcons[index] != null)
                  Icon(
                    _sortIcons[index],
                    size: 15.0, // Adjust the size as needed
                  ),
              ],
            ),
          ),
        ),
        onSort: (columnIndex, ascending) {
          sortColumn(columnIndex);
        },
        numeric: false,
      );
    });
  }

  _generateRows() {
    return widget.data.asMap().entries.map((entry) {
      final String rowIndex = entry.value['Id'];
      final row = entry.value;

      return DataRow(
        selected: selectedRowIds.contains(rowIndex), // Updated line
        onSelectChanged: (selected) {
          handleRowSelection(selected, rowIndex);
        },
        cells: List.generate(widget.headerNames.length, (index) {
          return DataCell(
            SizedBox(
              width: MediaQuery.of(context).size.width * widget.columnWidths[index], // Use provided column width
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child : Text(getFormattedCellData(widget.headerNames[index], row), maxLines: 2)
              ),
            ),
          );
        }),
      );
    }).toList();
  }

  void sortColumn(int colIndex) async {
    setState(() {
      // Show the spinner till the sorting is completed
      isLoading = true;
    });

    await _sortColumn(colIndex);

    // Way to create async mocking
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      // stop the spinner because the sorting is completed
      isLoading = false;
    });
  }

  Future<void> _sortColumn(int columnIndex) async {
    // Start the sorting

    for (int i = 0; i < _sortIcons.length; i++) {
      if (i == columnIndex) {
        if (_sortIcons[i] == Icons.arrow_upward) {
          _sortIcons[i] = Icons.arrow_downward;
          _sortAscending = false;
        } else {
          _sortIcons[i] = Icons.arrow_upward;
          _sortAscending = true;
        }
      } else {
        _sortIcons[i] = null;
      }
    }

    sortColumnIndex = columnIndex;
    if (detaildebug){
      log.d('I am here sortColumnIndex and sortascending values => $sortColumnIndex $_sortAscending');
    }
    widget.data.sort((a, b) {

      int result = 0;

      if(detaildebug){
        // log.d('a => $a');
        // log.d('b => $b');
      }
      String columnName = widget.headerNames[sortColumnIndex];

      if(detaildebug){
        // log.d('a => ${a[columnName]}');//I am here sortColumnIndex => $sortColumnIndex $_sortAscending');
        // log.d('b => ${b[columnName]}');//log.d('I am here sortColumnIndex => $sortColumnIndex $_sortAscending');
      }
      
      if (columnIndex == constNameColumnId) { // constNameColumnId = 0;
        result = compareStrings(a[columnName], b[columnName]);
      }
      else if (columnIndex == constAmountColumnId) {  // constAmountColumnId = 1;
        result = compareNumeric(a[columnName], b[columnName]);
      }
      else if (columnIndex == constDateColumnId) {  // constDateColumnId = 2
        result = compareDates(a[columnName], b[columnName]);
      }
      if(detaildebug) log.d('Interim result : $result');

      // Second layer sorting 
      // If the first column comparison is equal, use another column for sorting. See the default order below
      if (result == 0) {
        if (columnIndex == constNameColumnId) {
          result = compareDates(a[widget.headerNames[constDateColumnId]], b[widget.headerNames[constDateColumnId]]); // If still `amounts` are same finally sort by `date`
          if (result == 0) {
            result = compareNumeric(a[widget.headerNames[constAmountColumnId]], b[widget.headerNames[constAmountColumnId]]); // If `names` are same sort by `amount`
          }
        } 
        else if (columnIndex == constAmountColumnId) {
          result = compareStrings(a[widget.headerNames[constNameColumnId]], b[widget.headerNames[constNameColumnId]]); // If `amounts` are same sort by `name`
          if (result == 0) {
            result = compareDates(a[widget.headerNames[constDateColumnId]], b[widget.headerNames[constDateColumnId]]); // If still `names` are same sort by `date`
          }
        } 
        else if (columnIndex == constDateColumnId) {
          result = compareStrings(a[widget.headerNames[constNameColumnId]], b[widget.headerNames[constNameColumnId]]); // If dates are same sort by names
          if (result == 0) {
            result = compareNumeric(a[widget.headerNames[constAmountColumnId]], b[widget.headerNames[constAmountColumnId]]); // If still names are same finally sort by amount
          }
        }
      }
      if (detaildebug){
        log.d('_sortAscending ? result : -result => ${_sortAscending ? result : -result}');
      }
      return result;
    });
  }

  // Helper method to compare strings case insensitive
  int compareStrings(String a, String b) {
    a = a.toUpperCase();
    b = b.toUpperCase();
    return _sortAscending ? a.compareTo(b) : b.compareTo(a);
  }

  // Helper method to compare numeric values, removing unnecessary spaces, commas, and currency symbols
  int compareNumeric(double aValue, double bValue) {
    return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
  }

  // Helper method to compare date values
  int compareDates(DateTime aDate, DateTime bDate) {
    return _sortAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
  }

  Widget _buildEmptyTableMessage() {
    if (widget.data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: 
        Center(
          child: Text(
            widget.noRecordFoundMessage,
            // style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  void handleRowSelection(bool? selected, String rowIndex) {
    setState(() {
      if (selected != null) {
        if (selected) {
          selectedRowIds.add(rowIndex);
        } else {
          selectedRowIds.remove(rowIndex);
        }
      }
    });
  }

  String getFormattedCellData(String columnName, dynamic row){
    
    String formattedCellData = '';
    
    /////////////////////////// For Date type columns ///////////////////////////////////////
    if(dateColumns.contains(columnName)){
      String yyyymmdd = row[columnName].toString().substring(0, 10);
      String yy = yyyymmdd.split('-')[0].substring(2,4);  // Instead of `2023` just show `23`
      String mm = yyyymmdd.split('-')[1];
      String dd = yyyymmdd.split('-')[2];
      formattedCellData = '$dd/$mm/$yy';
    }
    /////////////////////////// For DateTime type columns ////////////////////////////////////
    else if(dateTimeColumns.contains(columnName)){
      
      // Convert UTC time to Local Time (+ 5.30 hrs)
      DateTime localDateTime = DateTime.parse(row[columnName].toString()).add(const Duration(hours: 5, minutes: 30));

      if(detaildebug) log.d('LocalDate Time column => ${localDateTime.toString()}');
      String yyyymmdd = localDateTime.toString().split(' ')[0];
      String hhmmss = localDateTime.toString().split(' ')[1].split('.')[0];
      String yy = yyyymmdd.split('-')[0].substring(2,4);
      String mm = yyyymmdd.split('-')[1];
      String dd = yyyymmdd.split('-')[2];
      formattedCellData = '$dd/$mm/$yy $hhmmss';
    }
    /////////////////////////// For Numeric / Currency type columns ///////////////////////////
    else if (numericColumns.contains(columnName)){
      double numericValue = double.parse((row[columnName] ?? 0).toString());
      formattedCellData = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(numericValue);
    }
    /////////////////////////// For All other and text type columns ////////////////////////////
    else{
      formattedCellData = row[columnName].toString();
    }
    return formattedCellData;
  }


  Future<void> handleApproveSMS(List<String> recordIds) async {
    
    // Set the flag to true when starting the approval process
    setState(() {
      isLoading = true;
    });
    
    Map<String, dynamic> response = await Util.approveSelectedMessages(objAPIName :'FinPlan__SMS_Message__c', recordIds : recordIds);
    if(debug) log.d('Response for handleApproveSMS ${response.toString()}');

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      // Reset the flag when the approval process is completed
      isLoading = false;
    });
  }
  
}