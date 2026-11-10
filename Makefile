THEOS ?= $(HOME)/theos
SOURCE_ZIP := CC18iPad-iOS18-visual-upgrade.zip

.PHONY: clean package
clean:
	rm -rf CC18iPad/packages CC18iPad/.theos CC18iPad/obj

package:
	unzip -oq $(SOURCE_ZIP) -d .
	$(MAKE) -C CC18iPad package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
