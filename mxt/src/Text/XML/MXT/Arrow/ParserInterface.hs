-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.Arrow.ParserInterface
   Copyright  : Copyright (C) 2010 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   interface to the MXT XML and DTD parsers
-}

-- ------------------------------------------------------------

module Text.XML.MXT.Arrow.ParserInterface
    ( module Text.XML.MXT.Arrow.ParserInterface )
where

import Control.Arrow.ArrowList

import Text.XML.MXT.DOM.Interface
import Text.XML.MXT.Arrow.XmlArrow

import qualified Text.XML.MXT.Parser.HtmlParsec          as HP
import qualified Text.XML.MXT.Parser.XmlParsec           as XP
import qualified Text.XML.MXT.Parser.XmlDTDParser        as DP

-- ------------------------------------------------------------

parseXmlDoc                     :: ArrowXml a => a (String, String) XmlTree
parseXmlDoc                     =  arr2L XP.parseXmlDocument

parseXmlDTDPart                 :: ArrowXml a => a (String, XmlTree) XmlTree
parseXmlDTDPart                 =  arr2L XP.parseXmlDTDPart

xreadCont                       :: ArrowXml a => a String XmlTree
xreadCont                       =  arrL XP.xread

xreadDoc                        :: ArrowXml a => a String XmlTree
xreadDoc                        =  arrL XP.xreadDoc

parseXmlEntityEncodingSpec
  , parseXmlDocEncodingSpec
  , removeEncodingSpec          :: ArrowXml a => a XmlTree XmlTree

parseXmlDocEncodingSpec         =  arrL XP.parseXmlDocEncodingSpec
parseXmlEntityEncodingSpec      =  arrL XP.parseXmlEntityEncodingSpec

removeEncodingSpec              =  arrL XP.removeEncodingSpec

parseXmlDTDdeclPart             :: ArrowXml a => a XmlTree XmlTree
parseXmlDTDdeclPart             =  arrL DP.parseXmlDTDdeclPart

parseXmlDTDdecl                 :: ArrowXml a => a XmlTree XmlTree
parseXmlDTDdecl                 =  arrL DP.parseXmlDTDdecl

parseXmlDTDEntityValue          :: ArrowXml a => a XmlTree XmlTree
parseXmlDTDEntityValue          =  arrL DP.parseXmlDTDEntityValue

parseXmlEntityValueAsContent    :: ArrowXml a => String -> a XmlTree XmlTree
parseXmlEntityValueAsContent    =  arrL . XP.parseXmlEntityValueAsContent

parseXmlEntityValueAsAttrValue  :: ArrowXml a => String -> a XmlTree XmlTree
parseXmlEntityValueAsAttrValue  =  arrL . XP.parseXmlEntityValueAsAttrValue

-- ------------------------------------------------------------

parseHtmlDoc                    :: ArrowList a => a (String, String) XmlTree
parseHtmlDoc                    = arr2L HP.parseHtmlDocument

hread                           :: ArrowList a => a String XmlTree
hread                           = arrL   HP.parseHtmlContent

hreadDoc                        :: ArrowList a => a String XmlTree
hreadDoc                        = arrL $ HP.parseHtmlDocument "string"

-- ------------------------------------------------------------
