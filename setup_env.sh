#!/bin/bash

# CAMotics macOS Build Environment Setup Script
# This script sets up all required environment variables for building CAMotics

echo "Setting up CAMotics build environment..."

# Qt5 Configuration
export QTDIR=/opt/homebrew/opt/qt@5
export PKG_CONFIG_PATH=/opt/homebrew/opt/qt@5/lib/pkgconfig:$PKG_CONFIG_PATH

# Library Paths
export BZIP2_LIBPATH=/opt/homebrew/opt/bzip2/lib
export BZIP2_INCLUDE=/opt/homebrew/opt/bzip2/include
export SQLITE3_LIBPATH=/opt/homebrew/opt/sqlite/lib
export SQLITE3_INCLUDE=/opt/homebrew/opt/sqlite/include

# Optional V8 Configuration
export V8_HOME=/opt/homebrew/opt/v8
export V8_INCLUDE=/opt/homebrew/opt/v8/include

# Verify critical paths exist
echo "Verifying environment setup..."

if [ ! -d "$QTDIR" ]; then
    echo "WARNING: Qt5 not found at $QTDIR"
    echo "Install with: brew install qt@5"
fi

if [ ! -d "/opt/homebrew/opt/bzip2" ]; then
    echo "WARNING: bzip2 not found"
    echo "Install with: brew install bzip2"
fi

if [ ! -d "/opt/homebrew/opt/sqlite" ]; then
    echo "WARNING: sqlite not found"
    echo "Install with: brew install sqlite"
fi

# Check SCons Python environment
SCONS_PYTHON="/opt/homebrew/Cellar/scons/4.9.1/libexec/bin/python3"
if [ -f "$SCONS_PYTHON" ]; then
    if ! $SCONS_PYTHON -c "import six" 2>/dev/null; then
        echo "WARNING: 'six' module not found in SCons Python"
        echo "Install with: $SCONS_PYTHON -m pip install six"
    fi
else
    echo "WARNING: SCons Python not found at expected location"
fi

echo "Environment setup complete!"
echo ""
echo "Current configuration:"
echo "  QTDIR: $QTDIR"
echo "  BZIP2_LIBPATH: $BZIP2_LIBPATH"
echo "  SQLITE3_LIBPATH: $SQLITE3_LIBPATH"
echo "  PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
echo ""
echo "To build CAMotics:"
echo "  make all"
echo ""
echo "Or manually:"
echo "  scons with_tpl=False"