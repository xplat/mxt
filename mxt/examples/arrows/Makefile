# $Id: Makefile,v 1.9 2006/11/12 14:52:59 hxml Exp $
#
# Example Applications
#

EXAMPLES	= \
		HelloWorld hparser hunit dtd2mxt absurls \
		pickle \
		hrelaxng \
		RelaxTestSuite \
		AGentleIntroductionToMXT \
		performance

MXT_HOME	= ../..
PKGFLAGS	=
DIST		= $(MXT_HOME)/dist/examples
DIST_DIR	= $(DIST)/arrows

all		:
		$(foreach i,$(EXAMPLES),$(MAKE) -C $i PKGFLAGS="$(PKGFLAGS)" $@ ;)

test		:
		$(foreach i,$(EXAMPLES),$(MAKE) -C $i $@ ;)

clean		:
		$(foreach i,$(EXAMPLES),$(MAKE) -C $i $@ ;)

.PHONY		: all clean test dist

