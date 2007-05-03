-- ------------------------------------------------------------

{- |
   Module     : Network.Server.Janus.Handler.ConsoleHandler
   Copyright  : Copyright (C) 2006 Christian Uhlig
   License    : MIT

   Maintainer : Christian Uhlig (uhl\@fh-wedel.de)
   Stability  : experimental
   Portability: portable
   Version    : $Id: ConsoleHandler.hs, v1.1 2007/03/27 00:00:00 janus Exp $

   Janus Console Handler
   
   A Handler to accept textual commands at a command prompt, to create Transaction
   values from commands, to utilize its Shader pipeline to process the command 
   Transactions and to produce textual response to the user by means of the resulting
   Transactions.

-}

-- ------------------------------------------------------------

{-# OPTIONS -fglasgow-exts -farrows #-}

module Network.Server.Janus.Handler.ConsoleHandler
    (
    -- console handler
      ttyHandler
    )
where

import System.IO
import Text.XML.HXT.Arrow

import Network.Server.Janus.Core
import Network.Server.Janus.Messaging
import Network.Server.Janus.Transaction as TA
import Network.Server.Janus.XmlHelper

{- |
TODO
-}
ttyHandler :: HandlerCreator
ttyHandler = proc (conf, shader) -> do
    state   <- getVal "/config/@state"                                              -<  conf
    ident   <- getVal "/config/@id"                                                 -<  conf
    context <- getContext                                                           -<  ()
    (state ++ "/ctx") <*! context                                                   -<< ()
    (state ++ "/ctx_name") <-! ident                                                -<< ()
    (state ++ "/cursor") <-! "/global"                                              -<< ()
    let handler = proc _ -> do
        ctx_name    <- getSVS (state ++ "/ctx_name")                            -<  ()
        -- cursor      <- getSVS (state ++ "/cursor")                          -<  ()
        arrIO $ hSetBuffering stdout                                            -<  NoBuffering
        arrIO $ putStr                                                          -<  "(" ++ ctx_name ++ ")> "
        line        <- arrIO0 $ getLine                                         -<  ()
        -- let command = words line
        ta          <- createTA 1 Init                                          -<  ()
        ta2         <- (setVal "/transaction/@handler" "ConsoleHandler")        -<< ta
        ts_start    <- getCurrentTS                                             -<  ()
        ta3         <- setTAStart ts_start                                      -<< ta2 
        ta4         <- setVal "/transaction/request_fragment" line              -<< ta3
        ta5         <- TA.setTAState Processing                                 -<  ta4
        ta6         <- shader                                                   -<  ta5
        ta_state    <- getTAState                                               -<  ta6
        (if ta_state == Failure
         then proc ta' -> do
            arrIO $ putStrLn                                                -<  "Error."
            listA $ TA.getTAMsg >>> showMsg >>> (arrIO $ putStrLn)          -<  ta'
         else proc ta' -> do
            response    <- getValDef "/transaction/response_fragment" ""    -<  ta'
            listA $ arrIO $ putStrLn                                        -<  response
            )                                                                   -<< ta6

        -- ts_end      <- getCurrentTS                                         -<  ()
        -- setTAEnd ts_end                                                     -<< ta6
        -- runtime     <- getTARunTime                                         -<  ta7 
        handler                                                             -<  ()
    returnA                                                                         -<  handler
        
