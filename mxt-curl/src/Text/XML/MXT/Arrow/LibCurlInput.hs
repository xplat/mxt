-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.Arrow.LibCurlInput
   Copyright  : Copyright (C) 2005 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   libcurl input
-}

-- ------------------------------------------------------------

module Text.XML.MXT.Arrow.LibCurlInput
    ( getLibCurlContents
    , a_use_curl
    , withCurl
    , curlOptions
    )
where

import           Control.Arrow                            -- arrow classes
import           Control.Arrow.ArrowList
import           Control.Arrow.ArrowTree
import           Control.Arrow.ArrowIO

import qualified Data.ByteString.Lazy           as B
-- import qualified Data.ByteString.Lazy.Char8     as C

import           System.Console.GetOpt

import           Text.XML.MXT.Arrow.DocumentInput               ( addInputError )
import qualified Text.XML.MXT.IO.GetHTTPLibCurl as LibCURL

import           Text.XML.MXT.DOM.Interface

import           Text.XML.MXT.Arrow.XmlArrow
import           Text.XML.MXT.Arrow.XmlState
import           Text.XML.MXT.Arrow.XmlState.TypeDefs
import           Text.XML.MXT.Arrow.XmlOptions                  ( a_proxy
                                                                , a_redirect
                                                                )

-- ----------------------------------------------------------

getLibCurlContents      :: IOSArrow XmlTree XmlTree
getLibCurlContents
    = getC
      $<<
      ( getAttrValue transferURI
        &&&
        getSysVar (theInputOptions .&&&.
                   theRedirect     .&&&.
                   theProxy        .&&&.
                   theStrictInput
                  )
      )
      where
      getC uri (options, (redirect, (proxy, strictInput)))
          = applyA ( ( traceMsg 2 ( "get HTTP via libcurl, uri=" ++ show uri ++ " options=" ++ show options' )
                       >>>
                       arrIO0 ( LibCURL.getCont
                                    strictInput
                                    options'
                                    uri
                              )
                     )
                     >>>
                     ( arr (uncurry addInputError)
                       |||
                       arr addContent
                     )
                   )
            where
            options' = (a_proxy, proxy)
                       : (a_redirect, show . fromEnum $ redirect)
                       : options

addContent        :: (Attributes, B.ByteString) -> IOSArrow XmlTree XmlTree
addContent (al, bc)
    = replaceChildren (blb bc)                  -- add the contents
      >>>
      seqA (map (uncurry addAttr) al)           -- add the meta info (HTTP headers, ...)

-- ------------------------------------------------------------

a_use_curl              :: String
a_use_curl              = "use-curl"

withCurl               :: Attributes -> SysConfig
withCurl curlOpts      = setS theHttpHandler getLibCurlContents
                         >>>
                         withInputOptions curlOpts

curlOptions            :: [OptDescr SysConfig]
curlOptions            = [ Option "" [a_use_curl]  (NoArg (withCurl []))  "enable HTTP input with libcurl" ]

-- ------------------------------------------------------------

