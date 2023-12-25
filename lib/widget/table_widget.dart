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
  
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool bigdebug = bool.parse(dotenv.env['bigdebug'] ?? 'false');

  String approveButtonName = 'Approve';
  bool isApproving = false; // Flag to track whether the approval process is ongoing
  bool isLoading = false; // Flag to track whether the approval process is ongoing

  @override
  void initState() {

    super.initState();

    if(widget.tabIndex == 0 || widget.tabIndex == 1){ 
      onLoadDefaultDescendingColumnId = 2;  // By default, on load the table will be sorted by col 2 (i.e. date)
    }
    else{
      onLoadDefaultDescendingColumnId = 0;  // However for third tab (bank account details) sorting will be on col 0 i.e. Name
    }

    selectedRows = List.generate(widget.tableData.length, (index) => false);
    _sortIcons = List.generate(widget.columnNames.length, (colIndex) {
      if (colIndex == 2) {  // This index = 2 means the third column i.e. the `date` column
        _sortAscending = false; // Set the default sort order for the date column to descending
        return Icons.arrow_upward; // Set the default sorting icon for the third column
      } 
      else {
        return null;
      }
    });
    // Sort the data by the third column (date) in descending order initially
    _sortColumn(onLoadDefaultDescendingColumnId);
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
                                  _sortColumn(index);
                                },
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
                            onSort: (columnIndex, ascending) {
                              _sortColumn(columnIndex);
                              setState(() {});
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

  // The private `_sort` method
  void _sortColumn(int columnIndex) {
    setState(() {

      // Show the spinner till the sorting is completed
      isApproving = true;
      
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
      
      int NAME_COLUMN_ID = 0;
      int AMOUNT_COLUMN_ID = 1;
      int DATE_COLUMN_ID = 2;
      
      widget.tableData.sort((a, b) {
        int result = 0;
        if (columnIndex == NAME_COLUMN_ID) {
          result = _compareStrings(a[columnIndex], b[columnIndex]);
        } 
        else if (columnIndex == AMOUNT_COLUMN_ID) {
          result = _compareNumeric(a[columnIndex], b[columnIndex]);
        } 
        else if (columnIndex == DATE_COLUMN_ID) {
          result = _compareDates(a[columnIndex], b[columnIndex]);
        }

        // If the first column comparison is equal, use another column for sorting. See the default order below
        if (result == 0) {
          if (columnIndex == NAME_COLUMN_ID) { 
              result = _compareDates(a[DATE_COLUMN_ID], b[DATE_COLUMN_ID]); // If still `amounts` are same finally sort by `date`
            if(result == 0){      
              result = _compareNumeric(a[AMOUNT_COLUMN_ID], b[AMOUNT_COLUMN_ID]);   // If `names` are same sort by `amount`
            }
          } else if (columnIndex == AMOUNT_COLUMN_ID) {
            result = _compareStrings(a[NAME_COLUMN_ID], b[NAME_COLUMN_ID]); // If `amounts` are same sort by `name`
            if(result == 0){
              result = _compareDates(a[DATE_COLUMN_ID], b[DATE_COLUMN_ID]); // If still `names` are same sort by `date`
            }
          } else if (columnIndex == DATE_COLUMN_ID) {
            result = _compareStrings(a[NAME_COLUMN_ID], b[NAME_COLUMN_ID]); // If dates are same sort by names
            if(result == 0){
              result = _compareNumeric(a[AMOUNT_COLUMN_ID], b[AMOUNT_COLUMN_ID]); // If still names are same finally sort by amount
            }
          }
        }

        return _sortAscending ? result : -result; // Invert result for descending order
      });

      // stop the spinner because the sorting is completed
      isApproving = false;      
    });
  }

  // Helper method to compare strings case insensitive
  int _compareStrings(String a, String b) {
    a = a.toUpperCase();
    b = b.toUpperCase();
    return _sortAscending ? a.compareTo(b) : b.compareTo(a);
  }

  // Helper method to compare numeric values, removing unncessary spaces, commas and currency symbol
  int _compareNumeric(String a, String b) {
    a = a.replaceAll(',', '').replaceAll('INR', '').replaceAll(' ', '');
    b = b.replaceAll(',', '').replaceAll('INR', '').replaceAll(' ', '');
    double aValue = double.parse(a);
    double bValue = double.parse(b);
    return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
  }

  // Helper method to compare date values
  int _compareDates(String aDateValue, String bDateValue) {
    
    if(bigdebug) log.d('Tabindex is => ${widget.tabIndex}');

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

    List<String> recordIds = [];

    for (int i = 0; i < selectedRows.length; i++) {
      if (selectedRows[i]) {
        recordIds.add(widget.tableData[i][3]);
      }
    }

    dynamic response = await DataGenerator.approveSelectedMessages(objAPIName: 'FinPlan__SMS_Message__c', recordIds: recordIds);
    
    if(debug) log.d('Response for handleApproveSMS ${response.toString()}');

    setState(() {

      // Reset the flag when the approval process is completed
      isApproving = false;

      for (int i = 0; i < selectedRows.length; i++) {
        if (selectedRows[i]) {
          widget.tableData.removeAt(i);
          selectedRows.removeAt(i);
        }
      }
    });
  }
}
