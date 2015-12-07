module Main
where

import Text.XML.MXT.Core

main :: IO ()
main = runX
       ( readBinaryValue "emil"
         >>>
         xshow this
       ) >> return ()
             