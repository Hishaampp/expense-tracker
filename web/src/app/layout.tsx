import type { Metadata, Viewport } from "next";
import localFont from "next/font/local";
import { SessionProvider } from "@/lib/session/session";
import { ThemeProvider, themeBootScript } from "@/lib/theme/theme";
import { VaultProvider } from "@/lib/vault/vault-context";
import "./globals.css";

const fraunces = localFont({
  src: "../fonts/Fraunces-SoftSemiBold.ttf",
  weight: "600",
  variable: "--font-fraunces",
  display: "swap",
});

const manrope = localFont({
  src: [
    { path: "../fonts/Manrope-Regular.ttf", weight: "400" },
    { path: "../fonts/Manrope-Medium.ttf", weight: "500" },
    { path: "../fonts/Manrope-SemiBold.ttf", weight: "600" },
    { path: "../fonts/Manrope-Bold.ttf", weight: "700" },
  ],
  variable: "--font-manrope",
  display: "swap",
});

export const metadata: Metadata = {
  title: { default: "Ample", template: "%s · Ample" },
  description: "Your Ample records on a bigger screen, unlocked only in your browser.",
  robots: { index: false, follow: false },
};

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: dark)", color: "#0d0d0d" },
    { media: "(prefers-color-scheme: light)", color: "#ffffff" },
  ],
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en-IN" data-theme="dark" className={`${fraunces.variable} ${manrope.variable}`} suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeBootScript }} />
      </head>
      <body>
        <ThemeProvider>
          <SessionProvider>
            <VaultProvider>{children}</VaultProvider>
          </SessionProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
