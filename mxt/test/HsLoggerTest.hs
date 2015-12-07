module Main
where

import Data.List ( isPrefixOf )
import Text.XML.MXT.Arrow
import System.Log.Logger

main	:: IO ()
main	= do
	  runX ( mxtSetLogLevel INFO
		 >>>
	         mxtSetErrorLog
		 >>>
		 readDocument [ (a_parse_html, v_1)
			      , (a_remove_whitespace, v_1)
			      ] "http://www.haskell.org"
		 >>>
		 processChildren (deep isText)
		 >>>
		 writeDocument [] ""
	       )
	   >> return ()

mxtLoggerName	= "mxt"

mxtLogger :: Int -> String -> IO ()
mxtLogger level msg
    = logM mxtLoggerName priority (show priority ++ "\t" ++ msg')
    where
    msg'
	| "-- (" `isPrefixOf` msg	= drop 7 msg
	| otherwise			= msg
    priority = toPriority level
    toPriority level
	| level <= 0	= WARNING
	| level == 1    = NOTICE
	| level == 2	= INFO
	| level >= 3	= DEBUG

mxtSetTraceAndErrorLogger	:: Priority -> IOStateArrow s b b
mxtSetTraceAndErrorLogger priority
    = mxtSetLogLevel priority
      >>>
      mxtSetErrorLog

mxtSetLogLevel			:: Priority -> IOStateArrow s b b
mxtSetLogLevel priority
    = setTraceLevel (fromPriority priority)
      >>>
      setTraceCmd mxtLogger
      >>>
      perform ( arrIO0 $
		updateGlobalLogger mxtLoggerName (setLevel priority)
	      )
    where
    fromPriority NOTICE	 = 1
    fromPriority INFO	 = 2
    fromPriority DEBUG	 = 3
    fromPriority _	 = 0

mxtSetErrorLog	:: IOStateArrow s b b
mxtSetErrorLog	= setErrorMsgHandler False mxtErrorLogger

mxtErrorLogger	:: String -> IO ()
mxtErrorLogger msg
    = logM mxtLoggerName priority (show priority ++ "\t" ++ (drop 2 . dropWhile (/= ':') $ msg)) 
    where
    priority = prio . drop 1 $ msg
    prio m
	| "fatal" `isPrefixOf` m	= CRITICAL
        | "error" `isPrefixOf` m	= ERROR
	| "warning" `isPrefixOf` m	= WARNING
	| otherwise			= NOTICE