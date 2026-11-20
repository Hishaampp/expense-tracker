import { categoryColorName, type CategoryColorName } from "@/components/overview/category-style";

/**
 * The category palette as RGB for the PDF, which can't read CSS. The same
 * values as the --cat-* tokens in globals.css (the app's tile primitives).
 */
const RGB: Record<CategoryColorName, [number, number, number]> = {
  orange: [0xe2, 0x60, 0x0f],
  green: [0x1e, 0x95, 0x50],
  blue: [0x3b, 0x5b, 0xdb],
  red: [0xd9, 0x38, 0x3e],
  purple: [0xa6, 0x3b, 0xbf],
  amber: [0xb8, 0x73, 0x00],
  violet: [0x6a, 0x4f, 0xe0],
  teal: [0x0f, 0x8a, 0x80],
  pink: [0xc2, 0x34, 0x7a],
  grey: [0x7a, 0x74, 0x6e],
};

export const categoryColor = (icon: string | null) => RGB[categoryColorName(icon)];
