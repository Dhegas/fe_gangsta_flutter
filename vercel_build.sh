#!/bin/sh
set -e

# Configurable Flutter channel/version
: "${FLUTTER_CHANNEL:=stable}"
: "${FLUTTER_REPO:=https://github.com/flutter/flutter.git}"

# Download Flutter SDK (shallow clone for speed)
if [ ! -d "$PWD/.flutter" ]; then
  git clone --depth 1 --branch "$FLUTTER_CHANNEL" "$FLUTTER_REPO" .flutter
fi

export PATH="$PWD/.flutter/bin:$PATH"
flutter --version
flutter config --enable-web

# Fetch dependencies
flutter pub get

# Build Flutter web with Supabase env passed from Vercel env vars
flutter build web --release --web-renderer canvaskit \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
