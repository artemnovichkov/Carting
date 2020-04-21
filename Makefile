BINARY?=carting
BUILD_FOLDER?=.build
OS?=sierra
PREFIX?=/usr/local
PROJECT?=Carting
RELEASE_BINARY_FOLDER?=$(BUILD_FOLDER)/release/$(PROJECT)
VERSION?=2.1.3

build:
	swift build --disable-sandbox -c release

test:
	swift test

clean:
	swift package clean
	rm -rf $(BUILD_FOLDER) $(PROJECT).xcodeproj

xcode:
	swift package generate-xcodeproj

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(RELEASE_BINARY_FOLDER) $(PREFIX)/bin/$(BINARY)

bottle: clean build
	mkdir -p $(BINARY)/$(VERSION)/bin
	cp README.md $(BINARY)/$(VERSION)/README.md
	cp LICENSE $(BINARY)/$(VERSION)/LICENSE
	cp -f $(RELEASE_BINARY_FOLDER) $(BINARY)/$(VERSION)/bin/$(BINARY)
	tar cfvz $(BINARY)-$(VERSION).$(OS).bottle.tar.gz --exclude='*/.*' $(BINARY)
	shasum -a 256 $(BINARY)-$(VERSION).$(OS).bottle.tar.gz
	rm -rf $(BINARY)

sha256:
	wget https://github.com/artemnovichkov/$(PROJECT)/archive/$(VERSION).tar.gz -O $(PROJECT)-$(VERSION).tar.gz
	shasum -a 256 $(PROJECT)-$(VERSION).tar.gz
	rm $(PROJECT)-$(VERSION).tar.gz
