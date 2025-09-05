# CAMotics Embedded Build Guide for macOS

## Overview
This comprehensive guide documents the complete process of building CAMotics on macOS, including troubleshooting common issues encountered during embedded integration. Based on a real debugging session that resolved multiple build failures.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Original Problem & Root Cause](#original-problem--root-cause)
3. [Environment Setup](#environment-setup)
4. [Dependencies Installation](#dependencies-installation)
5. [Build Process](#build-process)
6. [V8 Configuration Details](#v8-configuration-details)
7. [Troubleshooting](#troubleshooting)
8. [Integration Notes](#integration-notes)

## Prerequisites

### System Requirements
- macOS 12.0 or later
- Xcode Command Line Tools
- Homebrew package manager
- Python 3.8+ (for SCons)

### Development Tools
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python (if not already installed)
brew install python@3.11
```

## Original Problem & Root Cause

### The Issue
CAMotics build was failing with:
```
ModuleNotFoundError: No module named 'six'
```

### Root Cause Analysis
1. **Primary Issue**: Missing `six` Python module in SCons' isolated environment
2. **Secondary Issues**:
   - Missing bzip2 library paths
   - Missing sqlite3 library paths
   - Qt5 pkg-config not in PATH
   - V8 header detection issues

### Investigation Steps Taken
1. **Identified SCons Environment**: Uses `/opt/homebrew/Cellar/scons/4.9.1/libexec/lib/python3.13/site-packages/`
2. **Found Missing Dependencies**: `six` module not installed in SCons environment
3. **Discovered Library Path Issues**: Homebrew libraries not in standard locations
4. **Resolved Qt5 Detection**: Added pkg-config path for Qt5
5. **Bypassed V8 Issues**: Used `with_tpl=False` to skip JavaScript engine requirements

## Environment Setup

### Required Environment Variables
Add these to your shell profile (`.zshrc`, `.bashrc`, or `.bash_profile`):

```bash
# Qt5 Configuration
export QTDIR=/opt/homebrew/opt/qt@5
export PKG_CONFIG_PATH=/opt/homebrew/opt/qt@5/lib/pkgconfig

# Library Paths
export BZIP2_LIBPATH=/opt/homebrew/opt/bzip2/lib
export BZIP2_INCLUDE=/opt/homebrew/opt/bzip2/include
export SQLITE3_LIBPATH=/opt/homebrew/opt/sqlite/lib
export SQLITE3_INCLUDE=/opt/homebrew/opt/sqlite/include

# Optional: V8 Configuration (if using TPL)
export V8_HOME=/opt/homebrew/opt/v8
export V8_INCLUDE=/opt/homebrew/opt/v8/include
```

### Makefile Configuration
Update your Makefile to include environment variables:

```makefile
# macOS Build Environment Setup
export QTDIR := /opt/homebrew/opt/qt@5
export BZIP2_LIBPATH := /opt/homebrew/opt/bzip2/lib
export BZIP2_INCLUDE := /opt/homebrew/opt/bzip2/include
export SQLITE3_LIBPATH := /opt/homebrew/opt/sqlite/lib
export SQLITE3_INCLUDE := /opt/homebrew/opt/sqlite/include
export PKG_CONFIG_PATH := /opt/homebrew/opt/qt@5/lib/pkgconfig

all:
	scons -C cbang
	scons with_tpl=False

clean:
	scons -C cbang -c
	scons -c
```

## Dependencies Installation

### Core Dependencies
```bash
# Build Tools
brew install scons cmake ninja

# Core Libraries
brew install bzip2 sqlite zlib xz lz4 snappy expat

# Qt5 Framework
brew install qt@5

# Optional: V8 JavaScript Engine
brew install v8

# Python Dependencies (for SCons)
brew install python@3.11
```

### Python Module Installation
Install required Python modules in SCons' environment:

```bash
# Install six module in SCons environment
/opt/homebrew/Cellar/scons/4.9.1/libexec/bin/python3 -m pip install six

# Verify installation
/opt/homebrew/Cellar/scons/4.9.1/libexec/bin/python3 -c "import six; print('six OK')"
```

## Build Process

### Quick Build (Recommended for Embedded)
```bash
# Set environment variables
source setup_env.sh  # Or manually export variables above

# Build
make all
```

### Manual Build with Full Control
```bash
# Build CBang first
scons -C cbang

# Build CAMotics with TPL disabled
QTDIR=/opt/homebrew/opt/qt@5 \
BZIP2_LIBPATH=/opt/homebrew/opt/bzip2/lib \
BZIP2_INCLUDE=/opt/homebrew/opt/bzip2/include \
SQLITE3_LIBPATH=/opt/homebrew/opt/sqlite/lib \
SQLITE3_INCLUDE=/opt/homebrew/opt/sqlite/include \
PKG_CONFIG_PATH=/opt/homebrew/opt/qt@5/lib/pkgconfig \
scons with_tpl=False
```

### Build with V8 Support (Advanced)
```bash
# Install and configure V8
brew install v8

# Build with V8
V8_HOME=/opt/homebrew/opt/v8 \
V8_INCLUDE=/opt/homebrew/opt/v8/include \
scons with_tpl=True
```

## V8 Configuration Details

### V8 Compressed Pointers
**Current Status**: NOT enabled in CAMotics build

#### V8 Configuration Support
- CAMotics V8 config supports compressed pointers via `v8_compress_pointers` environment variable
- If set, defines `V8_COMPRESS_POINTERS` macro
- Requires V8 to be built with compression enabled

#### Buildbot Configuration
The project's buildbot uses compressed V8:
```gn
# buildbot/workers/windows-10-64bit/v8-config/out/x64.release/args.gn
v8_enable_pointer_compression = true
v8_monolithic = true
```

#### To Enable Compression
```bash
# Set environment variable
export v8_compress_pointers=1

# Ensure V8 is built with compression
# (Homebrew V8 doesn't enable this by default)

# Build CAMotics
scons with_tpl=True
```

### V8 Library Detection
CAMotics tries V8 libraries in this order:
1. `v8_monolith` (single library)
2. `v8` + `v8_libplatform` (separate libraries)
3. `v8_snapshot` + `v8_base`/`v8_base.x64`/`v8_base.ia32`

## Troubleshooting

### Common Issues & Solutions

#### 1. ModuleNotFoundError: No module named 'six'
```bash
# Solution: Install in SCons environment
/opt/homebrew/Cellar/scons/4.9.1/libexec/bin/python3 -m pip install six
```

#### 2. Library not found errors
```bash
# Check library locations
ls /opt/homebrew/opt/bzip2/lib/libbz2.dylib
ls /opt/homebrew/opt/sqlite/lib/libsqlite3.dylib

# Set explicit paths
export BZIP2_LIBPATH=/opt/homebrew/opt/bzip2/lib
export SQLITE3_LIBPATH=/opt/homebrew/opt/sqlite/lib
```

#### 3. Qt5 pkg-config not found
```bash
# Add Qt5 to pkg-config path
export PKG_CONFIG_PATH=/opt/homebrew/opt/qt@5/lib/pkgconfig

# Verify
pkg-config --exists Qt5Core && echo "Qt5 found"
```

#### 4. V8 header not found
```bash
# Set V8 paths explicitly
export V8_HOME=/opt/homebrew/opt/v8
export V8_INCLUDE=/opt/homebrew/opt/v8/include

# Or disable TPL
scons with_tpl=False
```

#### 5. Build cache issues
```bash
# Clear SCons cache
rm -rf .sconsign.dblite config.log

# Clear build directory
make clean
```

### Diagnostic Commands
```bash
# Check SCons Python environment
/opt/homebrew/Cellar/scons/4.9.1/libexec/bin/python3 -c "import sys; print(sys.path)"

# Check library versions
brew list --versions bzip2 sqlite qt@5 v8

# Check pkg-config
pkg-config --list-all | grep -i qt

# Check V8 installation
ls /opt/homebrew/opt/v8/lib/
ls /opt/homebrew/opt/v8/include/
```

## Integration Notes

### For Embedded Projects

#### 1. Minimal Build Configuration
Use `with_tpl=False` for smallest footprint:
```bash
scons with_tpl=False
```
This disables JavaScript engine support but maintains all core CAMotics functionality.

#### 2. Static Linking (Optional)
For embedded deployment, consider static linking:
```bash
scons static=True mostly_static=True
```

#### 3. Custom Installation Paths
```bash
scons install_prefix=/custom/path
```

#### 4. Cross-Compilation
For embedded targets, set architecture:
```bash
scons TARGET_ARCH=arm64  # or x86_64
```

### Library Dependencies
CAMotics requires these libraries at runtime:
- Qt5 Core, GUI, OpenGL, Network, WebSockets, Widgets
- bzip2, sqlite3, zlib, lz4, expat
- OpenGL framework (macOS)
- System frameworks: CoreServices, IOKit, Security, etc.

### Python Integration
CAMotics provides Python bindings:
- Python module: `camotics.dylib`
- Requires Python 3.8+ with development headers
- Install in virtual environment or system Python

## Files Modified/Created

### Modified Files
- `Makefile` - Added environment variable setup
- SCons Python environment - Added `six` module

### Created Files
- `MACOS_BUILD_SETUP.md` - Build documentation
- `CAMOTICS_EMBEDDED_BUILD_GUIDE.md` - This comprehensive guide

## Version Information
- **macOS**: Tested on macOS 15.0 (Apple Silicon)
- **SCons**: 4.9.1
- **Qt5**: 5.15.16 (Homebrew)
- **V8**: 13.5.212.10 (Homebrew)
- **Python**: 3.13 (SCons environment)

## Support
For issues not covered here:
1. Check the [CAMotics GitHub Issues](https://github.com/CauldronDevelopmentLLC/CAMotics/issues/)
2. Review the build logs for specific error messages
3. Verify all environment variables are set correctly
4. Ensure all Homebrew packages are up to date

---
*This guide was created from a real debugging session that resolved multiple build failures on macOS. Last updated: 2025-09-05*