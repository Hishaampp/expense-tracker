#!/usr/bin/env bash
# The single CI gate (spec §16 Phase 0). Each step guards one contract:
#   lint include pinned  -> a missing include silently disables every lint
#   codegen freshness    -> a schema change without a migration loses data
#   format               -> dart format is the only whitespace authority
#   analyze --fatal-infos-> silence-bug lints are build failures
#   test (random order)  -> behaviour + policy greps; catches state leakage
#   manifests            -> no SMS perms in play; no INTERNET in release
# Run locally before every PR; a CI workflow should call exactly this script.
# What CI cannot prove: on-device capture, OEM battery behaviour, real fonts.
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$1"; }

step "pub get"
flutter pub get >/dev/null

step "lint include resolves"
include=$(sed -n 's/^include: package:very_good_analysis\/\(.*\)$/\1/p' analysis_options.yaml)
vga_dir=$(dart pub deps --json | python3 -I -c 'import json,sys;d=json.load(sys.stdin);print(next(p["version"] for p in d["packages"] if p["name"]=="very_good_analysis"))')
pub_cache="${PUB_CACHE:-$HOME/.pub-cache}"
if [[ ! -f "$pub_cache/hosted/pub.dev/very_good_analysis-$vga_dir/lib/$include" ]]; then
  echo "::error::analysis_options include '$include' not found in very_good_analysis $vga_dir — analysis would run with zero rules."; exit 1
fi

step "generated code is up to date"
dart run build_runner build --delete-conflicting-outputs >/dev/null
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/app/ >/dev/null
dart run drift_dev schema steps drift_schemas/app/ lib/data/db/app_database.steps.dart >/dev/null
dart run drift_dev schema generate --data-classes --companions drift_schemas/app/ test/drift/app/generated/ >/dev/null
if [[ -d .git ]] && ! git diff --exit-code --stat -- '*.g.dart' '*.steps.dart' drift_schemas/ test/drift/app/generated/; then
  echo "::error::Generated code or drift_schemas/ is stale. If you changed a table: bump schemaVersion, add a migration step, then commit the regenerated files."; exit 1
fi

step "format"
dart format --output=none --set-exit-if-changed .

step "analyze"
flutter analyze --fatal-infos

step "test"
flutter test --test-randomize-ordering-seed random

step "parser package tests"
(cd packages/txn_parser && dart test)

step "manifest checks"
tool/check_manifests.sh

printf '\nCI passed.\n'
