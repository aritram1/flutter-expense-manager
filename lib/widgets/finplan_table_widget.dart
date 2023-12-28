import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FinPlanTableWidget extends StatefulWidget {
  final List<String> headerNames;
  final List<Map<String, dynamic>> data;
  final Function(String) onLoadComplete;
  final String noRecordFoundMessage;
  final String caller;
  final List<double> columnWidths;
  final String defaultSortcolumnName;

  const FinPlanTableWidget({
    Key? key,
    required this.headerNames,
    required this.data,
    required this.onLoadComplete,
    this.noRecordFoundMessage = 'Default Message for no records!',
    required this.caller,
    required this.columnWidths, // Add this line
    required this.defaultSortcolumnName,
  }) : super(key: key);

  @override
  _FinPlanTableWidgetState createState() => _FinPlanTableWidgetState();
}

class _FinPlanTableWidgetState extends State<FinPlanTableWidget> {
  late List<Map<String, dynamic>> tableData;
  late Set<int> selectedRows;
  final Logger log = Logger();
  bool isLoading = false;

  bool debug = true;
  bool detaildebug = true;

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

    // Initialize tableData based on whether widget.data is empty or not
    tableData = widget.data.isNotEmpty ? widget.data : [];

    // Initialize selectedRows list
    selectedRows = {}; //List.generate(widget.data.length, (index) => false);

    _sortIcons = List.generate(widget.headerNames.length, (colIndex) {
      if (widget.headerNames[colIndex] == widget.defaultSortcolumnName) {  // Set default sorting based on the passed column
        _sortAscending = false;
        return Icons.arrow_upward;
      } 
      else {
        // no specific rule for other columns
        return null;
      }
    });


    // Notify onLoadComplete based on the initialization result
    widget.onLoadComplete(
        tableData.isNotEmpty ? 'SUCCESS' : 'Error: Empty data sent to table');
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
      ],
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
      final rowIndex = entry.key;
      final row = entry.value;

      return DataRow(
        selected: selectedRows.contains(rowIndex), // Updated line
        onSelectChanged: (selected) {
          handleRowSelection(selected, rowIndex);
        },
        cells: List.generate(widget.headerNames.length, (index) {
          return DataCell(
            SizedBox(
              width: MediaQuery.of(context).size.width * widget.columnWidths[index], // Use provided column width
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child : Text(getFormattedCellData(widget.headerNames[index], row), maxLines: 2,)
                // child: Text(
                //   (widget.headerNames[index] == 'Date')
                //       ? row[widget.headerNames[index]].toString().substring(0, 10)
                //       : (widget.headerNames[index] == 'Amount')
                //           ? NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(double.parse(row[widget.headerNames[index]].toString()))
                //           : row[widget.headerNames[index]].toString(),
                //   maxLines: 2,
                // ),
              ),
            ),
          );
        }),
      );
    }).toList();
  }

  void _onSort(int columnIndex, bool ascending) {
    // Implement sorting logic based on columnIndex and ascending
    setState(() {
      // Sort the tableData accordingly
      tableData.sort((a, b) {
        // Assuming data in each cell is of type String
        String aValue = a[widget.headerNames[columnIndex]].toString();
        String bValue = b[widget.headerNames[columnIndex]].toString();

        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  void sortColumn(int colIndex) async {
    setState(() {
      // Show the spinner till the sorting is completed
      isLoading = true;
    });

    // await _sortColumn(colIndex);

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

      log.d('a => ${a}');
      log.d('b => ${b}');
      String columnName = widget.headerNames[sortColumnIndex];
      log.d('a => ${a[columnName]}');//I am here sortColumnIndex => $sortColumnIndex $_sortAscending');
      log.d('b => ${b[columnName]}');//log.d('I am here sortColumnIndex => $sortColumnIndex $_sortAscending');
      
      if (columnIndex == constNameColumnId) { // constNameColumnId = 0;
        result = compareStrings(a[columnName], b[columnName]);
      }
      else if (columnIndex == constAmountColumnId) {  // constAmountColumnId = 1;
        result = compareNumeric(a[columnName], b[columnName]);
      }
      else if (columnIndex == constDateColumnId) {  // constDateColumnId = 2
        result = compareDates(a[columnName], b[columnName]);
      }
      log.d('Interim result : $result');

      // Second layer sorting will be implemented later
      // TBD
      // Urgent
      // If the first column comparison is equal, use another column for sorting. See the default order below
      // if (result == 0) {
      //   if (columnIndex == constNameColumnId) {
      //     result = compareDates(a[constDateColumnId],
      //         b[constDateColumnId]); // If still `amounts` are same finally sort by `date`
      //     if (result == 0) {
      //       result = compareNumeric(a[constAmountColumnId],
      //           b[constAmountColumnId]); // If `names` are same sort by `amount`
      //     }
      //   } else if (columnIndex == constAmountColumnId) {
      //     result = compareStrings(a[constNameColumnId],
      //         b[constNameColumnId]); // If `amounts` are same sort by `name`
      //     if (result == 0) {
      //       result = compareDates(a[constDateColumnId],
      //           b[constDateColumnId]); // If still `names` are same sort by `date`
      //     }
      //   } else if (columnIndex == constDateColumnId) {
      //     result = compareStrings(a[constNameColumnId],
      //         b[constNameColumnId]); // If dates are same sort by names
      //     if (result == 0) {
      //       result = compareNumeric(a[constAmountColumnId],
      //           b[constAmountColumnId]); // If still names are same finally sort by amount
      //     }
      //   }
      // }
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
      String message = widget.noRecordFoundMessage;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.noRecordFoundMessage,
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void handleRowSelection(bool? selected, int rowIndex) {
    setState(() {
      if (selected != null) {
        if (selected) {
          selectedRows.add(rowIndex);
        } else {
          selectedRows.remove(rowIndex);
        }
      }
    });
  }


  String getFormattedCellData(String columnName, dynamic row){
    String formattedCellData = '';
    if(columnName == 'Date'){
      String yyyymmdd = row[columnName].toString().substring(0, 10);
      String yy = yyyymmdd.split('-')[0].substring(2,4);
      String mm = yyyymmdd.split('-')[1];
      String dd = yyyymmdd.split('-')[2];
      formattedCellData = '$dd/$mm/$yy';
    }
    else if (columnName == 'Amount'){
      formattedCellData = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(double.parse(row[columnName].toString()));
    }
    else{
      formattedCellData = row[columnName].toString();
    }
    return formattedCellData;
  }

}