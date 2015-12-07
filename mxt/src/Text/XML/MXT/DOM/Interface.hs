-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.DOM.Interface
   Copyright  : Copyright (C) 2008 Uwe Schmidt
   License    : MIT


   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   The interface to the primitive DOM data types and constants
   and utility functions

-}

-- ------------------------------------------------------------

module Text.XML.MXT.DOM.Interface
    ( module Text.XML.MXT.DOM.XmlKeywords
    , module Text.XML.MXT.DOM.TypeDefs
    , module Text.XML.MXT.DOM.Util
    , module Text.XML.MXT.DOM.MimeTypes
    , module Data.String.EncodingNames
    )
where

import Text.XML.MXT.DOM.XmlKeywords             -- constants
import Text.XML.MXT.DOM.TypeDefs                -- XML Tree types
import Text.XML.MXT.DOM.Util
import Text.XML.MXT.DOM.MimeTypes               -- mime types related stuff

import Data.String.EncodingNames                -- char encoding names for readDocument

-- ------------------------------------------------------------
