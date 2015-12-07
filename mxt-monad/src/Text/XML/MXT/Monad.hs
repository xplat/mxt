-- ------------------------------------------------------------

{- |
   The MXT interface based on monads

   The application programming interface
   to the monad base modules of the Haskell XML Toolbox.
   This module exports all important arrows for input,
   output, parsing, validating and transforming XML.
   It also exports all basic datatypes and functions of the toolbox.
-}

-- ------------------------------------------------------------

module Text.XML.MXT.Monad
    ( module Control.Monad
    , module Control.Monad.Arrow
    , module Data.Sequence.ArrowTypes
    , module Text.XML.MXT.DOM.Interface
    , module Text.XML.MXT.Monad.ArrowXml
    , module Text.XML.MXT.Monad.XmlState
    , module Text.XML.MXT.Monad.DocumentInput
    , module Text.XML.MXT.Monad.DocumentOutput
    , module Text.XML.MXT.Monad.Edit
    , module Text.XML.MXT.Monad.GeneralEntitySubstitution
    , module Text.XML.MXT.Monad.Namespace
    , module Text.XML.MXT.Monad.Pickle
    , module Text.XML.MXT.Monad.ProcessDocument
    , module Text.XML.MXT.Monad.ReadDocument
    , module Text.XML.MXT.Monad.WriteDocument
    , module Text.XML.MXT.Monad.Binary
    , module Text.XML.MXT.Monad.XmlOptions
    )
where

import           Control.Monad
import           Control.Monad.Arrow

import           Data.Atom                                    ()
import           Data.Sequence.ArrowTypes

import           Text.XML.MXT.DOM.Interface
import           Text.XML.MXT.Monad.ArrowXml
import           Text.XML.MXT.Monad.Binary
import           Text.XML.MXT.Monad.DocumentInput
import           Text.XML.MXT.Monad.DocumentOutput
import           Text.XML.MXT.Monad.Edit
import           Text.XML.MXT.Monad.GeneralEntitySubstitution
import           Text.XML.MXT.Monad.Namespace
import           Text.XML.MXT.Monad.Pickle
import           Text.XML.MXT.Monad.ProcessDocument
import           Text.XML.MXT.Monad.ReadDocument
import           Text.XML.MXT.Monad.WriteDocument
import           Text.XML.MXT.Monad.XmlOptions
import           Text.XML.MXT.Monad.XmlRegex                  ()
import           Text.XML.MXT.Monad.XmlState

-- ------------------------------------------------------------
