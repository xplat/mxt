MIMETYPES	= /etc/mime.types

all	: MimeTypeDefaults.hs

MimeTypeDefaults.hs	: GenMimeTypeTable.hs $(MIMETYPES) Makefile
	runghc GenMimeTypeTable.hs $(MIMETYPES) > $@ && ghc -Wall -c $@

install	: all
	cat MimeTypeDefaults.hs | \
	sed 's|MimeTypeDefaults|Text.XML.MXT.DOM.MimeTypeDefaults|' > \
	../../src/Text/XML/MXT/DOM/MimeTypeDefaults.hs

