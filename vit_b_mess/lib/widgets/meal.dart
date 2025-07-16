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
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          minHeight: MediaQuery.of(context).size.height * 0.4,
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),

        child: Card(
          elevation: 6,
          shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Content
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSectionHeader(
                            context,
                            "Vegetarian",
                            Icons.eco_rounded,
                            Colors.green.shade700,
                            Colors.green.withOpacity(0.1),
                          ),
                          const SizedBox(height: 8),
                          currentMeal.veg.isEmpty
                              ? _buildEmptyState(
                                context,
                                "No vegetarian items available today",
                              )
                              : _buildItemsGrid(
                                context,
                                currentMeal.veg,
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),

                          // Non-Veg Section
                          if (!ref.read(settingsNotifier).onlyVeg &&
                              currentMeal.nonVeg.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _buildSectionHeader(
                              context,
                              "Non-Vegetarian",
                              Icons.set_meal_rounded,
                              Colors.red.shade700,
                              Colors.red.withOpacity(0.1),
                            ),
                            const SizedBox(height: 10),
                            _buildItemsGrid(
                              context,
                              currentMeal.nonVeg,
                              Theme.of(context).colorScheme.errorContainer,
                              Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: iconColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildItemsGrid(
    BuildContext context,
    List<String> items,
    Color backgroundColor,
    Color textColor,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    // Optionally show more details about the item
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Selected: $item')));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
