import { ArrowDownToLine, LayoutDashboard, PiggyBank, Plane, ReceiptText, Shapes, Store, type LucideIcon } from "lucide-react";

export type NavItem = { href: string; label: string; icon: LucideIcon; ready: boolean };

/** The dashboard's pages; the ones not built yet are shown, not linked. */
export const NAV: NavItem[] = [
  { href: "/overview", label: "Overview", icon: LayoutDashboard, ready: true },
  { href: "/transactions", label: "Transactions", icon: ReceiptText, ready: true },
  { href: "/categories", label: "Categories", icon: Shapes, ready: true },
  { href: "/payees", label: "Payees", icon: Store, ready: true },
  { href: "/rooms", label: "Rooms", icon: Plane, ready: true },
  { href: "/budgets", label: "Budgets", icon: PiggyBank, ready: true },
  { href: "/export", label: "Export", icon: ArrowDownToLine, ready: false },
];
