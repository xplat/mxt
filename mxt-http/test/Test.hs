module Test where

import Text.XML.MXT.Core
import Text.XML.MXT.HTTP

main
  = do
    runX ( readDocument
           [ withInputOption "curl--max-filesize" "100000"
           , withParseHTML yes
           , withTrace 2
           , withHTTP []
           , withRedirect yes
           ] "http://www.haskell.org/"
           >>>
           traceDoc "the too long document"
           >>>
           none
         )
      