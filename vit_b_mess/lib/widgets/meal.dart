import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_b_mess/models/meals.dart';
import 'package:vit_b_mess/provider/settings.dart';

class MealWidget extends ConsumerWidget {
  const MealWidget({super.key, required this.currentMeal});
  final Meal currentMeal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight:
              MediaQuery.of(context).size.height *
              0.4, // Set your desired max height here
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Makes column wrap to content
                children: [
                  // Veg Section
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        // Prevents text overflow
                        child: Text(
                          "Vegetarian",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing:
                        8, // Adds vertical spacing between wrapped lines
                    children:
                        currentMeal.veg
                            .map(
                              (item) => Chip(
                                label: Text(item),
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                              ),
                            )
                            .toList(),
                  ),

                  // Non-Veg Section
                  if (!ref.read(settingsNotifier).onlyVeg &&
                      currentMeal.nonVeg.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.set_meal, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          // Prevents text overflow
                          child: Text(
                            "Non-Vegetarian",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing:
                          8, // Adds vertical spacing between wrapped lines
                      children:
                          currentMeal.nonVeg
                              .map(
                                (item) => Chip(
                                  label: Text(item),
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
