-- |
-- Simple parse functions.
--
-- the "main" building blocks for an application.
-- this module exports all important functions for parsing, validating and transforming XML.
-- it also exports all basic datatypes and functions of the toolbox.
--

module Text.XML.MXT.Parser
    ( module Text.XML.MXT.DOM

    , module Text.XML.MXT.Parser.XmlParser
    , module Text.XML.MXT.Parser.HtmlParser
    , module Text.XML.MXT.Parser.XmlInput
    , module Text.XML.MXT.Parser.XmlOutput
    , module Text.XML.MXT.Parser.DTDProcessing
    , module Text.XML.MXT.Parser.MainFunctions

    , module Text.XML.MXT.Validator.Validation
    )
where

import Text.XML.MXT.DOM

import Text.XML.MXT.Parser.XmlParser
import Text.XML.MXT.Parser.HtmlParser
import Text.XML.MXT.Parser.XmlInput
import Text.XML.MXT.Parser.XmlOutput
import Text.XML.MXT.Parser.DTDProcessing
import Text.XML.MXT.Parser.MainFunctions

import Text.XML.MXT.Validator.Validation

-- ------------------------------------------------------------

