-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.Core
   Copyright  : Copyright (C) 2006-2010 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   The MXT arrow interface

   The application programming interface to the arrow modules of the Haskell XML Toolbox.
   This module exports all important arrows for input, output, parsing, validating and transforming XML.
   It also exports all basic datatypes and functions of the toolbox.

-}

-- ------------------------------------------------------------

module Text.XML.MXT.Core
    ( module Control.Arrow.ListArrows

    , module Text.XML.MXT.DOM.Interface

    , module Text.XML.MXT.Arrow.XmlArrow
    , module Text.XML.MXT.Arrow.XmlState

    , module Text.XML.MXT.Arrow.DocumentInput
    , module Text.XML.MXT.Arrow.DocumentOutput
    , module Text.XML.MXT.Arrow.Edit
    , module Text.XML.MXT.Arrow.GeneralEntitySubstitution
    , module Text.XML.MXT.Arrow.Namespace
    , module Text.XML.MXT.Arrow.Pickle
    , module Text.XML.MXT.Arrow.ProcessDocument
    , module Text.XML.MXT.Arrow.ReadDocument
    , module Text.XML.MXT.Arrow.WriteDocument
    , module Text.XML.MXT.Arrow.Binary
    , module Text.XML.MXT.Arrow.XmlOptions

    , module Text.XML.MXT.Version
    )
where

import Control.Arrow.ListArrows                 -- arrow classes

import Data.Atom ()                             -- import this explicitly

import Text.XML.MXT.DOM.Interface

import Text.XML.MXT.Arrow.DocumentInput
import Text.XML.MXT.Arrow.DocumentOutput
import Text.XML.MXT.Arrow.Edit
import Text.XML.MXT.Arrow.GeneralEntitySubstitution
import Text.XML.MXT.Arrow.Namespace
import Text.XML.MXT.Arrow.Pickle
import Text.XML.MXT.Arrow.ProcessDocument
import Text.XML.MXT.Arrow.ReadDocument
import Text.XML.MXT.Arrow.WriteDocument
import Text.XML.MXT.Arrow.XmlArrow
import Text.XML.MXT.Arrow.XmlOptions
import Text.XML.MXT.Arrow.XmlState
import Text.XML.MXT.Arrow.XmlRegex ()           -- import this explicitly
import Text.XML.MXT.Arrow.Binary

import Text.XML.MXT.Version

-- ------------------------------------------------------------
