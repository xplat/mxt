-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.TagSoup
   Copyright  : Copyright (C) 2010 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   Interface for TagSoup Parser

-}

-- ------------------------------------------------------------

module Text.XML.MXT.TagSoup
    ( module Text.XML.MXT.Arrow.TagSoupInterface
    , module Text.XML.MXT.TagSoup
    )
where

import           System.Console.GetOpt

import           Text.XML.MXT.Arrow.TagSoupInterface
import           Text.XML.MXT.Arrow.XmlState

-- ------------------------------------------------------------

a_tagsoup                       :: String
a_tagsoup                       = "tagsoup"

tagSoupOptions                  ::  [OptDescr SysConfig]
tagSoupOptions
    = [ Option "T" [a_tagsoup] (NoArg withTagSoup)
        "lazy tagsoup parser, for HTML and XML, no DTD, no validation, no PIs, only XHTML entityrefs"
      ]

-- ------------------------------------------------------------
