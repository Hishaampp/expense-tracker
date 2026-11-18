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

const c = (name: string) => `var(--cat-${name})`;

// The app's lib/widgets/category_style.dart, with Lucide's nearest glyphs.
const STYLES: Record<string, Style> = {
  food: { Icon: Utensils, color: c("orange") },
  groceries: { Icon: ShoppingBasket, color: c("green") },
  transport: { Icon: Bus, color: c("blue") },
  fuel: { Icon: Fuel, color: c("red") },
  shopping: { Icon: ShoppingBag, color: c("purple") },
  bills: { Icon: ReceiptText, color: c("amber") },
  mobile: { Icon: Smartphone, color: c("teal") },
  rent: { Icon: House, color: c("violet") },
  emi: { Icon: Landmark, color: c("blue") },
  health: { Icon: Heart, color: c("red") },
  education: { Icon: GraduationCap, color: c("violet") },
  entertainment: { Icon: Clapperboard, color: c("pink") },
  personal: { Icon: Sparkles, color: c("teal") },
  gifts: { Icon: Gift, color: c("pink") },
  family: { Icon: Users, color: c("orange") },
  travel: { Icon: Plane, color: c("blue") },
  fees: { Icon: Percent, color: c("grey") },
  transfer: { Icon: ArrowLeftRight, color: c("grey") },
  salary: { Icon: BriefcaseBusiness, color: c("green") },
  refund: { Icon: Undo2, color: c("green") },
  income: { Icon: ArrowDownLeft, color: c("green") },
  more: { Icon: Ellipsis, color: c("grey") },
};

/** The glyph and tile colour for a stored icon key; unknown keys get a neutral pair. */
export function categoryStyle(icon: string | null): Style {
  return (icon && STYLES[icon]) || { Icon: Shapes, color: c("grey") };
}
