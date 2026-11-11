/// A small bundled keyword list (spec §8, step 2): a payee's UPI id or name
/// containing one of these words suggests a category. Suggestions only; the
/// user confirms in the review inbox.
const Map<String, String> _keywordCategory = {
  'swiggy': 'cat_food',
  'zomato': 'cat_food',
  'dominos': 'cat_food',
  'blinkit': 'cat_groceries',
  'zepto': 'cat_groceries',
  'bigbasket': 'cat_groceries',
  'instamart': 'cat_groceries',
  'dmart': 'cat_groceries',
  'amazon': 'cat_shopping',
  'flipkart': 'cat_shopping',
  'myntra': 'cat_shopping',
  'ajio': 'cat_shopping',
  'meesho': 'cat_shopping',
  'uber': 'cat_transport',
  'olacabs': 'cat_transport',
  'rapido': 'cat_transport',
  'irctc': 'cat_travel',
  'makemytrip': 'cat_travel',
  'goibibo': 'cat_travel',
  'jio': 'cat_mobile',
  'airtel': 'cat_mobile',
  'vodafone': 'cat_mobile',
  'bookmyshow': 'cat_entertainment',
  'netflix': 'cat_entertainment',
  'spotify': 'cat_entertainment',
  'hotstar': 'cat_entertainment',
  'iocl': 'cat_fuel',
  'indianoil': 'cat_fuel',
  'hpcl': 'cat_fuel',
  'bpcl': 'cat_fuel',
  'petrol': 'cat_fuel',
  'apollo': 'cat_health',
  'pharmeasy': 'cat_health',
  'netmeds': 'cat_health',
};

/// The category suggested for a payee, or null. Matches whole words of the
/// UPI id's name part and the payee name, so "jio" does not match "rajiorder".
String? suggestCategory({String? payeeKey, String? payeeName}) {
  final text = [
    (payeeKey ?? '').replaceFirst('name:', '').split('@').first,
    payeeName ?? '',
  ].join(' ').toLowerCase();
  final words = text.split(RegExp('[^a-z]+')).where((w) => w.isNotEmpty);
  for (final word in words) {
    final hit = _keywordCategory[word];
    if (hit != null) return hit;
  }
  // Joined forms such as "swiggyinstamart" or "amazonpay".
  for (final entry in _keywordCategory.entries) {
    if (entry.key.length >= 5 && text.contains(entry.key)) return entry.value;
  }
  return null;
}
