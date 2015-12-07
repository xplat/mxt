module Main
where

import Text.XML.MXT.Core

main :: IO ()
main = do
       runX ( readDocument [withValidate no] "t.xml"
	      >>>
	      xshow (deep isText)
	      >>>
	      arrIO print
	    )
       runX ( readDocument [withValidate no] "t.o"
	      >>>
	      xshow (deep isText)
	      >>>
	      arrIO print
	    )
       runX ( readDocument [withValidate no
			   ,withMimeTypeFile "mime.types"] "t.o"
	      >>>
	      xshow (deep isText)
	      >>>
	      arrIO print
	    )
       return ()
