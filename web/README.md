# Ample for the web

The Ample dashboard: your phone's records on a bigger screen, unlocked only
in your browser. Plan: `../docs/WEB_DASHBOARD_PLAN.md`. Product record:
`PRODUCT.md`. Brand: `../docs/DESIGN.md`.

```bash
npm install
npm run dev        # http://localhost:3000
npm test           # crypto, vault and format tests
npm run build      # static site in out/
```

- **No server code.** `next build` exports static HTML/JS; records are
  fetched from Supabase and unlocked in the tab with WebCrypto.
- **Same crypto as the app.** `src/lib/crypto` is a port of
  `lib/data/sync/sync_crypto.dart`; `src/lib/crypto/fixtures/sync-vectors.json`
  is written by the app's own code
  (`UPDATE_WEB_VECTORS=1 flutter test test/data/sync/web_vectors_test.dart`).
- **Brand animations** in `public/brand/` are generated from the logo
  geometry: `python3 tool/render_brand_lottie.py web/public/brand`.
- **Deploy:** Vercel, Root Directory `web`. Security headers in `vercel.json`.
