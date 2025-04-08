import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:ombor/utils/app_colors.dart';

class FilterDateBottomSheet extends StatefulWidget {
  final ValueNotifier<DateTime?> startDate;
  final ValueNotifier<DateTime?> endDate;
  final void Function(DateTime?) onStartDateSelected;
  final void Function(DateTime?) onEndDateSelected;
  final VoidCallback? onFilter;
  const FilterDateBottomSheet({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onFilter,
  });

  @override
  State<FilterDateBottomSheet> createState() => _FilterDateBottomSheetState();
}

class _FilterDateBottomSheetState extends State<FilterDateBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          Center(
            child: Text(
              'Sana oralig\'ini tanlang',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16.0),

          // Date pickers with "до" (To) separator
          _buildDatePickerRow(
            startLabel: 'From',
            startDate: widget.startDate,
            endLabel: 'To',
            endDate: widget.endDate,
            onStartPressed: _selectStartDate,
            onEndPressed: _selectEndDate,
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Clear Filters Button
              _buildActionButton(
                label: 'Tozalash',
                onPressed: _clearFilters,
                color: AppColors.secondaryColor,
              ),
              // Apply Filters Button
              _buildActionButton(
                label: 'Filtrni qo\'llash',
                onPressed: widget.onFilter ?? () {},
                color: AppColors.mainColor,
              ),
            ],
          ),
          SizedBox(height: 30.0),
        ],
      ),
    );
  }

  // Custom Row for From and To Date Pickers with "до" separator
  Widget _buildDatePickerRow({
    required String startLabel,
    required ValueNotifier<DateTime?> startDate,
    required String endLabel,
    required ValueNotifier<DateTime?> endDate,
    required VoidCallback onStartPressed,
    required VoidCallback onEndPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // From Date Picker
        _buildDatePickerButton(
          label: startLabel,
          date: startDate,
          onPressed: onStartPressed,
        ),
        // "до" separator
        Text(
          'до', // "To" in Russian
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        // To Date Picker
        _buildDatePickerButton(
          label: endLabel,
          date: endDate,
          onPressed: onEndPressed,
        ),
      ],
    );
  }

  // Custom Date Picker button
  Widget _buildDatePickerButton({
    required String label,
    required ValueNotifier<DateTime?> date,
    required VoidCallback onPressed,
  }) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: date,
      builder: (context, currentDate, _) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 20.0,
          ), // Custom padding
          decoration: BoxDecoration(
            color: AppColors.buttonColor, // Button color
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          child: Material(
            color: Colors.transparent, // Transparent material to catch tap
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12.0), // Rounded tap area
              child: Center(
                child: Text(
                  currentDate == null
                      ? label
                      : DateFormat('yyyy-MM-dd').format(currentDate),
                  style: TextStyle(
                    color: AppColors.black, // Text color
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    await _showCupertinoDatePicker(
      context: context,
      initialDate: widget.startDate.value ?? DateTime.now(),
      onDateSelected: (pickedDate) {
        widget.onStartDateSelected(pickedDate);
      },
    );
  }

  // End date tanlash (using Cupertino style date picker)
  Future<void> _selectEndDate() async {
    await _showCupertinoDatePicker(
      context: context,
      initialDate: widget.endDate.value ?? DateTime.now(),
      onDateSelected: (pickedDate) {
        widget.onEndDateSelected(pickedDate);
      },
    );
  }

  // Cupertino Date Picker Popup
  Future<void> _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required Function(DateTime?) onDateSelected,
  }) async {
    DateTime? selectedDate =
        initialDate; // Temp variable to store selected date

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            SizedBox(
              height: 200.0,
              child: CupertinoDatePicker(
                initialDateTime: initialDate,
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2101),
                onDateTimeChanged: (newDate) {
                  selectedDate = newDate; // Update selected date
                },
                mode: CupertinoDatePickerMode.date,
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                if (selectedDate != null) {
                  onDateSelected(selectedDate); // Save the selected date
                }
                Navigator.pop(context); // Close the popup
              },
              child: Text('ок'), // Save button text
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context); // Close the popup
            },
            child: Text('назад'), // Cancel button text
          ),
        );
      },
    );
  }

  // Clear filters
  void _clearFilters() {
    setState(() {
      widget.startDate.value = null;
      widget.endDate.value = null;
    });
  }

  // Helper function to create action buttons
  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 30,
        height: 60,
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
