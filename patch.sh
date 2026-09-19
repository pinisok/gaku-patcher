#!/bin/bash
set -euo pipefail

GAME_EMBEDDED_BASE="$GAME_FILE_BASE"_embedded
GAME_PATCHED_APK="$GAME_FILE_BASE"-430-lspatched.apk
GAME_EMBEDDED_APK="$GAME_EMBEDDED_BASE".apk
GAME_EMBEDDED_CLONED="$GAME_EMBEDDED_BASE"_cloned.apk

java -jar lspatch.jar -l 2 --manager "$GAME_APK_NAME" -o ls_patched
java -jar lspatch.jar "$GAME_APK_NAME" -m "$LOCALIFY_NAME" -o localify --force

patched_apk=$(find ./ls_patched/*.apk)
embed_apk=$(find ./localify/*.apk)

mv "$patched_apk" ./"$GAME_PATCHED_APK"
mv "$embed_apk" ./"$GAME_EMBEDDED_APK"

{
    echo "PATCHED_APK=$GAME_PATCHED_APK";
    echo "EMBED_APK=$GAME_EMBEDDED_APK";
} >> "$GITHUB_ENV"

if [ -f "$GAME_CLONED_NAME" ]
then
# The module supports both game packages without package-name rewriting.
java -jar lspatch.jar "$GAME_CLONED_NAME" -m "$LOCALIFY_NAME" -o localify_cloned --force
embed_apk_cloned=$(find ./localify_cloned/*.apk)
mv "$embed_apk_cloned" ./"$GAME_EMBEDDED_CLONED"
echo "EMBED_APK_CLONED=$GAME_EMBEDDED_CLONED" >> "$GITHUB_ENV"
fi
