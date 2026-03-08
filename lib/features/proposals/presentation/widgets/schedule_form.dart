import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleForm extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int durationMinutes;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final ValueChanged<int> onDurationChanged;

  const ScheduleForm({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.durationMinutes,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proposed Schedule',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Date Picker
        const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDateInvalid(context) ? Colors.red : Colors.grey,
                width: _isDateInvalid(context) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('EEEE, MMMM d, y').format(selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        if (_isDateInvalid(context))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _getDateValidationMessage(context),
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 16),

        // Time Picker
        const Text('Time', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isTimeInvalid(context) ? Colors.red : Colors.grey,
                width: _isTimeInvalid(context) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Select time',
                    style: TextStyle(
                      color: selectedTime != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
        ),
        if (_isTimeInvalid(context))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _getTimeValidationMessage(context),
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 16),

        // Duration
        const Text(
          'Duration (minutes)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: durationMinutes,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: durationMinutes < 15 ? Colors.red : Colors.grey,
                width: durationMinutes < 15 ? 2 : 1,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: [15, 30, 45, 60, 90, 120].map((duration) {
            return DropdownMenuItem(
              value: duration,
              child: Text('$duration minutes'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onDurationChanged(value);
          },
        ),
        if (durationMinutes < 15)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Duration must be at least 15 minutes',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  bool _isDateInvalid(BuildContext context) {
    if (selectedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    // Check if date is before today
    if (selectedDay.isBefore(today)) return true;

    // Check if date is more than 1 year in the future
    final maxDate = today.add(const Duration(days: 365));
    if (selectedDay.isAfter(maxDate)) return true;

    return false;
  }

  String _getDateValidationMessage(BuildContext context) {
    if (selectedDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    if (selectedDay.isBefore(today)) {
      return 'Date cannot be in the past';
    }

    final maxDate = today.add(const Duration(days: 365));
    if (selectedDay.isAfter(maxDate)) {
      return 'Date cannot be more than 1 year in the future';
    }

    return '';
  }

  bool _isTimeInvalid(BuildContext context) {
    if (selectedDate == null || selectedTime == null) return false;

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    // Check if selected date/time is in the past (within 1 hour buffer)
    final bufferTime = now.add(const Duration(hours: 1));
    return selectedDateTime.isBefore(bufferTime);
  }

  String _getTimeValidationMessage(BuildContext context) {
    if (selectedDate == null || selectedTime == null) return '';

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      return 'Time cannot be in the past';
    }

    final bufferTime = now.add(const Duration(hours: 1));
    if (selectedDateTime.isBefore(bufferTime)) {
      return 'Please select a time at least 1 hour from now';
    }

    return '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }
}
