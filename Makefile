BINARY?=carting
BUILD_FOLDER?=.build
OS?=sierra
PREFIX?=/usr/local
PROJECT?=Carting
RELEASE_BINARY_FOLDER?=$(BUILD_FOLDER)/release/$(PROJECT)
VERSION?=1.2.4

build:
	swift package --enable-prefetching update
	swift build --enable-prefetching -c release -Xswiftc -static-stdlib

install: build
	cp -f $(RELEASE_BINARY_FOLDER) $(PREFIX)/bin/$(BINARY)