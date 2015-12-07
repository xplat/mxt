-- ------------------------------------------------------------

module Text.XML.MXT.Monad.ParserInterface
    ( module Text.XML.MXT.Monad.ParserInterface )
where

import           Control.Monad.Arrow

import           Text.XML.MXT.DOM.Interface
import qualified Text.XML.MXT.Parser.HtmlParsec   as HP
import qualified Text.XML.MXT.Parser.XmlDTDParser as DP
import qualified Text.XML.MXT.Parser.XmlParsec    as XP

-- ------------------------------------------------------------

parseXmlDoc                     :: MonadSeq m => (String, String) -> m XmlTree
parseXmlDoc                     =  arr2L XP.parseXmlDocument

parseXmlDTDPart                 :: MonadSeq m => (String, XmlTree) -> m XmlTree
parseXmlDTDPart                 =  arr2L XP.parseXmlDTDPart

parseXmlContent                 :: MonadSeq m => String -> m XmlTree
parseXmlContent                 =  arrL XP.xread

parseXmlEntityEncodingSpec
  , parseXmlDocEncodingSpec
  , removeEncodingSpec          :: MonadSeq m => XmlTree -> m XmlTree

parseXmlDocEncodingSpec         =  arrL XP.parseXmlDocEncodingSpec
parseXmlEntityEncodingSpec      =  arrL XP.parseXmlEntityEncodingSpec

removeEncodingSpec              =  arrL XP.removeEncodingSpec

parseXmlDTDdeclPart             :: MonadSeq m => XmlTree -> m XmlTree
parseXmlDTDdeclPart             =  arrL DP.parseXmlDTDdeclPart

parseXmlDTDdecl                 :: MonadSeq m => XmlTree -> m XmlTree
parseXmlDTDdecl                 =  arrL DP.parseXmlDTDdecl

parseXmlDTDEntityValue          :: MonadSeq m => XmlTree -> m XmlTree
parseXmlDTDEntityValue          =  arrL DP.parseXmlDTDEntityValue

parseXmlEntityValueAsContent    :: MonadSeq m => String -> XmlTree -> m XmlTree
parseXmlEntityValueAsContent    =  arrL . XP.parseXmlEntityValueAsContent

parseXmlEntityValueAsAttrValue  :: MonadSeq m => String -> XmlTree -> m XmlTree
parseXmlEntityValueAsAttrValue  =  arrL . XP.parseXmlEntityValueAsAttrValue

-- ------------------------------------------------------------

parseHtmlDoc                    :: MonadSeq m => (String, String) -> m XmlTree
parseHtmlDoc                    = arr2L HP.parseHtmlDocument

parseHtmlContent                :: MonadSeq m => String -> m XmlTree
parseHtmlContent                = arrL  HP.parseHtmlContent

-- ------------------------------------------------------------
