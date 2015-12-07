module Simple where

import Text.XML.MXT.Core
import Text.XML.MXT.RelaxNG

process schema =
  runX
  ( readDocument [ withTrace 2
                 , withRelaxNG schema
                 ] "simple.xml"
    >>>
    writeDocument [withIndent yes] ""
  )

main
    = -- process "simple-unqualified.rng"
      -- >>
      process "simple-qualified.rng"
      >>
      return ()
