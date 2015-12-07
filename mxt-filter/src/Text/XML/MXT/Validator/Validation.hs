-- |
-- This module provides a state filter as a main function for validating XML documents.
--
-- The real validation is done with pure filters from module 'Text.XML.MXT.Validator.ValidationFilter'
--
-- Author : .\\artin Schmidt

module Text.XML.MXT.Validator.Validation
    ( getValidatedDoc
    , module Text.XML.MXT.Validator.ValidationFilter
    )

where

import Text.XML.MXT.DOM.XmlTree
import Text.XML.MXT.DOM.XmlState

import Text.XML.MXT.Validator.ValidationFilter

import Text.XML.MXT.Parser.XmlOutput
    ( traceTree
    , traceSource
    , traceMsg
    )

-- ------------------------------------------------------------

-- |
-- monadic filter for validating and transforming a wellformed document.
--
-- the "main" function for validation.
--
-- the input tree must consist of a root node with a complete document and DTD.
-- Result is the single element list containing same tree but tranformed with respect to the DTD,
-- or, in case of errors, the root with an empty list of children

getValidatedDoc         :: XmlStateFilter state
getValidatedDoc
    = traceMsg 1 "validating document"
      .>>
      ( ( runValidation
          .>>
          traceTree
          .>>
          traceSource
        )
        `whenM` (isRoot .> getChildren)
      )
      where
      runValidation t
          = ( issueError $$< res )
            >>
            ( if null errs
              then ( traceMsg 1 "transforming validated document"
                     .>>
                     liftMf transform
                   )
              else liftMf (setStatus c_err "validating document")
              ) t
            where
            res  = validate t
            errs = isXError .> neg isWarning $$ res

-- ------------------------------------------------------------
