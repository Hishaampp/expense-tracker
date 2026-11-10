import 'package:flutter/material.dart';

/// The glyph for a stored category icon key. Unknown keys get a neutral
/// glyph, so a category added later still renders.
IconData categoryIcon(String? iconKey) => switch (iconKey) {
  'food' => Icons.restaurant,
  'groceries' => Icons.local_grocery_store_outlined,
  'transport' => Icons.directions_bus_outlined,
  'fuel' => Icons.local_gas_station_outlined,
  'shopping' => Icons.shopping_bag_outlined,
  'bills' => Icons.receipt_long_outlined,
  'mobile' => Icons.smartphone,
  'rent' => Icons.home_outlined,
  'emi' => Icons.account_balance_outlined,
  'health' => Icons.medical_services_outlined,
  'education' => Icons.school_outlined,
  'entertainment' => Icons.movie_outlined,
  'personal' => Icons.spa_outlined,
  'gifts' => Icons.card_giftcard,
  'family' => Icons.family_restroom,
  'travel' => Icons.flight,
  'fees' => Icons.percent,
  'transfer' => Icons.swap_horiz,
  'salary' => Icons.work_outline,
  'refund' => Icons.undo,
  'income' => Icons.south_west,
  'other' => Icons.category_outlined,
  _ => Icons.help_outline,
};
