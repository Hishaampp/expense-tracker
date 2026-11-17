import { ArrowDownToLine, LayoutDashboard, PiggyBank, Plane, ReceiptText, Shapes, Store, type LucideIcon } from "lucide-react";

export type NavItem = { href: string; label: string; icon: LucideIcon; ready: boolean };

/** The dashboard's pages; the ones not built yet are shown, not linked. */
export const NAV: NavItem[] = [
  { href: "/overview", label: "Overview", icon: LayoutDashboard, ready: true },
  { href: "/transactions", label: "Transactions", icon: ReceiptText, ready: false },
  { href: "/categories", label: "Categories", icon: Shapes, ready: false },
  { href: "/payees", label: "Payees", icon: Store, ready: false },
  { href: "/rooms", label: "Rooms", icon: Plane, ready: false },
  { href: "/budgets", label: "Budgets", icon: PiggyBank, ready: false },
  { href: "/export", label: "Export", icon: ArrowDownToLine, ready: false },
];
