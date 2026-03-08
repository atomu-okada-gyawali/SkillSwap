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
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
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

        const SizedBox(height: 16),

        // Time Picker
        const Text('Time', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
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

        const SizedBox(height: 16),

        // Duration
        const Text(
          'Duration (minutes)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: durationMinutes,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
      ],
    );
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
