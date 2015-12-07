-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.Expat
   Copyright  : Copyright (C) 2010 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   Interface for Expat XML Parser

-}

-- ------------------------------------------------------------

module Text.XML.MXT.Expat
    ( withExpat
    , withoutExpat
    , issueExpatErr
    )
where

import Text.XML.MXT.Arrow.ExpatInterface

-- ------------------------------------------------------------
