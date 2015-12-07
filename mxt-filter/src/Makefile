# ------------------------------------------------------------
#
# global names and dirs

include ../Version.mk

MXT_HOME	= ..
MXT_HOME_PATH	= $(shell cd $(MXT_HOME) ; pwd)
PACKAGE_DIR	= $(MXT_HOME_PATH)/lib/$(SOFTWARE)
IMPORT_DIR	= imports
MXT_PACKAGE	= $(SOFTWARE)

# ------------------------------------------------------------
#
# commands

GHCFLAGS	= -Wall -O2 -fglasgow-exts -ignore-package $(SOFTWARE)
GHC             = ghc $(GHCFLAGS)
GHCVERSION	=  $(shell ghc -v 2>&1 | head -n 2 | tail -n 1 | cut -d " " -f 5 | sed 's|^.*ghc-\([0-9.]*\)/package.conf|\1|')

MXT_PACKAGE_NAME=$(DIST_NAME)

RM              = rm -f

all	:

packagename	:
		@echo $(MXT_PACKAGE_NAME)

# ------------------------------------------------------------
#
# protocol handler config (for removing http or popen)

./Text/XML/MXT/Parser/ProtocolHandler.hs	: ./Text/XML/MXT/ProtocolHandler/ProtocolHandler.hs
		$(MAKE) -C ./Text/XML/MXT/ProtocolHandler default_http

# ------------------------------------------------------------
#
# mxt package variables and rules

MXT_SRC	= \
	$(wildcard Control/Monad/*.hs) \
	$(wildcard Data/Tree/NTree/*.hs) \
        $(wildcard System/*.hs) \
	$(wildcard Text/XML/MXT/*.hs) \
	$(wildcard Text/XML/MXT/DOM/*.hs) \
	$(wildcard Text/XML/MXT/Parser/*.hs) \
	$(wildcard Text/XML/MXT/Validator/*.hs)

MXT_OBJ		= $(MXT_SRC:.hs=.o)
MXT_HI		= $(MXT_SRC:.hs=.hi)

MXT_DRIVER	= MXT.o
MXT_LIBA	= libHS$(MXT_PACKAGE).a
MXT_LIBO	= HS$(MXT_PACKAGE).o
MXT_LIB		= $(MXT_LIBA) $(MXT_LIBO)
MXT_REQ_PKG	= -package parsec -package HTTP -package mxt-8.3.0

$(MXT_LIBA)	: $(MXT_SRC)
		$(GHC) -package-name $(MXT_PACKAGE_NAME) $(MXT_REQ_PKG) --make $(MXT_DRIVER:.o=.hs)
		ar crs $@ $(MXT_OBJ)
		@echo "#  please note: !! GNU ar (at least 2.15.90) does not set exit code on missing .o files !!"

$(MXT_LIBO)	: $(MXT_LIBA)
		ld -r --whole-archive -o $@ $<

# ------------------------------------------------------------
#

PROFFLAGS	= -Wall -fglasgow-exts $(MXT_REQ_PKG) -prof -auto -ignore-package mxt -ignore-package HTTP -i../profiling

prof		:
		ghc $(PROFFLAGS) --make $(MXT_DRIVER:.o=.hs)

# ------------------------------------------------------------

LOCAL_INSTALL_DIR	= $(PACKAGE_DIR)
LOCAL_IMPORT_DIR	= $(PACKAGE_DIR)/$(IMPORT_DIR)

PKG_LIB		=
PKG_NAME	=
PKG_HI		=

install_local_$(MXT_PACKAGE)	: $(MXT_LIB) $(SOFTWARE)-package.conf
		$(MAKE) install_local_package PKG_NAME=$(MXT_PACKAGE) PKG_LIB="$(MXT_LIB)" PKG_HI="$(MXT_HI)"

install_local_package	: $(PKG_NAME)-package.conf
		[ -d $(LOCAL_INSTALL_DIR) ] || mkdir -p $(LOCAL_INSTALL_DIR)
		[ -d $(LOCAL_IMPORT_DIR)  ] || mkdir -p $(LOCAL_IMPORT_DIR)
		cp -f  $(PKG_LIB)    $(LOCAL_INSTALL_DIR)
		tar cvf - $(PKG_HI) | ( cd $(LOCAL_IMPORT_DIR) ; tar xf - )
		[ -f $(LOCAL_INSTALL_DIR)/package.conf ] || echo "[]" > $(LOCAL_INSTALL_DIR)/package.conf
		cat $(PKG_NAME)-package.conf \
		| ghc-pkg update - --package-conf=$(LOCAL_INSTALL_DIR)/package.conf
		@echo use package with: ghc\(i\) ... -package-conf $(LOCAL_INSTALL_DIR)/package.conf -package $(PKG_NAME) ...

GHC_INSTALL	= $(shell ghc -v 2>&1 | head -n 2 | tail -n 1 | cut -d " " -f 5 | sed 's|/package.conf||')
GHC_INSTALL_DIR	= $(GHC_INSTALL)/$(SOFTWARE)
GHC_PKG_CONF	=

install		: $(SOFTWARE)-package.conf
		@[ -d $(GHC_INSTALL)     ] || ( echo "ghc install dir not found"       1>&2 ; exit 1 )
		@[ -w $(GHC_INSTALL)     ] || ( echo "you need root access for this target" ; exit 1 )
		[ -d $(GHC_INSTALL_DIR) ] || mkdir -p $(GHC_INSTALL_DIR)
		cp -r $(LOCAL_INSTALL_DIR)/*.[ao] $(LOCAL_INSTALL_DIR)/imports $(GHC_INSTALL_DIR)
		$(MAKE) install_packages
		@echo
		@echo use package with: ghc\(i\) ... -package $(MXT_PACKAGE) ...

uninstall	:
		@[ -d $(GHC_INSTALL) ] || ( echo "ghc install dir not found"       1>&2 ; exit 1 )
		@[ -w $(GHC_INSTALL) ] || ( echo "you need root access for this target" ; exit 1 )
		$(MAKE) uninstall_packages
		rm -rf $(GHC_INSTALL_DIR)

# ------------------------------------------------------------

all		:
		$(MAKE) install_local_$(MXT_PACKAGE)

$(SOFTWARE)-package.conf	: $(SOFTWARE)-package.hs
		ghc -o $(SOFTWARE)-package $(SOFTWARE)-package.hs
		./$(SOFTWARE)-package $(VERSION) "ghc" $(LOCAL_INSTALL_DIR) $(MXT_SRC) > $@

../$(SOFTWARE).cabal	: $(SOFTWARE)-package.hs Makefile ../Makefile
		ghc -o $(SOFTWARE)-package $(SOFTWARE)-package.hs
		./$(SOFTWARE)-package $(VERSION) "cabal" $(GHC_INSTALL_DIR) $(MXT_SRC) > $@

install_packages	:
		runghc $(SOFTWARE)-package.hs $(VERSION) "ghc" $(GHC_INSTALL_DIR) $(MXT_SRC) \
		| ghc-pkg --update-package

uninstall_packages	:
		ghc-pkg --remove-package $(MXT_PACKAGE) || true

clean_packages	:
		$(MAKE) clean_$(MXT_PACKAGE)

clean		:
		$(MAKE) clean_packages
		$(MAKE) -C ./Text/XML/MXT/ProtocolHandler clean
		rm -rf $(LOCAL_INSTALL_DIR) $(SOFTWARE)-package.conf ../$(SOFTWARE).cabal

clean_$(MXT_PACKAGE)	:
		$(RM) $(MXT_DRIVER) $(MXT_DRIVER:.o=.hi) $(MXT_OBJ) $(MXT_HI) $(MXT_LIB)

# ------------------------------------------------------------

DIST		= ../$(DIST_NAME)
DIST_DIR	= $(DIST)/src
DIST_FILES	= Makefile \
		  $(MXT_SRC) $(MXT_DRIVER:.o=.hs) $(SOFTWARE)-package.hs \
		  ./Text/XML/MXT/ProtocolHandler/ProtocolHandler.hs \
		  ./Text/XML/MXT/ProtocolHandler/Makefile


dist		:
		[ -d $(DIST_DIR) ] || mkdir -p $(DIST_DIR)
		tar cvf - $(DIST_FILES) | ( cd $(DIST_DIR) ; tar xf - )

.PHONY		: all install doc clean dist

# eof ------------------------------------------------------------
