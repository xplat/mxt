-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.Arrow.Compat8
   Copyright  : Copyright (C) 2010 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   compatibility module for MXT-8.5

-}

-- ------------------------------------------------------------

module Text.XML.MXT.Arrow.Compat8
    ( module Text.XML.MXT.Arrow.Compat8
    , module Text.XML.MXT.Arrow
    )
where

import Text.XML.MXT.Arrow hiding ( readDocument
                                 , readFromDocument
                                 , readString
                                 , readFromString
                                 , xunpickleDocument
                                 )

import qualified Text.XML.MXT.Arrow as X

-- ------------------------------------------------------------

optionToSysConfig		:: (String, String) -> SysConfig
optionToSysConfig (n, v)
    | n == a_trace              	= withTrace      	    (toInt 0 v)
    | n == a_issue_warnings		= withWarnings        	    (isTrueValue v)
    | n == a_issue_errors		= withErrors        	    (isTrueValue v)
    | n == a_remove_whitespace		= withRemoveWS        	    (isTrueValue v)
    | n == a_preserve_comment   	= withPreserveComment 	    (isTrueValue v) 
    | n == a_parse_by_mimetype  	= withParseByMimeType 	    (isTrueValue v)
    | n == a_mime_types                 = withMimeTypeFile           v
    | n == a_parse_html         	= withParseHTML       	    (isTrueValue v)
    | n == a_validate           	= withValidate        	    (isTrueValue v)
    | n == a_check_namespaces   	= withCheckNamespaces 	    (isTrueValue v)
    | n == a_canonicalize       	= withCanonicalize    	    (isTrueValue v)
    | n == a_ignore_none_xml_contents   = withIgnoreNoneXmlContents (isTrueValue v)
    | n == a_accept_mimetypes           = withAcceptedMimeTypes     (words v)
    | n == a_tagsoup                    = withTagSoup               (isTrueValue v)
    | n == a_ignore_encoding_errors v_1 = withEncodingErrors        (not $ isTrueValue v)
    | n == transferURI                  = withDefaultBaseURI         v
    | n == a_proxy                      = withProxy                  v
    | n == a_use_curl                   = if isTrueValue v
                                          then withCurl
                                          else id
    | "curl-" `isPrefixOf` n            = withInputOption (drop 5 n) v
    | n == a_redirect                   = withRedirect              (isTrueValue v)
    | otherwise				= withAttr                  (addEntry n v)
    where
    toInt				:: Int -> String -> Int
    toInt def s
        | not (null s) && all isDigit s	= read s
        | otherwise                     = def

-- ------------------------------------------------------------

{- |
the main document input filter

this filter can be configured by an option list, a value of type 'Text.XML.MXT.DOM.TypeDefs.Attributes'

available options:

* 'a_parse_html': use HTML parser, else use XML parser (default)

- 'a_tagsoup' : use light weight and lazy parser based on tagsoup lib

- 'a_parse_by_mimetype' : select the parser by the mime type of the document
                          (pulled out of the HTTP header). When the mime type is set to \"text\/html\"
                          the HTML parser (parsec or tagsoup) is taken, when it\'s set to
                          \"text\/xml\" or \"text\/xhtml\" the XML parser (parsec or tagsoup) is taken.
                          If the mime type is something else no further processing is performed,
                          the contents is given back to the application in form of a single text node.
                          If the default document encoding ('a_encoding') is set to isoLatin1, this even enables processing
                          of arbitray binary data.

- 'a_validate' : validate document againsd DTD (default), else skip validation

- 'a_relax_schema' : validate document with Relax NG, the options value is the schema URI
                     this implies using XML parser, no validation against DTD, and canonicalisation

- 'a_check_namespaces' : check namespaces, else skip namespace processing (default)

- 'a_canonicalize' : canonicalize document (default), else skip canonicalization

- 'a_preserve_comment' : preserve comments during canonicalization, else remove comments (default)

- 'a_remove_whitespace' : remove all whitespace, used for document indentation, else skip this step (default)

- 'a_indent' : indent document by inserting whitespace, else skip this step (default)

- 'a_issue_warnings' : issue warnings, when parsing HTML (default), else ignore HTML parser warnings

- 'a_issue_errors' : issue all error messages on stderr (default), or ignore all error messages

- 'a_ignore_encoding_errors': ignore all encoding errors, default is issue all encoding errors

- 'a_ignore_none_xml_contents': ignore document contents of none XML\/HTML documents.
                                This option can be useful for implementing crawler like applications, e.g. an URL checker.
                                In those cases net traffic can be reduced.

- 'a_trace' : trace level: values: 0 - 4

- 'a_proxy' : proxy for http access, e.g. www-cache:3128

- 'a_redirect' : automatically follow redirected URIs, default is yes

- 'a_use_curl' : obsolete and ignored, HTTP acccess is always done with curl bindings for libcurl

- 'a_strict_input' : file input is done strictly using the 'Data.ByteString' input functions. This ensures correct closing of files, especially when working with
                     the tagsoup parser and not processing the whole input data. Default is off. The @ByteString@ input usually is not faster than the buildin @hGetContents@
                     for strings.

- 'a_options_curl' : deprecated but for compatibility reasons still supported.
                     More options passed to the curl binding.
                     Instead of using this option to set a whole bunch of options at once for curl
                     it is recomended to use the @curl-.*@ options syntax described below.

- 'a_encoding' : default document encoding ('utf8', 'isoLatin1', 'usAscii', 'iso8859_2', ... , 'iso8859_16', ...).
                 Only XML, HTML and text documents are decoded,
                 default decoding for XML\/HTML is utf8, for text iso latin1 (no decoding).
                 The whole content is returned in a single text node.

- 'a_mime_types' : set the mime type table for file input with given file. The format of this config file must be in the syntax of a debian linux \"mime.types\" config file

- 'a_if_modified_since' : read document conditionally, only if the document is newer than the given date and time argument, the contents is delivered,
                          else just the root node with the meta data is returned. The date and time must be given in "System.Locale.rfc822DateFormat".

- curl options : the HTTP interface with libcurl can be configured with a lot of options. To support these options in an easy way, there is a naming convetion:
                 Every option, which has the prefix @curl@ and the rest of the name forms an option as described in the curl man page, is passed to the curl binding lib.
                 See 'Text.XML.MXT.IO.GetHTTPLibCurl.getCont' for examples. Currently most of the options concerning HTTP requests are implemented.

All attributes not evaluated by readDocument are stored in the created document root node for easy access of the various
options in e.g. the input\/output modules

If the document name is the empty string or an uri of the form \"stdin:\", the document is read from standard input.

examples:

> readDocument [ ] "test.xml"

reads and validates a document \"test.xml\", no namespace propagation, only canonicalization is performed

> readDocument [ (a_validate, "0")
>              , (a_encoding, isoLatin1)
>              , (a_parse_by_mimetype, "1")
>              ] "http://localhost/test.php"

reads document \"test.php\", parses it as HTML or XML depending on the mimetype given from the server, but without validation, default encoding 'isoLatin1'.


> readDocument [ (a_parse_html, "1")
>              , (a_encoding, isoLatin1)
>              ] ""

reads a HTML document from standard input, no validation is done when parsing HTML, default encoding is 'isoLatin1',
parsing is done with tagsoup parser, but input is read strictly

> readDocument [ (a_encoding, isoLatin1)
>              , (a_mime_type,    "/etc/mime.types")
>              , (a_tagsoup,      "1")
>              , (a_strict_input, "1")
>              ] "test.svg"

reads an SVG document from standard input, sets the mime type by looking in the system mimetype config file, default encoding is 'isoLatin1',
parsing is done with the lightweight tagsoup parser, which implies no validation.

> readDocument [ (a_parse_html,     "1")
>              , (a_proxy,          "www-cache:3128")
>              , (a_curl,           "1")
>              , (a_issue_warnings, "0")
>              ] "http://www.haskell.org/"

reads Haskell homepage with HTML parser ignoring any warnings, with http access via external program curl and proxy \"www-cache\" at port 3128

> readDocument [ (a_validate,          "1")
>              , (a_check_namespace,   "1")
>              , (a_remove_whitespace, "1")
>              , (a_trace,             "2")
>              ] "http://www.w3c.org/"

read w3c home page (xhtml), validate and check namespaces, remove whitespace between tags, trace activities with level 2

for minimal complete examples see 'Text.XML.MXT.Arrow.WriteDocument.writeDocument' and 'runX', the main starting point for running an XML arrow.
-}

readDocument    :: Attributes -> String -> IOStateArrow s b XmlTree
readDocument userOptions src
    = X.readDocument (map optionToSysConfig $ userOptions) src

readFromDocument        :: Attributes -> IOStateArrow s String XmlTree
readFromDocument userOptions
    = applyA ( arr $ readDocument userOptions )

readString      :: Attributes -> String -> IOStateArrow s b XmlTree
readString userOptions content
    = readDocument ( (a_encoding, unicodeString) : userOptions ) (stringProtocol ++ content)

readFromString  :: Attributes -> IOStateArrow s String XmlTree
readFromString userOptions
    = applyA ( arr $ readString userOptions )


-- ------------------------------------------------------------

xunpickleDocument       :: PU a -> Attributes -> String -> IOStateArrow s b a
xunpickleDocument xp al src
                        = readDocument al src
                          >>>
                          traceMsg 1 ("xunpickleVal for " ++ show src ++ " started")
                          >>>
                          xunpickleVal xp
                          >>>
                          traceMsg 1 ("xunpickleVal for " ++ show src ++ " finished")

-- ------------------------------------------------------------
