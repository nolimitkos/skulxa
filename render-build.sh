#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
say() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${RED}==>${NC} $1"; }

say "H2APK Render Build"
echo "───────────────────"
echo

say "Installing packages..."
apt-get update -qq
apt-get install -y -qq openjdk-17-jdk-headless zip wget unzip file

say "Installing Android SDK..."
mkdir -p /opt/android-sdk
cd /opt/android-sdk

if [ ! -d "cmdline-tools/latest/bin" ]; then
    rm -rf cmdline-tools
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip -q commandlinetools-linux-11076708_latest.zip
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/bin cmdline-tools/latest/
    mv cmdline-tools/lib cmdline-tools/latest/
fi

export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0

say "Accepting SDK licenses..."
yes | cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null 2>&1 || true

say "Installing build tools..."
cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;34.0.0" "platforms;android-34" >/dev/null 2>&1 || true

say "Downloading JAR tools..."
mkdir -p /opt/render/project/tools
cd /opt/render/project/tools

REPO="https://github.com/HashShin/H2APK-TOOLS/releases/download/tools"

download_tool() {
    local name="$1" url="$2"
    if [ -f "$name" ]; then
        say "$name already present"
        return 0
    fi
    say "Downloading $name..."
    for i in 1 2 3; do
        if wget -q -O "$name" "$url" 2>/dev/null; then
            say "Downloaded $name"
            return 0
        fi
        warn "Retry $i/3..."
        sleep 3
    done
    warn "Failed to download $name"
    return 1
}

download_tool "d8.jar" "$REPO/d8.jar" || exit 1
download_tool "apksigner.jar" "$REPO/apksigner.jar" || exit 1
download_tool "android.jar" "$REPO/android.jar" || exit 1

say "Verifying dependencies..."
ALL_OK=true
for cmd in javac java aapt2 zipalign zip wget go; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "  ✓ $cmd"
    else
        echo "  ✗ $cmd NOT FOUND"
        ALL_OK=false
    fi
done

for jar in d8.jar apksigner.jar android.jar; do
    if [ -f "/opt/render/project/tools/$jar" ]; then
        echo "  ✓ $jar"
    else
        echo "  ✗ $jar NOT FOUND"
        ALL_OK=false
    fi
done

if $ALL_OK; then
    say "All dependencies ready!"
else
    warn "Some dependencies missing"
fi

say "Building Go binary..."
cd /opt/render/project
go build -o h2apk main.go
say "Build complete!"
