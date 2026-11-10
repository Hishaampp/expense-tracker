# Design direction: Passbook

Chosen by the owner on 2026-11-10 (spec section 11.1 A). This file and
`lib/theme/` decide look and feel. The spec decides what a screen shows.

## The idea

The app looks like a bank passbook: ruled rows, ink on paper, and amounts in a
straight right-hand column. It is calm, dense and quick to scan, because it is
opened many times a day.

The one memorable thing is the **amount column**. Amounts are right-aligned
with equal-width digits, so they line up from row to row. Everything around
the column stays quiet.

## Colour

Widgets read the role (`AppColors`), never the hex. Hex values live only in
`lib/theme/primitives.dart`.

| Role | Used for | Light | Dark |
|---|---|---|---|
| `surface` | Page background | `#F6F7F9` | `#0E1626` |
| `surfaceRaised` | Sheets, dialogs | `#FFFFFF` | `#17223A` |
| `onSurface` | Text, icons, spent amounts | `#16233F` | `#E6EBF5` |
| `onSurfaceMuted` | Supporting text, transfers | `#4A5674` | `#A9B4CC` |
| `hairline` | Row dividers | `#D9DEE8` | `#2C3A57` |
| `rule` | Heavy line that opens a ledger block | `#16233F` | `#E6EBF5` |
| `accent` | Primary actions, selection, budget bar | `#2747A0` | `#9DB4F5` |
| `onAccent` | Text on `accent` | `#FFFFFF` | `#0E1626` |
| `moneyIn` | Money received | `#1C7A52` | `#7BD3A8` |
| `danger` | Over budget, destructive actions | `#B3261E` | `#F2A29B` |
| `review` | "Needs review" text and icons | `#6B4700` | `#F5D58A` |
| `reviewContainer` | "Needs review" badge fill | `#FFF1CC` | `#3A2E0F` |
| `reviewOutline` | "Needs review" dashed outline | `#8A5A00` | `#D9B24C` |

Dark is authored by hand, not flipped from light. Every text pair in both
themes meets WCAG AA (4.5:1); `test/theme/app_colors_test.dart` checks this.

## Money states

No state relies on colour alone. Each has a sign, an icon or a label as well.

| State | Sign | Icon | Label | Colour |
|---|---|---|---|---|
| Spent | none | category icon | category name | `onSurface` |
| Money in | `+` before the amount | down-left arrow | "Money in" | `moneyIn` |
| Transfer | none | two arrows | "Transfer" | `onSurfaceMuted` |
| Needs review | none | question mark | "Review needed", dashed outline | `review` |
| Over budget | none | warning triangle | "Over by ₹X" | `danger` |

A screen reader hears the full meaning, for example "₹340 spent at Swiggy",
never the bare digits.

## Type

- **Family:** Anek Latin, bundled with the app as one variable font file
  (`assets/fonts/`, SIL Open Font License; no runtime font download). It has
  the ₹ sign, and its tabular digits are all the same width.
  Anek Devanagari and Anek Gurmukhi are added with Hindi and Punjabi.
- **Weights:** 400 for text, 500 for labels, 600 for totals and titles.
- **Amounts** use equal-width (tabular) digits and Indian grouping
  (`₹1,23,456.78`).

| Style | Size | Weight | Used for |
|---|---|---|---|
| `amountHero` | 40 | 600 | The one big number on a screen |
| `amountLarge` | 22 | 600 | Secondary totals |
| `amountRow` | 15 | 500 | Amount column in a row |
| `headlineMedium` | 24 | 600 | Screen headings |
| `titleLarge` | 20 | 600 | Empty-state titles |
| `titleMedium` | 16 | 500 | Section headings, app bar, month name |
| `bodyLarge` | 16 | 400 | Row titles (payee) |
| `bodyMedium` | 14 | 400 | Body text |
| `bodySmall` | 13 | 400 | Supporting line under a row title |
| `labelLarge` | 15 | 500 | Buttons |
| `labelMedium` | 13 | 500 | Chips, badges |

Text is never clamped: layouts must work at the largest system text size.

## Shape and density

- **Corners:** 6 on buttons, chips, badges and sheets.
- **Lists:** rows separated by a 1px hairline, not cards. A block of rows opens
  with a 2px rule.
- **Spacing:** a 4-point grid: 4, 8, 12, 16, 24. The page gutter is 16.
- **Tap targets:** at least 48 high, even when the row looks tighter.
- **Elevation:** none. Sheets and dialogs differ by `surfaceRaised`, not by a
  shadow.
- **Wide screens:** content is capped at 560 wide and centred.

## Buttons

- **Filled:** the screen's primary next step (Add expense, Save, an empty
  state's action). At most one per screen.
- **Outlined:** recovery actions, such as Try again on an error.
- **Text:** small secondary links, such as See all.

## Motion

- **Tone:** quick and flat, with no bounce and no ripple.
- **Durations:** 120ms for presses and the confirm "stamp"; 200ms for sheets
  and the budget bar.
- **Reduced motion:** when the phone asks for it, every animation becomes
  instant (`resolveMotion`). Motion is never the only sign that something
  changed.
- **Theme change:** light and dark switch without animation.

## Rules for code

- No raw colour, size, radius, duration or curve outside `lib/theme/`.
  `test/policy/no_raw_design_values_test.dart` fails the build if one appears.
  A new need is a new slot in the theme.
- Read slots with `AppColors.of(context)`, `AppMetrics.of(context)`,
  `AppMotion.of(context)` and `AppTextStyles.of(context)`.
- The theme is built in one place: `buildAppTheme` in
  `lib/theme/app_theme.dart`.
