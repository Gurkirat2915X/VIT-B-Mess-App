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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
   // Adjust height as needed
      width: double.infinity,
      child: SegmentedButton<int>(
        direction: Axis.horizontal,
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primaryContainer.withOpacity(0.5);
              }
              return theme.cardColor;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primary;
              }
              return colorScheme.onSurface.withOpacity(0.7);
            },
          ),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        segments: List.generate(7, (index) => index).map((day) {
          return ButtonSegment<int>(
            value: day,
            label: Text(
              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day],
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily,
                color: selectedDay == day
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          );
        }).toList(),
        selected: {selectedDay},
        showSelectedIcon: false,
        onSelectionChanged: (Set<int> newSelection) {
          if (newSelection.isNotEmpty) {
            onDaySelected(newSelection.first);
          }
        },
      ),
    );
  }
}
