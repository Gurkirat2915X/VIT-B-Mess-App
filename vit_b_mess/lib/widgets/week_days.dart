import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeekDays extends ConsumerWidget {
  const WeekDays({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });
  final int selectedDay;
  final void Function(int) onDaySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      child: SegmentedButton<int>(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          // padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0)),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        segments:
            List.generate(7, (index) => index).map((day) {
              return ButtonSegment<int>(
                value: day,
                label: Text(
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day],
                ),
              );
            }).toList(),
        selected: {selectedDay},
        showSelectedIcon: false,
        onSelectionChanged: (Set<int> newSelection) {
          if (newSelection.isNotEmpty) {
            print("Selected day: ${newSelection.first}");
            onDaySelected(newSelection.first);
          }
        },
      ),
    );
  }
}
