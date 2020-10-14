# dpkg.mk (edo365.de)  
# universal debian package (dpkg) makefile
# Copyright 2019-2020 Benjamin 'Benno' Falkner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


URL_MK?="https://raw.githubusercontent.com/bennof/edo365.deb/master/debpkg.mk"
BUILD_PATH?=./dists/stable
SRC_PATH?=./deb
REP_NAME?=privatedpkg
INSTALL_PATH?=/usr/local/$(REP_NAME)
SRCS?=$(shell ls -d $(SRC_PATH)/*/ )
DEBS?=$(SRCS:$(SRC_PATH)/%/=$(BUILD_PATH)/%.deb)
RELEASE=Release


.PHONY: $(INSTALL_PATH)/Release /etc/apt/sources.list.d/$(REP_NAME).list $(INSTALL_PATH)/Packages.gz $(INSTALL_PATH)/Packages

all: build


install: copy_files $(INSTALL_PATH)/Release /etc/apt/sources.list.d/$(REP_NAME).list


# INSTALL
copy_files: 
	test -d "$(INSTALL_PATH)" || mkdir -p $(INSTALL_PATH)
	chmod -R 0755 $(INSTALL_PATH)
	cp $(BUILD_PATH)/*.deb $(INSTALL_PATH)

$(INSTALL_PATH)/Packages:
	cd $(INSTALL_PATH); dpkg-scanpackages . /dev/null > Packages
	chmod -R 0644 $(INSTALL_PATH)/*

$(INSTALL_PATH)/Packages.gz:
	cd $(INSTALL_PATH); dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
	chmod -R 0644 $(INSTALL_PATH)/*

$(INSTALL_PATH)/Release: $(INSTALL_PATH)/Packages.gz $(INSTALL_PATH)/Packages
	echo "Origin: $(REP_NAME)" > $@
	echo "Label: $(REP_NAME)" >> $@
	echo "Suite: stable" >> $@
	echo "Date: $(shell date -R -u)" >> $@
	echo "Architectures: all" >> $@
	echo "Components: ." >> $@
	echo "Description: Private Debian Package Repository" >> $@
	echo "MD5Sum:" >> $@
	echo " $(shell md5sum $(INSTALL_PATH)/Packages.gz | cut -f 1 -d ' ') $(shell stat -c%s $(INSTALL_PATH)/Packages.gz) Packages.gz" >> $@ 
	echo " $(shell md5sum $(INSTALL_PATH)/Packages | cut -f 1 -d ' ') $(shell stat -c%s $(INSTALL_PATH)/Packages) Packages" >> $@ 

/etc/apt/sources.list.d/$(REP_NAME).list:
	echo '### THIS FILE IS AUTOMATICALLY CONFIGURED ###' > $@
	echo 'deb [trusted=yes] file:$(INSTALL_PATH) ./ ' >> $@




# update
update:
	@echo "updating"
	wget $(URL_MK)  || curl -O $(URL_MK)


# Build
build: output_dir $(DEBS)

$(BUILD_PATH)/%.deb:  $(SRC_PATH)/%
	chmod -R 755 $</DEBIAN
	dpkg-deb -b $< $(BUILD_PATH)

output_dir:
	mkdir -p $(BUILD_PATH)

# Clean
clean:
	rm -rf $(BUILD_PATH)

# Create a new package
new:
	@test -n $(NAME) || echo "ERROR: no NAME defined"
	@test -n $(NAME) ||exit 1 
	@test -d $(SRC_PATH)/$(NAME) && echo "ERROR: folder already exists" && exit 1 || mkdir -p $(SRC_PATH)/$(NAME)/DEBIAN
	@echo "#!/bin/sh" > $(SRC_PATH)/$(NAME)/DEBIAN/postinst
	@chmod 755 $(SRC_PATH)/$(NAME)/DEBIAN/postinst
	@echo "Package: $(NAME)"> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Version: 0.0.1" >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Section: web" >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Priority: optional" >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Maintainer: $(USER)" >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Homepage: http://" >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Architecture: all" >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Depends: " >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "Description: " >> $(SRC_PATH)/$(NAME)/DEBIAN/control 
	@echo "" >> $(SRC_PATH)/$(NAME)/DEBIAN/control 

# Initialize a new project with dpkg.mk
init: Makefile
	@echo "Install all dependencies"
	sudo apt-get install dpkg dpkg-dev gzip
	mkdir -p $(BUILD_PATH) $(SRC_PATH)

Makefile:
	@echo "#Makefile for DPKG\ninclude dpkg.mk" > Makefile

# Help
help: 
	cat README.mk

# Tests
test:
	@echo "Test:"
	@echo "URL:          $(URL_MK)"
	@echo "Build Path:   $(BUILD_PATH)"
	@echo "Install Path: $(INSTALL_PATH)"
	@echo "Sourece Dirs: $(SRCS)"
	@echo "deb-Files:    $(DEBS)"