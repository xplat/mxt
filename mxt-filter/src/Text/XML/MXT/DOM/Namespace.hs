-- |
-- main namespace filter for propagation, checking, tracing and error handling

module Text.XML.MXT.DOM.Namespace
    ( module Text.XML.MXT.DOM.Namespace
    , module Text.XML.MXT.DOM.NamespaceFilter
    )
where

import Text.XML.MXT.DOM.XmlTree
import Text.XML.MXT.DOM.XmlState
import Text.XML.MXT.DOM.NamespaceFilter

import Text.XML.MXT.Parser.XmlOutput
    ( traceTree
    , traceSource
    , traceMsg
    )

-- -----------------------------------------------------------------------------

-- |
-- propagate all namespace declarations, check namespace constraints and issue errors.
-- If no error was found, result is the unchanged input tree, else the root node \"\/\" with an empty document is returned.
--
-- see also : 'propagateNamespaces', 'validateNamespaces'

propagateAndValidateNamespaces  :: XmlStateFilter a
propagateAndValidateNamespaces
    = traceMsg 2 "propagating namespaces"
      .>>
      liftMf propagateNamespaces
      .>>
      traceTree
      .>>
      traceSource
      .>>
      traceMsg 2 "validating namespaces"
      .>>
      validate
    where
    validate    :: XmlStateFilter a
    validate t
        = let
          errs = validateNamespaces t
          in if null errs
             then thisM t
             else ( liftF this $$< errs )
                  >>
                  return (setStatus c_err "namespace propagation" t)

-- -----------------------------------------------------------------------------
