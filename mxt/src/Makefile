# ------------------------------------------------------------
#
# global names and dirs

include ../Version.mk

MXT_HOME	= ..
MXT_HOME_PATH	= $(shell cd $(MXT_HOME) ; pwd)
PACKAGE_DIR	= $(MXT_HOME_PATH)/lib/mxt
HDOC_DIR	= $(MXT_HOME)/doc/hdoc
HDOC_DIR_ARROW	= $(MXT_HOME)/doc/hdoc_arrow
HDOC_DIR_FILTER	= $(MXT_HOME)/doc/hdoc_filter
IMPORT_DIR	= imports
MXT_PACKAGE	= mxt

# ------------------------------------------------------------
#
# commands

GHCFLAGS	= -Wall -O2 -fglasgow-exts -ignore-package $(MXT_PACKAGE)
GHC             = ghc $(GHCFLAGS)
GHCVERSION	=  $(shell ghc -v 2>&1 | head -n 2 | tail -n 1 | cut -d " " -f 5 | sed 's|^.*ghc-\([0-9.]*\)/package.conf|\1|')

MXT_PACKAGE_NAME=$(MXT_PACKAGE)-$(VERSION)

HDOCFLAGS	= -v -v -v -h
HDOC            = haddock $(HDOCFLAGS)

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
# Unicode Codeblocks and Char Properties generated from Unicode DB

./Text/XML/MXT/RelaxNG/Unicode/Blocks.hs ./Text/XML/MXT/RelaxNG/Unicode/CharProps.hs	:
		$(MAKE) -C ./Text/XML/MXT/RelaxNG/Unicode all

# ------------------------------------------------------------
#
# mxt package variables and rules

MXT_SRC	= \
	Control/Arrow/ArrowIf.hs \
	Control/Arrow/ArrowIO.hs \
	Control/Arrow/ArrowList.hs \
	Control/Arrow/ArrowNF.hs \
	Control/Arrow/ArrowState.hs \
	Control/Arrow/ArrowTree.hs \
	Control/Arrow/IOListArrow.hs \
	Control/Arrow/IOStateListArrow.hs \
	Control/Arrow/ListArrow.hs \
	Control/Arrow/ListArrows.hs \
	Control/Arrow/StateListArrow.hs \
	Data/AssocList.hs \
	Data/Atom.hs \
	Data/Char/UTF8.hs \
	Data/NavTree.hs \
	Data/Tree/Class.hs \
	Data/Tree/NTree/TypeDefs.hs \
	Text/XML/MXT/Arrow/DocumentInput.hs \
	Text/XML/MXT/Arrow/DocumentOutput.hs \
	Text/XML/MXT/Arrow/DTDProcessing.hs \
	Text/XML/MXT/Arrow/Edit.hs \
	Text/XML/MXT/Arrow/GeneralEntitySubstitution.hs \
	Text/XML/MXT/Arrow.hs \
	Text/XML/MXT/Arrow/Namespace.hs \
	Text/XML/MXT/Arrow/ParserInterface.hs \
	Text/XML/MXT/Arrow/Pickle/DTD.hs \
	Text/XML/MXT/Arrow/Pickle.hs \
	Text/XML/MXT/Arrow/Pickle/Schema.hs \
	Text/XML/MXT/Arrow/Pickle/Xml.hs \
	Text/XML/MXT/Arrow/ProcessDocument.hs \
	Text/XML/MXT/Arrow/ReadDocument.hs \
	Text/XML/MXT/Arrow/WriteDocument.hs \
	Text/XML/MXT/Arrow/XmlArrow.hs \
	Text/XML/MXT/Arrow/XmlIOStateArrow.hs \
	Text/XML/MXT/Arrow/XmlRegex.hs \
	Text/XML/MXT/Arrow/XPath.hs \
	Text/XML/MXT/Arrow/XPathSimple.hs \
	Text/XML/MXT/DOM/FormatXmlTree.hs \
	Text/XML/MXT/DOM/Interface.hs \
	Text/XML/MXT/DOM/IsoLatinTables.hs \
	Text/XML/MXT/DOM/MimeTypeDefaults.hs \
	Text/XML/MXT/DOM/MimeTypes.hs \
	Text/XML/MXT/DOM/QualifiedName.hs \
	Text/XML/MXT/DOM/ShowXml.hs \
	Text/XML/MXT/DOM/TypeDefs.hs \
	Text/XML/MXT/DOM/Unicode.hs \
	Text/XML/MXT/DOM/UTF8Decoding.hs \
	Text/XML/MXT/DOM/Util.hs \
	Text/XML/MXT/DOM/XmlKeywords.hs \
	Text/XML/MXT/DOM/XmlNode.hs \
	Text/XML/MXT/DOM/XmlOptions.hs \
	Text/XML/MXT/DTDValidation/AttributeValueValidation.hs \
	Text/XML/MXT/DTDValidation/DocTransformation.hs \
	Text/XML/MXT/DTDValidation/DocValidation.hs \
	Text/XML/MXT/DTDValidation/DTDValidation.hs \
	Text/XML/MXT/DTDValidation/IdValidation.hs \
	Text/XML/MXT/DTDValidation/RE.hs \
	Text/XML/MXT/DTDValidation/TypeDefs.hs \
	Text/XML/MXT/DTDValidation/Validation.hs \
	Text/XML/MXT/DTDValidation/XmlRE.hs \
	Text/XML/MXT/IO/GetFILE.hs \
	Text/XML/MXT/IO/GetHTTPLibCurl.hs \
	Text/XML/MXT/Parser/HtmlParsec.hs \
	Text/XML/MXT/Parser/ProtocolHandlerUtil.hs \
	Text/XML/MXT/Parser/TagSoup.hs \
	Text/XML/MXT/Parser/XhtmlEntities.hs \
	Text/XML/MXT/Parser/XmlCharParser.hs \
	Text/XML/MXT/Parser/XmlDTDParser.hs \
	Text/XML/MXT/Parser/XmlDTDTokenParser.hs \
	Text/XML/MXT/Parser/XmlEntities.hs \
	Text/XML/MXT/Parser/XmlParsec.hs \
	Text/XML/MXT/Parser/XmlTokenParser.hs \
	Text/XML/MXT/RelaxNG/BasicArrows.hs \
	Text/XML/MXT/RelaxNG/CreatePattern.hs \
	Text/XML/MXT/RelaxNG/DataTypeLibMysql.hs \
	Text/XML/MXT/RelaxNG/DataTypeLibraries.hs \
	Text/XML/MXT/RelaxNG/DataTypeLibUtils.hs \
	Text/XML/MXT/RelaxNG/DataTypes.hs \
	Text/XML/MXT/RelaxNG.hs \
	Text/XML/MXT/RelaxNG/PatternFunctions.hs \
	Text/XML/MXT/RelaxNG/PatternToString.hs \
	Text/XML/MXT/RelaxNG/SchemaGrammar.hs \
	Text/XML/MXT/RelaxNG/Schema.hs \
	Text/XML/MXT/RelaxNG/Simplification.hs \
	Text/XML/MXT/RelaxNG/Unicode/Blocks.hs \
	Text/XML/MXT/RelaxNG/Unicode/CharProps.hs \
	Text/XML/MXT/RelaxNG/Utils.hs \
	Text/XML/MXT/RelaxNG/Validation.hs \
	Text/XML/MXT/RelaxNG/Validator.hs \
	Text/XML/MXT/RelaxNG/XmlSchema/DataTypeLibW3C.hs \
	Text/XML/MXT/RelaxNG/XmlSchema/Regex.hs \
        Text/XML/MXT/RelaxNG/XmlSchema/RegexMatch.hs \
	Text/XML/MXT/RelaxNG/XmlSchema/RegexParser.hs \
	Text/XML/MXT/Version.hs \
	Text/XML/MXT/XPath.hs \
	Text/XML/MXT/XPath/NavTree.hs \
	Text/XML/MXT/XPath/XPathArithmetic.hs \
	Text/XML/MXT/XPath/XPathDataTypes.hs \
	Text/XML/MXT/XPath/XPathEval.hs \
	Text/XML/MXT/XPath/XPathFct.hs \
	Text/XML/MXT/XPath/XPathKeywords.hs \
	Text/XML/MXT/XPath/XPathParser.hs \
	Text/XML/MXT/XPath/XPathToNodeSet.hs \
	Text/XML/MXT/XPath/XPathToString.hs


# no longer in use	System/PipeOpen.hs
# no longer in use	Text/XML/MXT/IO/GetHTTPNative.hs
# no longer in use	Text/XML/MXT/IO/GetHTTPCurl.hs

Text/XML/MXT/Version.hs	: ../mxt.cabal
		( echo "module Text.XML.MXT.Version" \
		; echo "where" \
		; echo "mxt_version :: String" \
		; echo "mxt_version = \"$$(cat ../mxt.cabal | grep -i '^version:' | cut -d ' ' -f 2)\"" \
		) > $@

MXT_OBJ		= $(MXT_SRC:.hs=.o)
MXT_HI		= $(MXT_SRC:.hs=.hi)

MXT_DRIVER	= MXT.o
MXT_LIBA	= libHS$(MXT_PACKAGE).a
MXT_LIBO	= HS$(MXT_PACKAGE).o
MXT_LIB		= $(MXT_LIBA) $(MXT_LIBO)
MXT_REQ_PKG	= -package parsec -package curl -package tagsoup

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

doc           : $(MXT_SRC)
		[ -d $(HDOC_DIR) ] || mkdir -p $(HDOC_DIR)
		$(HDOC) -t "Haskell Xml Toolbox $(VERSION): The complete API" -o $(HDOC_DIR) $(MXT_SRC)

# ------------------------------------------------------------

DIST		= ../$(DIST_NAME)
DIST_DIR	= $(DIST)/src
DIST_FILES	= Makefile \
		  $(MXT_SRC) $(MXT_DRIVER:.o=.hs) mxt-package.hs \
		  $(wildcard ./Text/XML/MXT/RelaxNG/Unicode/G*.hs) \
		  $(wildcard ./Text/XML/MXT/RelaxNG/Unicode/Makefile) \
		  $(wildcard ./Text/XML/MXT/RelaxNG/Unicode/*.txt)

dist		:
		[ -d $(DIST_DIR) ] || mkdir -p $(DIST_DIR)
		tar cvf - $(DIST_FILES) | ( cd $(DIST_DIR) ; tar xf - )

.PHONY		: all install doc clean dist

# eof ------------------------------------------------------------
