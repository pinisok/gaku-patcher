#!/bin/bash
set -euo pipefail

LOCALIFY_NAME=GakumasLocalify_v3.5.0k2.apk

APKEEP_LINK=https://github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu
APKEEP_NAME=apkeep

APKEDITOR_LINK=https://github.com/REAndroid/APKEditor/releases/download/V1.4.9/APKEditor-1.4.9.jar
APKEDITOR_NAME=APKEditor.jar

# LSPatch renamed its release asset from "lspatch.jar" to "lspatch-<ver>-<build>-release.jar"
# as of v1.2, so resolve the asset by pattern from the latest release instead of a fixed name.
LSPATCH_REPO=JingMatrix/LSPatch
LSPATCH_PATTERN='lspatch-*-release.jar'
LSPATCH_NAME=lspatch.jar

if [ ! -f "$LOCALIFY_NAME" ]; then
    echo "Required local Localify APK not found: $LOCALIFY_NAME" >&2
    exit 1
fi

aria2c -x4 "$APKEEP_LINK" -o "$APKEEP_NAME"
aria2c -x4 "$APKEDITOR_LINK" -o "$APKEDITOR_NAME"
gh release download --repo "$LSPATCH_REPO" --pattern "$LSPATCH_PATTERN" --output "$LSPATCH_NAME" --clobber

for f in "$APKEEP_NAME" "$APKEDITOR_NAME" "$LSPATCH_NAME"; do
    if [ ! -s "$f" ]; then
        echo "Module download failed or empty: $f" >&2
        exit 1
    fi
done

chmod +x "$APKEEP_NAME"

echo "LOCALIFY_NAME=$LOCALIFY_NAME" >> "$GITHUB_ENV"
