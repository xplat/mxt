module Main
where

import Text.XML.MXT.Core

main	:: IO()
main
    = runX ( configSysVars [ withTrace 1 ]
	     >>>
	     readDocument    [ withValidate no ] "hello.xml"
	     >>>
	     writeDocument   [ ] "bye.xml"
	   )
      >> return ()

      