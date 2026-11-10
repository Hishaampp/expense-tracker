import 'package:expense_tracker/theme/category_colors.dart';
import 'package:flutter/material.dart';

/// The glyph and tile colour for a stored icon key. Unknown keys get a
/// neutral pair, so a category added later still renders.
({IconData icon, Color color}) categoryStyle(
  BuildContext context,
  String? iconKey,
) {
  final c = CategoryColors.of(context);
  return switch (iconKey) {
    'food' => (icon: Icons.restaurant_rounded, color: c.orange),
    'groceries' => (icon: Icons.local_grocery_store_rounded, color: c.green),
    'transport' => (icon: Icons.directions_bus_rounded, color: c.blue),
    'fuel' => (icon: Icons.local_gas_station_rounded, color: c.red),
    'shopping' => (icon: Icons.shopping_bag_rounded, color: c.purple),
    'bills' => (icon: Icons.receipt_long_rounded, color: c.amber),
    'mobile' => (icon: Icons.smartphone_rounded, color: c.teal),
    'rent' => (icon: Icons.home_rounded, color: c.violet),
    'emi' => (icon: Icons.account_balance_rounded, color: c.blue),
    'health' => (icon: Icons.favorite_rounded, color: c.red),
    'education' => (icon: Icons.school_rounded, color: c.violet),
    'entertainment' => (icon: Icons.movie_rounded, color: c.pink),
    'personal' => (icon: Icons.spa_rounded, color: c.teal),
    'gifts' => (icon: Icons.card_giftcard_rounded, color: c.pink),
    'family' => (icon: Icons.family_restroom_rounded, color: c.orange),
    'travel' => (icon: Icons.flight_rounded, color: c.blue),
    'fees' => (icon: Icons.percent_rounded, color: c.grey),
    'transfer' => (icon: Icons.swap_horiz_rounded, color: c.grey),
    'salary' => (icon: Icons.work_rounded, color: c.green),
    'refund' => (icon: Icons.undo_rounded, color: c.green),
    'income' => (icon: Icons.south_west_rounded, color: c.green),
    'more' => (icon: Icons.more_horiz_rounded, color: c.grey),
    _ => (icon: Icons.category_rounded, color: c.grey),
  };
}
