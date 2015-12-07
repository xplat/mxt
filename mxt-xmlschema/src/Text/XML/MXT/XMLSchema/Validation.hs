{- |
   Module     : Text.XML.MXT.XMLSchema.Validation
   Copyright  : Copyright (C) 2005-2012 Thorben Guelck, Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   Contains functions to perform validation following a given schema definition.
-}

module Text.XML.MXT.XMLSchema.Validation
  ( validateDocumentWithXmlSchema

    -- these are only used in test suite
  , validateWithXmlSchema'
  , SValResult
  , SValEnv(..)
  , XmlSchema
  , runSVal
  , testRoot
  , createRootDesc
  )

where

import           Prelude                                hiding (lookup)

import           Text.XML.MXT.Core                      (XmlTree, arr, arrL,
                                                         c_err, constA,
                                                         documentStatusOk,
                                                         getChildren, guards,
                                                         isA, isElem, issueErr,
                                                         issueFatal, issueWarn,
                                                         none, orElse, perform, setDocumentStatusFromSystemState,
                                                         this, traceMsg, when,
                                                         ($<), (>>>))

import           Text.XML.MXT.Arrow.XmlState.TypeDefs   (IOSArrow, IOStateArrow,
                                                         SysConfigList,
                                                         configSysVars,
                                                         localSysEnv, setS,
                                                         theXmlSchemaValidate,
                                                         withoutUserState)

import           Text.XML.MXT.XMLSchema.AbstractSyntax  (XmlSchema)
import           Text.XML.MXT.XMLSchema.Loader
import           Text.XML.MXT.XMLSchema.Transformation  (createRootDesc)
import           Text.XML.MXT.XMLSchema.ValidationCore  (testRoot)
import           Text.XML.MXT.XMLSchema.ValidationTypes

-- ----------------------------------------

validateWithXmlSchema' :: XmlSchema -> XmlTree -> SValResult
validateWithXmlSchema' schema doc
    = runSVal (SValEnv { xpath = ""
                       , elemDesc        = rootElemDesc
                       , allElemDesc     = allElems
                       }
              ) $ testRoot doc
    where
      (rootElemDesc, allElems) = createRootDesc schema

-- ----------------------------------------

validateDocumentWithXmlSchema :: SysConfigList -> String -> IOStateArrow s XmlTree XmlTree
validateDocumentWithXmlSchema config schemaUri
    = ( withoutUserState
        $
        localSysEnv
        $
        configSysVars (config ++ [setS theXmlSchemaValidate False])
        >>>
        traceMsg 1 ( "validating document with XML schema: " ++ show schemaUri )
        >>>
        ( ( validateWithSchema schemaUri
            >>>
            traceMsg 1 "document validation done, no errors found"
          )
          `orElse`
          ( traceMsg 1 "document not valid, errors found"
            >>>
            setDocumentStatusFromSystemState "validating with XML schema"
          )
        )
      )
      `when`
      documentStatusOk                                 -- only do something when document status is ok

validateWithSchema :: String -> IOSArrow XmlTree XmlTree
validateWithSchema uri
    = validate $< ( ( constA uri
                      >>>
                      traceMsg 1 ("reading XML schema definition from " ++ show uri)
                      >>>
                      loadDefinition []
                      >>>
                      traceMsg 1 ("XML schema definition read from " ++ show uri)
                    )
                    `orElse`
                    ( issueFatal ("Could not read XML Schema definition from " ++ show uri)
                      >>>
                      none
                    )
                  )
    where
      issueMsg (lev, xp, e)
          = (if lev < c_err then issueWarn else issueErr) $
            "At XPath " ++ xp ++ ": " ++ e

      validate schema
          = ( getChildren >>> isElem    -- select document root element
              >>>
              traceMsg 1 "document validation process started"
              >>>
              arr (validateWithXmlSchema' schema)
              >>>
              perform ( arrL snd
                        >>>
                        ( issueMsg $< this )
                      )
              >>>
              isA ((== True) . fst)
            )
            `guards` this

-- ----------------------------------------

