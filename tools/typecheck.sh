#!/usr/bin/env bash
# Type-checks EVERY Kotlin file in the app with the real Kotlin compiler.
#
# The Android SDK, Compose and the other libraries are not downloadable in every
# environment, so tools/stubs holds hand-written stand-ins with the same shapes.
# That is enough for the compiler to resolve types and catch the errors a static
# scan cannot see: a method that does not exist on a return type, a stale field
# after a refactor, a missing import.
#
# Not a substitute for the Gradle build — annotation processing (Hilt, Room) and
# resource linking still only happen there.
#
# Needs kotlinc: set KOTLINC, or place it at /tmp/kotlinc.
set -e
cd "$(dirname "$0")/.."
KOTLINC="${KOTLINC:-/tmp/kotlinc/bin/kotlinc}"
if [ ! -x "$KOTLINC" ]; then
  echo "  kotlinc not found — skipping type-check (set KOTLINC=/path/to/bin/kotlinc)"
  exit 0
fi
COROUTINES="$(dirname "$KOTLINC")/../lib/kotlinx-coroutines-core-jvm.jar"
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT

echo "Building API stubs..."
"$KOTLINC" tools/stubs/android/*.kt -cp "$COROUTINES" -nowarn -d "$OUT/android" 2>/dev/null
"$KOTLINC" tools/stubs/compose/*.kt -cp "$COROUTINES:$OUT/android" -nowarn -d "$OUT/compose" 2>/dev/null
"$KOTLINC" tools/stubs/generated/*.kt -nowarn -d "$OUT/generated" 2>/dev/null

echo "Type-checking every source file..."
"$KOTLINC" app/src/main/java/com/middleeastcontainer \
  -cp "$OUT/android:$OUT/compose:$OUT/generated:$COROUTINES" \
  -nowarn -d "$OUT/classes" 2>"$OUT/errors.txt" || true

COUNT=$(grep -c "error:" "$OUT/errors.txt" || true)
if [ "$COUNT" -gt 0 ]; then
  grep "error:" "$OUT/errors.txt" | sed 's|.*middleeastcontainer/||'
  echo "  $COUNT error(s)"
  exit 1
fi
echo "  [PASS] every Kotlin file type-checks — 0 errors"
