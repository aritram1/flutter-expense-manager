import 'package:ExpenseManager/util/helper_util.dart';
import 'package:flutter/material.dart';
import 'package:ExpenseManager/util/data_generator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class TableWidget extends StatefulWidget {
  final List<List<String>> tableData;
  final int tabIndex;
  final List<String> columnNames;
  final List<double> columnWidths;

  const TableWidget({
    Key? key,
    required this.tableData,
    required this.tabIndex,
    required this.columnNames,
    required this.columnWidths,
  }) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  late List<bool> selectedRows;
  static final Logger log = Logger();

  int sortColumnIndex = 0;
  bool _sortAscending = false;
  List<IconData?> _sortIcons = [];
  int onLoadDefaultDescendingColumnId = 2; // default order declared
  final int constNameColumnId = 0;
  final int constAmountColumnId = 1;
  final int constDateColumnId = 2;
      
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');

  String approveButtonName = 'Approve';
  bool isApproving = false; // Flag to track whether the approval process is ongoing
  bool isLoading = false; // Flag to track whether the approval process is ongoing

  @override
  void initState(){

    super.initState();

    if(widget.tabIndex == 0 || widget.tabIndex == 1){ 
      // By default, first and second tab will be sorted based on date column `constDateColumnId` which is 2
      onLoadDefaultDescendingColumnId = constDateColumnId;  
    }
    else{
      // By default, the third tab will be sorted based on name column `constNameColumnId` which is 0
      onLoadDefaultDescendingColumnId = constNameColumnId;  
    }

    selectedRows = List.generate(widget.tableData.length, (index) => false);
    _sortIcons = List.generate(widget.columnNames.length, (colIndex) {
      if (colIndex == constDateColumnId) {  
        // specific rule for the date column 
        // i.e. when `constDateColumnId` = 2, set the default sort order and sorting icon
        _sortAscending = false;
        return Icons.arrow_upward;
      } 
      else {
        // no specific rule for other columns
        return null;
      }
    });

    // Sort the data by the third column (date) in descending order initially
    sortColumn(onLoadDefaultDescendingColumnId);
  }

  // The `build` method of the widget
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: widget.tableData.isEmpty
                  ? _buildEmptyTableMessage()
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 1.0,
                        headingRowHeight: 40.0,
                        sortAscending: _sortAscending,
                        columns: List.generate(widget.columnNames.length, (index) {
                          return DataColumn(
                            label: SizedBox(
                              width: widget.columnWidths[index],
                              child: InkWell(
                                onTap: () {
                                  sortColumn(index);
                                },
                                // Async version
                                // onTap: () async {
                                //   setState(() { isLoading = true; });
                                //   log.d('start=> ${DateTime.now(). millisecondsSinceEpoch}');
                                //   await _sortColumn(index); // we found it takes ~ 10ms so no immediate requirement to handle async from calling place
                                //   log.d('end=> ${DateTime.now(). millisecondsSinceEpoch}');
                                //   setState(() { isLoading = false; });
                                // },
                                child: Row(
                                  children: [
                                    Text(widget.columnNames[index]),
                                    if (_sortIcons[index] != null)
                                      Icon(
                                        _sortIcons[index], 
                                        size: 15.0, // Adjust the size as needed
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) { // Can we use this callback ? for using ascending flag? TBD Urgent
                              sortColumn(columnIndex);
                            },
                            numeric: false,
                          );
                        }),
                        rows: widget.tableData.asMap().entries.map((entry) {
                          final rowIndex = entry.key;
                          final row = entry.value;

                          return DataRow(
                            selected: selectedRows[rowIndex],
                            onSelectChanged: (selected) {
                              if (selected != null) {
                                setState(() {
                                  selectedRows[rowIndex] = selected;
                                });
                              }
                            },
                            cells: List.generate(widget.columnNames.length, (index) {
                              return DataCell(
                                SizedBox(
                                  width: widget.columnWidths[index],
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Text(
                                      row[index],
                                      overflow: TextOverflow.clip,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            Visibility(
              visible: showApproveButton(),
              child: ElevatedButton(
                onPressed: () async {
                  await handleApproveSMS();
                },
                child: isApproving ? const CircularProgressIndicator() : Text(approveButtonName),
              ),
            ),
          ],
        ),
        if (isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        if (isApproving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyTableMessage() {
    if (widget.tableData.isEmpty) {
      String message;
      switch (widget.tabIndex) {
        case 0:
          message = 'Nothing to approve';
          break;
        case 1:
          message = 'No transactions are available between the dates';
          break;
        case 2:
          message = 'No bank accounts are available to show';
          break;
        // Add more cases if needed
        default:
          message = 'Default Message : No data found';
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void sortColumn(int colIndex) async{
    setState(() {
      // Show the spinner till the sorting is completed
      isLoading = true;
    });

    await _sortColumn(colIndex);

    // Way to create async mocking
    // await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      // stop the spinner because the sorting is completed
      isLoading = false;
    });
  }

  // The private `_sort` method
  Future<void> _sortColumn(int columnIndex) async{
    
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
    if(detaildebug) log.d('I am here sortColumnIndex => $sortColumnIndex $_sortAscending');
    widget.tableData.sort((a, b) {
      int result = 0;
      if (columnIndex == constNameColumnId) {  // constNameColumnId = 0
        result = compareStrings(a[columnIndex], b[columnIndex]);
      } 
      else if (columnIndex == constAmountColumnId) { // constAmountColumnId = 1;
        result = compareNumeric(a[columnIndex], b[columnIndex]);
      } 
      else if (columnIndex == constDateColumnId) { // constDateColumnId = 2
        result = compareDates(a[columnIndex], b[columnIndex]);
      }

      // If the first column comparison is equal, use another column for sorting. See the default order below
      if (result == 0) {
        if (columnIndex == constNameColumnId) { 
          result = compareDates(a[constDateColumnId], b[constDateColumnId]); // If still `amounts` are same finally sort by `date`
          if(result == 0){      
            result = compareNumeric(a[constAmountColumnId], b[constAmountColumnId]);   // If `names` are same sort by `amount`
          }
        } else if (columnIndex == constAmountColumnId) {
          result = compareStrings(a[constNameColumnId], b[constNameColumnId]); // If `amounts` are same sort by `name`
          if(result == 0){
            result = compareDates(a[constDateColumnId], b[constDateColumnId]); // If still `names` are same sort by `date`
          }
        } else if (columnIndex == constDateColumnId) {
          result = compareStrings(a[constNameColumnId], b[constNameColumnId]); // If dates are same sort by names
          if(result == 0){
            result = compareNumeric(a[constAmountColumnId], b[constAmountColumnId]); // If still names are same finally sort by amount
          }
        }
      }
      if(detaildebug) log.d('_sortAscending ? result : -result => ${_sortAscending ? result : -result}');
      return result;
    });
    
  }

  // Helper method to compare strings case insensitive
  int compareStrings(String a, String b) {
    a = a.toUpperCase();
    b = b.toUpperCase();
    return _sortAscending ? a.compareTo(b) : b.compareTo(a);
  }

  // Helper method to compare numeric values, removing unncessary spaces, commas and currency symbol
  int compareNumeric(String a, String b) {
    // a = a.replaceAll(',', '').replaceAll('INR', '').replaceAll(' ', '');
    // b = b.replaceAll(',', '').replaceAll('INR', '').replaceAll(' ', '');
    // double aValue = double.parse(a);
    // double bValue = double.parse(b);
    double aValue = HelperUtil.parseCurrencyStringsToDouble(a);
    double bValue = HelperUtil.parseCurrencyStringsToDouble(b);
    return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
  }

  // Helper method to compare date values
  int compareDates(String aDateValue, String bDateValue) {
    
    if(detaildebug) log.d('Tabindex is => ${widget.tabIndex}');

    // When its on Messages tab or transactions tab
    if(widget.tabIndex == 0 || widget.tabIndex == 1){
      // just switch the DD/MM format to MM/DD format so they can be string sorted
      aDateValue = '${aDateValue.split('/')[1]}${aDateValue.split('/')[0]}';
      bDateValue = '${bDateValue.split('/')[1]}${bDateValue.split('/')[0]}';
      return _sortAscending ? aDateValue.compareTo(bDateValue) : bDateValue.compareTo(aDateValue);
    }
    else{// To be implemented for third tab // TBD // Urgent
      return 1;
    } 
  }

  bool showApproveButton() {
    return selectedRows.any((selected) => selected) && widget.tabIndex == 0; // widget.tabIndex == 0 means its first tab (messages)
  }

  Future<void> handleApproveSMS() async {
    setState(() {
      // Set the flag to true when starting the approval process
      isApproving = true;
    });

    // Extract recordIds from the list
    List<String> recordIds = [];
    for (int i = 0; i < selectedRows.length; i++) {
      if (selectedRows[i]) {
        recordIds.add(widget.tableData[i][3]);
      }
    }

    if(debug) log.d('recordIds=> $recordIds');

    // Call the API for approve message
    dynamic response = await DataGenerator.approveSelectedMessages(objAPIName: 'FinPlan__SMS_Message__c', recordIds: recordIds);
    if(debug) log.d('Response for handleApproveSMS ${response.toString()}');

    setState(() {

      // Reset the flag when the approval process is completed
      isApproving = false;

      for (int i = 0; i < selectedRows.length; i++) {
        if (selectedRows[i]) {
          if(debug) log.d('i=>$i AND selectedRows[i]=>${selectedRows[i]}');
          widget.tableData.removeAt(i);
          selectedRows.removeAt(i);
        }
      }
    });
  }
}
