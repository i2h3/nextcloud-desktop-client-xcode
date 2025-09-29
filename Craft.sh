#!/bin/env zsh

# Read the available environment paths which include (for example) Homebrew.
for f in /etc/paths.d/*; do
    while read -r line; do
        export PATH="$PATH:$line"
    done < "$f"
done

if [ -f "~/.zprofile" ]; then
    echo "Sourcing ~/.zprofile to include possible PATH definitions..."
    source "~/.zprofile"
fi

if [ -z "${CODE_SIGN_IDENTITY}" ]; then
    echo "Error: CODE_SIGN_IDENTITY is not defined or is empty!"
    exit 1
fi

DESKTOP_CLIENT_PROJECT_ROOT="$SOURCE_ROOT/Upstream"

if [ ! -d "$DESKTOP_CLIENT_PROJECT_ROOT" ]; then
    echo "Desktop client project root does not exist. Cloning repository..."
    cd "$SOURCE_ROOT"
    git clone --branch=master --quiet https://github.com/nextcloud/desktop.git Upstream

    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone the Nextcloud desktop client repository!"
        exit 1
    else
        echo "Successfully cloned the Nextcloud desktop client repository."
    fi
fi

if [ -d "$DESKTOP_CLIENT_PROJECT_ROOT/admin/osx/mac-crafter" ]; then
    cd "$DESKTOP_CLIENT_PROJECT_ROOT/admin/osx/mac-crafter"
else
    echo "Error: Directory '$DESKTOP_CLIENT_PROJECT_ROOT/admin/osx/mac-crafter' does not exist!"
    exit 1
fi

echo "Desktop client project root: $DESKTOP_CLIENT_PROJECT_ROOT"
echo "Build path: $DERIVED_SOURCES_DIR"
echo "Product path: $SOURCE_ROOT/Build"
echo "Code sign identity: $CODE_SIGN_IDENTITY"

swift run mac-crafter \
    --build-path="$DERIVED_SOURCES_DIR" \
    --product-path="/Applications" \
    --build-type="Debug" \
    --dev \
    --disable-auto-updater \
    --build-file-provider-module \
    --code-sign-identity="$CODE_SIGN_IDENTITY" \
    "$DESKTOP_CLIENT_PROJECT_ROOT"
