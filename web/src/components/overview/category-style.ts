import {
  ArrowDownLeft,
  ArrowLeftRight,
  BriefcaseBusiness,
  Bus,
  Clapperboard,
  Ellipsis,
  Fuel,
  Gift,
  GraduationCap,
  Heart,
  House,
  Landmark,
  Percent,
  Plane,
  ReceiptText,
  Shapes,
  ShoppingBag,
  ShoppingBasket,
  Smartphone,
  Sparkles,
  Undo2,
  Users,
  Utensils,
  type LucideIcon,
} from "lucide-react";

type Style = { Icon: LucideIcon; color: string };

export type CategoryColorName = "orange" | "green" | "blue" | "red" | "purple" | "amber" | "violet" | "teal" | "pink" | "grey";

// The app's lib/widgets/category_style.dart, with Lucide's nearest glyphs.
const STYLES: Record<string, [LucideIcon, CategoryColorName]> = {
  food: [Utensils, "orange"],
  groceries: [ShoppingBasket, "green"],
  transport: [Bus, "blue"],
  fuel: [Fuel, "red"],
  shopping: [ShoppingBag, "purple"],
  bills: [ReceiptText, "amber"],
  mobile: [Smartphone, "teal"],
  rent: [House, "violet"],
  emi: [Landmark, "blue"],
  health: [Heart, "red"],
  education: [GraduationCap, "violet"],
  entertainment: [Clapperboard, "pink"],
  personal: [Sparkles, "teal"],
  gifts: [Gift, "pink"],
  family: [Users, "orange"],
  travel: [Plane, "blue"],
  fees: [Percent, "grey"],
  transfer: [ArrowLeftRight, "grey"],
  salary: [BriefcaseBusiness, "green"],
  refund: [Undo2, "green"],
  income: [ArrowDownLeft, "green"],
  more: [Ellipsis, "grey"],
};

/** The palette colour of a stored icon key (the PDF uses it too). */
export function categoryColorName(icon: string | null): CategoryColorName {
  return (icon && STYLES[icon]?.[1]) || "grey";
}

/** The glyph and tile colour for a stored icon key; unknown keys get a neutral pair. */
export function categoryStyle(icon: string | null): Style {
  const s = icon ? STYLES[icon] : undefined;
  return { Icon: s?.[0] ?? Shapes, color: `var(--cat-${s?.[1] ?? "grey"})` };
}
