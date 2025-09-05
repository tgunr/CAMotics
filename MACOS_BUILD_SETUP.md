# CAMotics macOS Build Setup Guide

## Overview
This document describes the setup required to build CAMotics on macOS, including dependency installation and environment configuration.

## What I Learned

### Root Cause Analysis
The build was failing due to missing Python dependencies in SCons' isolated environment:
- **Primary Issue**: Missing `six` Python module in SCons' Python environment
- **Secondary Issues**: Missing system libraries (bzip2, sqlite3) and Qt5 configuration
- **Environment Isolation**: SCons uses its own Python environment separate from system Python

### Key Findings
1. **SCons Environment**: Uses `/opt/homebrew/Cellar/scons/4.9.1/libexec/lib/python3.13/site-packages/`
2. **Qt5 Detection**: Requires `QTDIR` environment variable and pkg-config setup
3. **Library Dependencies**: Need explicit paths for bzip2 and sqlite3 when not in standard locations
4. **Build Options**: `with_tpl=False` bypasses V8/Chakra requirements for basic functionality

## Changes Made from Master Branch

### 1. Python Dependencies
- **Installed**: `six` module in SCons' Python environment
- **Command**: `/opt/homebrew/Cellar/scons/4.9.1/libexec/bin/python3 -m pip install six`

### 2. System Dependencies
- **Installed**: `bzip2` via Homebrew
- **Installed**: `v8` via Homebrew (for future TPL support)
- **Verified**: `qt@5` and `sqlite` already installed

### 3. Environment Configuration
Added required environment variables for proper library detection:

```bash
export QTDIR=/opt/homebrew/opt/qt@5
export BZIP2_LIBPATH=/opt/homebrew/opt/bzip2/lib
export BZIP2_INCLUDE=/opt/homebrew/opt/bzip2/include
export SQLITE3_LIBPATH=/opt/homebrew/opt/sqlite/lib
export SQLITE3_INCLUDE=/opt/homebrew/opt/sqlite/include
export PKG_CONFIG_PATH=/opt/homebrew/opt/qt@5/lib/pkgconfig
```

### 4. Build Configuration
- **Modified**: Makefile to include environment variables
- **Added**: `with_tpl=False` to bypass V8 requirements
- **Result**: Successful build producing all executables

## Build Results
The build now successfully produces:
- `camotics` - Main CAM application
- `camsim` - Simulation tool
- `gcodetool` - G-code processing utility
- `planner` - Path planning tool
- `camotics.dylib` - Python module

## Usage Instructions

### Quick Build
```bash
make all
```

### Manual Build with Environment
```bash
QTDIR=/opt/homebrew/opt/qt@5 \
BZIP2_LIBPATH=/opt/homebrew/opt/bzip2/lib \
BZIP2_INCLUDE=/opt/homebrew/opt/bzip2/include \
SQLITE3_LIBPATH=/opt/homebrew/opt/sqlite/lib \
SQLITE3_INCLUDE=/opt/homebrew/opt/sqlite/include \
PKG_CONFIG_PATH=/opt/homebrew/opt/qt@5/lib/pkgconfig \
scons with_tpl=False
```

### Prerequisites Check
Ensure these Homebrew packages are installed:
```bash
brew install scons qt@5 bzip2 sqlite v8
```

## Troubleshooting

### Common Issues
1. **Missing `six` module**: Install in SCons environment
2. **Qt5 not found**: Set `QTDIR` and `PKG_CONFIG_PATH`
3. **Library not found**: Set explicit `*_LIBPATH` and `*_INCLUDE` variables
4. **V8 issues**: Use `with_tpl=False` to bypass

### Verification
Test the build environment:
```bash
# Check SCons Python environment
/opt/homebrew/Cellar/scons/4.9.1/libexec/bin/python3 -c "import six; print('six OK')"

# Check Qt5
ls /opt/homebrew/opt/qt@5/lib/pkgconfig/Qt5Core.pc

# Check libraries
ls /opt/homebrew/opt/bzip2/lib/libbz2.dylib
ls /opt/homebrew/opt/sqlite/lib/libsqlite3.dylib
```

## Files Modified
- `Makefile` - Added environment variable setup
- `MACOS_BUILD_SETUP.md` - This documentation

## Notes
- Build tested on macOS 15.0 with Apple Silicon
- Uses Homebrew for package management
- SCons version 4.9.1 with Python 3.13
- Qt5 version 5.15.16 from Homebrew