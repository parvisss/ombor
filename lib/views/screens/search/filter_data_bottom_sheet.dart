import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ombor/utils/app_colors.dart';

// ignore: must_be_immutable
class FilterDateBottomSheet extends StatefulWidget {
  ValueNotifier<DateTime?> startDate;
  ValueNotifier<DateTime?> endDate;
  void Function(DateTime?) onStartDateSelected;
  void Function(DateTime?) onEndDateSelected;
  VoidCallback? onFilter;
  ValueNotifier<bool?>? isIncludeInstallment;
  ValueNotifier<bool?>? isIncludeIncome;
  ValueNotifier<bool?>? isIncludeExpence;
  void Function(bool?)? onInstallmentChangedSelected;
  void Function(bool?)? onExpenceChangedSelected;
  void Function(bool?)? onIncomeChangedSelected;
  FilterDateBottomSheet({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onFilter,
    this.isIncludeExpence,
    this.isIncludeIncome,
    this.isIncludeInstallment,
    this.onExpenceChangedSelected,
    this.onIncomeChangedSelected,
    this.onInstallmentChangedSelected,
  });

  @override
  State<FilterDateBottomSheet> createState() => _FilterDateBottomSheetState();
}

class _FilterDateBottomSheetState extends State<FilterDateBottomSheet> {
  bool? _includeInstallment;
  bool? _includeIncome;
  bool? _includeExpence;

  @override
  void initState() {
    super.initState();
    _includeInstallment = widget.isIncludeInstallment?.value;
    _includeIncome = widget.isIncludeIncome?.value;
    _includeExpence = widget.isIncludeExpence?.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 350, // Increased height to accommodate switches
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
              'Filtrlash',
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
          SizedBox(height: 16.0),

          // Installment Filter
          if (widget.isIncludeInstallment != null)
            _buildFilterSwitch(
              title: 'credit'.tr(context: context),
              value: _includeInstallment,
              onChanged: (bool? value) {
                setState(() {
                  _includeInstallment = value;
                  widget.isIncludeInstallment?.value = value;
                });
              },
            ),
          // Income Filter
          if (widget.isIncludeIncome != null)
            _buildFilterSwitch(
              title: 'Kirim',
              value: _includeIncome,
              onChanged: (bool? value) {
                setState(() {
                  _includeIncome = value;
                  widget.isIncludeIncome?.value = value;
                });
              },
            ),
          // Expense Filter
          if (widget.isIncludeExpence != null)
            _buildFilterSwitch(
              title: 'Chiqim',
              value: _includeExpence,
              onChanged: (bool? value) {
                setState(() {
                  _includeExpence = value;
                  widget.isIncludeExpence?.value = value;
                });
              },
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
        return GestureDetector(
          onTap: onPressed,
          child: Container(
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
      _includeInstallment = null; // Ichki holatni null qilish
      if (widget.isIncludeInstallment != null) {
        widget.isIncludeInstallment!.value = true;
      }
      _includeIncome = null; // Ichki holatni null qilish
      if (widget.isIncludeIncome != null) {
        widget.isIncludeIncome!.value = true;
      }
      _includeExpence = null; // Ichki holatni null qilish
      if (widget.isIncludeExpence != null) {
        widget.isIncludeExpence!.value = true;
      }
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

  // Helper function to build the filter switch
  Widget _buildFilterSwitch({
    required String title,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16.0)),
          CupertinoSwitch(
            value: value ?? false,
            onChanged: onChanged,
            activeTrackColor: AppColors.mainColor,
          ),
        ],
      ),
    );
  }
}
