import type { NextConfig } from "next";

// A static site: every page is HTML and JS built ahead of time, with no
// server code. Records are fetched and unlocked in the browser.
const nextConfig: NextConfig = {
  output: "export",
  images: { unoptimized: true },
  poweredByHeader: false,
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
