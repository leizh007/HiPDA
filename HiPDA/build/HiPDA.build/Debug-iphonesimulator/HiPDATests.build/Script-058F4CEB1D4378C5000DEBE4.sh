#!/bin/sh
codesign --verify --force --sign "$CODE_SIGN_IDENTITY" "$CODESIGNING_FOLDER_PATH"
