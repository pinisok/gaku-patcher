#!/bin/bash

LOCALIFY_NAME=GakumasLocalify_v3.4.0k.apk

APKEEP_LINK=https://github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu
APKEEP_NAME=apkeep

APKEDITOR_LINK=https://github.com/REAndroid/APKEditor/releases/download/V1.4.9/APKEditor-1.4.9.jar
APKEDITOR_NAME=APKEditor.jar

LSPATCH_LINK=https://github.com/JingMatrix/LSPatch/releases/latest/download/lspatch.jar
LSPATCH_NAME=lspatch.jar

if [ ! -f "$LOCALIFY_NAME" ]; then
    echo "Required local Localify APK not found: $LOCALIFY_NAME" >&2
    exit 1
fi

aria2c -x4 "$APKEEP_LINK" -o "$APKEEP_NAME"
aria2c -x4 "$APKEDITOR_LINK" -o "$APKEDITOR_NAME"
aria2c -x4 "$LSPATCH_LINK" -o "$LSPATCH_NAME"

chmod +x "$APKEEP_NAME"

echo "LOCALIFY_NAME=$LOCALIFY_NAME" >> "$GITHUB_ENV"

