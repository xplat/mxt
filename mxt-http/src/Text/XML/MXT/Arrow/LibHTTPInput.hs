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

module Text.XML.MXT.Arrow.LibHTTPInput
    ( getHTTPNativeContents
    , withHTTP
    , httpOptions
    )
where

import           Control.Arrow
import           Control.Arrow.ArrowIO
import           Control.Arrow.ArrowList
import           Control.Arrow.ArrowTree

import qualified Data.ByteString.Lazy                 as B
-- import qualified Data.ByteString.Lazy.Char8     as C

import           System.Console.GetOpt

import           Text.XML.MXT.Arrow.DocumentInput     (addInputError)
import           Text.XML.MXT.IO.GetHTTPNative        (getCont)

import           Text.XML.MXT.DOM.Interface

import           Text.XML.MXT.Arrow.XmlArrow
import           Text.XML.MXT.Arrow.XmlState
import           Text.XML.MXT.Arrow.XmlState.TypeDefs

-- ----------------------------------------------------------

getHTTPNativeContents      :: IOSArrow XmlTree XmlTree
getHTTPNativeContents
    = getC
      $<<
      ( getAttrValue transferURI
        &&&
        getSysVar (theInputOptions .&&&.
                   theProxy        .&&&.
                   theStrictInput  .&&&.
                   theRedirect
                  )
      )
      where
      getC uri (options, (proxy, (strictInput, redirect)))
          = applyA ( ( traceMsg 2 ( "get HTTP via native HTTP interface, uri=" ++ show uri ++ " options=" ++ show options )
                       >>>
                       arrIO0 (getCont strictInput proxy uri redirect options)
                     )
                     >>>
                     ( arr (uncurry addInputError)
                       |||
                       arr addContent
                     )
                   )

addContent        :: (Attributes, B.ByteString) -> IOSArrow XmlTree XmlTree
addContent (al, bc)
    = replaceChildren (blb bc)                  -- add the contents
      >>>
      seqA (map (uncurry addAttr) al)           -- add the meta info (HTTP headers, ...)

-- ------------------------------------------------------------

a_use_http              :: String
a_use_http              = "use-http"

withHTTP               :: Attributes -> SysConfig
withHTTP httpOpts      = setS theHttpHandler getHTTPNativeContents
                         >>>
                         withInputOptions httpOpts

httpOptions            :: [OptDescr SysConfig]
httpOptions            = [ Option "" [a_use_http]  (NoArg (withHTTP []))  "enable HTTP input with native Haskell HTTP package" ]

-- ------------------------------------------------------------

