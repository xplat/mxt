-- | This modul exports the list of supported datatype libraries.
-- It also exports the main functions to validate an XML instance value
-- with respect to a datatype.

module Text.XML.MXT.RelaxNG.DataTypeLibraries
  ( datatypeLibraries
  , datatypeEqual
  , datatypeAllows
  )
where

import Text.XML.MXT.DOM.Interface
    ( relaxNamespace
    )

import Text.XML.MXT.RelaxNG.DataTypeLibUtils

import Text.XML.MXT.RelaxNG.DataTypeLibMysql
    ( mysqlDatatypeLib )

import Text.XML.MXT.RelaxNG.XMLSchema.DataTypeLibW3C
    ( w3cDatatypeLib )

import Data.Maybe
    ( fromJust )

-- ------------------------------------------------------------


-- | List of all supported datatype libraries which can be
-- used within the Relax NG validator modul.

datatypeLibraries :: DatatypeLibraries
datatypeLibraries
    = [ relaxDatatypeLib
      , relaxDatatypeLib'
      , mysqlDatatypeLib
      , w3cDatatypeLib
      ]


{- |
Tests whether a XML instance value matches a value-pattern.

The following tests are performed:

   * 1. :  does the uri exist in the list of supported datatype libraries

   - 2. :  does the library support the datatype

   - 3. :  does the XML instance value match the value-pattern

The hard work is done by the specialized 'DatatypeEqual' function
(see also: 'DatatypeCheck') of the datatype library.
-}

datatypeEqual :: Uri -> DatatypeEqual
datatypeEqual uri d s1 c1 s2 c2
    = if elem uri (map fst datatypeLibraries)
      then dtEqFct d s1 c1 s2 c2
      else Just ( "Unknown DatatypeLibrary " ++ show uri )
    where
    DTC _ dtEqFct _ = fromJust $ lookup uri datatypeLibraries

{- |
Tests whether a XML instance value matches a data-pattern.

The following tests are performed:

   * 1. :  does the uri exist in the list of supported datatype libraries

   - 2. :  does the library support the datatype

   - 3. :  does the XML instance value match the data-pattern

   - 4. :  does the XML instance value match all params

The hard work is done by the specialized 'DatatypeAllows' function
(see also: 'DatatypeCheck') of the datatype library.

-}

datatypeAllows :: Uri -> DatatypeAllows
datatypeAllows uri d params s1 c1
    = if elem uri (map fst datatypeLibraries)
      then dtAllowFct d params s1 c1
      else Just ( "Unknown DatatypeLibrary " ++ show uri )
    where
    DTC dtAllowFct _ _ = fromJust $ lookup uri datatypeLibraries


-- --------------------------------------------------------------------------------------
-- Relax NG build in datatype library

relaxDatatypeLib        :: DatatypeLibrary
relaxDatatypeLib        = (relaxNamespace, DTC datatypeAllowsRelax datatypeEqualRelax relaxDatatypes)

-- | if there is no datatype uri, the built in datatype library is used
relaxDatatypeLib'       :: DatatypeLibrary
relaxDatatypeLib'       = ("",             DTC datatypeAllowsRelax datatypeEqualRelax relaxDatatypes)

-- | The build in Relax NG datatype lib supportes only the token and string datatype,
-- without any params.

relaxDatatypes :: AllowedDatatypes
relaxDatatypes
    = map ( (\ x -> (x, [])) . fst ) relaxDatatypeTable

datatypeAllowsRelax :: DatatypeAllows
datatypeAllowsRelax d p v _
    = maybe notAllowed' allowed . lookup d $ relaxDatatypeTable
    where
    notAllowed'
        = Just $ errorMsgDataTypeNotAllowed relaxNamespace d p v
    allowed _
        = Nothing

-- | If the token datatype is used, the values have to be normalized
-- (trailing and leading whitespaces are removed).
-- token does not perform any changes to the values.

datatypeEqualRelax :: DatatypeEqual
datatypeEqualRelax d s1 _ s2 _
    = maybe notAllowed' checkValues . lookup d $ relaxDatatypeTable
      where
      notAllowed'
          = Just $ errorMsgDataTypeNotAllowed2 relaxNamespace d s1 s2
      checkValues predicate
          = if predicate s1 s2
            then Nothing
            else Just $ errorMsgEqual d s1 s2

relaxDatatypeTable :: [(String, String -> String -> Bool)]
relaxDatatypeTable
    = [ ("string", (==))
      , ("token",  \ s1 s2 -> normalizeWhitespace s1 == normalizeWhitespace s2 )
      ]


-- --------------------------------------------------------------------------------------
