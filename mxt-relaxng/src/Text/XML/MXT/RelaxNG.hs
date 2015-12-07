-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.RelaxNG
   Copyright  : Copyright (C) 2010 Uwe Schmidt, Torben Kuseler
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   This helper module exports elements from the basic Relax NG libraries:
   Validator, CreatePattern, PatternToString and DataTypes.
   It is the main entry point to the Relax NG schema validator of the Haskell
   XML Toolbox.

-}

-- ------------------------------------------------------------

module Text.XML.MXT.RelaxNG
  ( module Text.XML.MXT.RelaxNG.PatternToString
  , module Text.XML.MXT.RelaxNG.Validator
  , module Text.XML.MXT.RelaxNG.DataTypes
  , module Text.XML.MXT.RelaxNG.CreatePattern
  , module Text.XML.MXT.RelaxNG.SystemConfig
  )
where

import Text.XML.MXT.RelaxNG.PatternToString
import Text.XML.MXT.RelaxNG.Validator
import Text.XML.MXT.RelaxNG.DataTypes
import Text.XML.MXT.RelaxNG.CreatePattern
import Text.XML.MXT.RelaxNG.SystemConfig

-- ------------------------------------------------------------

