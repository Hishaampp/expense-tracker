# Design direction: Warm cards

Chosen by the owner on 2026-11-10, replacing the first direction
("Passbook"), which they found too dense. The owner supplied screenshots of a
polished app as a reference for feel; this direction takes its qualities, not
its identity (own accent colour, own content, own wording).

This file and `lib/theme/` decide look and feel. The spec decides what a
screen shows.

## The idea

Calm, premium and easy to scan. Each screen shows a few things, with plenty
of space between them:

- a **big bold title** opens every tab;
- **one dark hero card** says the key number as a sentence ("You've spent
  ₹18,420 this month.");
- everything else sits on **white cards with large rounded corners**, with
  space between cards instead of lines;
- **small colourful square tiles** mark categories and settings;
- a **floating round +** and a **floating pill tab bar** float above the
  content;
- **motion** makes changes feel smooth and shows what changed.

## Colour

Widgets read the role (`AppColors`, `CategoryColors`), never the hex. Hex
values live only in `lib/theme/primitives.dart`.

| Role | Used for | Light | Dark |
|---|---|---|---|
| `background` | Page background | `#F6F1EA` | `#0F0E0D` |
| `surface` | Cards, sheets, tab bar | `#FFFFFF` | `#1C1A18` |
| `surfaceSunken` | Pills, selected tab, keys | `#EFE9E2` | `#2A2724` |
| `onSurface` | Text, icons, spent amounts | `#141414` | `#F4F1EC` |
| `onSurfaceMuted` | Supporting text, transfers | `#6B655F` | `#A8A19A` |
| `accent` | Icons, progress, the + glyph (not text) | `#E2600F` | `#FF8A3D` |
| `accentFill` | Primary button fill | `#C8500A` | `#FF8A3D` |
| `onAccentFill` | Text on `accentFill` | `#FFFFFF` | `#1A0E05` |
| `accentText` | Accent-coloured text | `#AD4806` | `#FF9A55` |
| `hero` | The dark summary card | `#141414` | `#262320` |
| `onHero` / `onHeroMuted` | Text on the hero | `#FFFFFF` / `#A8A29C` | `#FFFFFF` / `#B3ADA6` |
| `moneyIn` | Money received | `#1A7742` | `#5BD38F` |
| `moneyInOnHero` | Money received, on the hero | `#5BD38F` | `#5BD38F` |
| `danger` | Over budget, delete | `#C93439` | `#FF7B7F` |
| `review` / `reviewContainer` | Needs review | `#7A4F00` / `#FCEBC5` | `#F5D58A` / `#3A2E0F` |

The accent is split in three because one orange cannot be vivid and also
carry readable text: `accent` is for shapes, `accentFill` for buttons with
white text, `accentText` for words. Every text pair meets WCAG AA (4.5:1) in
both themes; `test/theme/app_colors_test.dart` checks this.

Category tiles (`CategoryColors`) are orange, green, blue, red, purple,
amber, violet, teal, pink and grey, each holding a white glyph at 3:1 or
better.

## Money states

No state relies on colour alone. Each has a sign, an icon or a label as well.

| State | Sign | Icon | Label | Colour |
|---|---|---|---|---|
| Spent | none | category tile | category name | `onSurface` |
| Money in | `+` before the amount | down-left arrow | "Money in" | `moneyIn` |
| Transfer | none | two arrows | "Transfer" | `onSurfaceMuted` |
| Needs review | none | question mark | "Review needed" | `review` |
| Over budget | none | warning triangle | "Over by ₹X" | `danger` |

A screen reader hears the full meaning, for example "₹340 spent, Swiggy,
Food", never the bare digits.

## Type

Anek Latin, bundled as one variable font file (`assets/fonts/`, SIL Open Font
License). It has the ₹ sign, and amounts use its equal-width digits so they
line up and do not jitter while counting.

| Style | Size | Weight | Used for |
|---|---|---|---|
| `headlineMedium` | 34 | 700 | The large title that opens a tab |
| `headlineSmall` | 24 | 700 | Titles inside the hero card |
| `titleLarge` | 20 | 700 | Empty-state titles |
| `titleMedium` | 17 | 700 | Card titles, app bar |
| `bodyLarge` | 16 | 500 | Row titles |
| `bodyMedium` | 15 | 400 | Body text |
| `bodySmall` | 13 | 400 | Supporting lines (muted) |
| `labelLarge` | 16 | 600 | Buttons |
| `labelMedium` / `labelSmall` | 13 / 11 | 600 | Pills, tab labels |
| `amountDisplay` | 56 | 700 | The amount typed in Quick Add |
| `heroSentence` | 20 | 500 | The hero card's sentence |
| `statValue` | 19 | 700 | Numbers in the hero card |
| `amountRow` | 16 | 700 | The amount at the end of a row |

Text is never clamped: layouts work at the largest system text size.

## Shape, space and layout

- **Corners:** 24 on cards and sheets, 9 on small icon tiles, 16 on Quick Add
  tiles; buttons, pills and the tab bar are fully rounded.
- **Spacing:** a 4-point grid: 4, 8, 12, 16, 24, 32. Page gutter and card
  padding are 16; cards are 12 apart; a title has 24–32 above it.
- **Headings:** a card's own title (Top categories, Recent) sits inside the
  card; a heading that names a group of cards or a list section (a day in
  Activity, a settings group) sits just above it. Both are `titleMedium`.
- **Row-list cards** (Activity days, settings groups) use 16 side padding
  and 8 top and bottom, so rows sit close to the card edge.
- **Sheets** all use `SheetFrame` and open with `showAppSheet`.
- **No lines between cards.** A divider appears only between rows inside one
  card.
- **Elevation:** none on cards. Only the floating round buttons and the
  floating tab bar carry a soft shadow, because they float over content.
- **Tap targets:** at least 48.
- **Phones first.** On tablets and foldables (600 wide or more) content is
  capped at 560 and centred, and a side rail replaces the floating tab bar.

## Buttons

- **Filled pill** (`accentFill`): the screen's primary next step. At most one
  per screen.
- **Round floating button** (white, accent glyph): Add, top right.
- **Text button** (`accentText`): small links such as "See all".
- **Outlined (no border, white pill):** recovery actions such as Try again.

## Motion

Motion is smooth and purposeful: it shows what changed and never blocks. Every
moment is listed here with what it does when the phone asks for reduced
motion. Durations come from `AppMotion` through `resolveMotion`.

| Moment | Trigger | What moves | Duration | Haptic | Reduced motion |
|---|---|---|---|---|---|
| Press | finger down on a card, tile, key or button | scales to 0.97 | quick | none | no scale |
| Screen entrance | a tab's content first appears | cards fade in and rise 16, 55 ms apart | slow | none | appear at once |
| Count-up | an amount on the hero card changes | counts from the old value to the new | count-up | none | new value at once |
| Progress fill | a category bar appears or changes | grows to its length | slow | none | at full length |
| Tab switch | a tab is tapped | the selected pill slides; content fades in | medium | selection | instant |
| Keypad digit | a key is pressed | the amount slides up into place | quick | selection | instant |
| Reject | category tapped with no amount | the amount shakes sideways, hint shows | medium | reject | hint only |
| Save | category tapped with an amount | the tile pops; Quick Add slides away | quick, slow | commit | closes at once |
| Quick Add open/close | + tapped / closed | slides up / down with a fade | slow | none | appears at once |
| New row | a transaction appears in a list | fades in and rises | slow | none | appears at once |
| Loading | data not ready after a moment | placeholder blocks pulse | pulse | none | static blocks |

Rules: nothing loops except the loading pulse, which stops when the screen is
not visible; every animation can be interrupted; the end state is always
reachable with animations off; theme changes do not animate.

## Rules for code

- No raw colour, size, radius, duration or curve outside `lib/theme/`.
  `test/policy/no_raw_design_values_test.dart` fails the build if one appears.
  A new need is a new slot in the theme.
- Read slots with `AppColors.of`, `CategoryColors.of`, `AppMetrics.of`,
  `AppMotion.of` and `AppTextStyles.of`.
- The theme is built in one place: `buildAppTheme` in
  `lib/theme/app_theme.dart`.
- Shared building blocks live in `lib/widgets/`: `AppCard`, `HeroCard`,
  `IconTile`, `InfoRow`, `LargeTitlePage`, `RoundIconButton`, `Pressable`,
  `Entrance`, `CountUpMoney`, `GrowingBar`, `Shake`, `PulsingPlaceholder`,
  `EmptyStateView`, `ErrorStateView`.
