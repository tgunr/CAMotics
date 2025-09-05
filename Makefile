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
