# Linux Build Environment Setup
# Qt5 and other libraries are in standard system paths on Linux
# No special paths needed

all:
	scons -C cbang
	scons with_tpl=False

clean:
	scons -C cbang -c
	scons -c
