-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.XPath.XPathToString
   Copyright  : Copyright (C) 2008 - infinity: Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   Format an expression or value in tree- or string-representation

-}

-- ------------------------------------------------------------

module Text.XML.MXT.XPath.XPathToString
    ( expr2XPathTree
    , xPValue2String
    , xPValue2XmlTrees
    , nt2XPathTree
    , pred2XPathTree
    , toXPathTree
    , formatXPathTree
    )
where

-- import Text.XML.MXT.DOM.XmlTree

import Text.XML.MXT.DOM.Interface
import Text.XML.MXT.DOM.XmlNode         ( mkText
                                        , mkError
                                        )
import Text.XML.MXT.DOM.FormatXmlTree   ( formatXmlTree )
import Text.XML.MXT.XPath.XPathDataTypes

import Data.Char                        ( toLower )
import Data.Tree.Class                  ( formatTree )

-- ------------------------------------------------------------

type XPathTree                          = NTree String

-- -----------------------------------------------------------------------------
-- |
-- Convert an navigable tree in a xmltree
--
toXPathTree                             :: [NavTree a] -> [NTree a]
toXPathTree                             = map subtreeNT

-- -----------------------------------------------------------------------------

formatXPathTree                         :: Expr -> String
formatXPathTree                         = formatTree id . expr2XPathTree

-- -----------------------------------------------------------------------------
-- |
-- Format a XPath-value in string representation.
-- Text output is done by 'formatXmlTree' for node-sets (trees),
-- all other values are represented as strings.
--

xPValue2String                          :: XPathValue -> String
xPValue2String (XPVNode ns)             = foldr (\ t -> ((formatXmlTree t ++ "\n") ++)) "" (toXPathTree . fromNodeSet $ ns)
xPValue2String (XPVBool b)              = map toLower (show b)
xPValue2String (XPVNumber (Float f))    = show f
xPValue2String (XPVNumber s)            = show s
xPValue2String (XPVString s)            = s
xPValue2String (XPVError s)             = "Error: " ++ s

-- -----------------------------------------------------------------------------
-- |
-- Convert a a XPath-value into XmlTrees.
--

xPValue2XmlTrees                        :: XPathValue -> XmlTrees
xPValue2XmlTrees (XPVNode ns)           = toXPathTree . fromNodeSet $ ns
xPValue2XmlTrees (XPVBool b)            = xtext (show b)
xPValue2XmlTrees (XPVNumber (Float f))  = xtext (show f)
xPValue2XmlTrees (XPVNumber s)          = xtext (show s)
xPValue2XmlTrees (XPVString s)          = xtext s
xPValue2XmlTrees (XPVError  s)          = xerr s

xtext, xerr                             :: String -> XmlTrees
xtext                                   = (:[]) . mkText

xerr                                    = (:[]) . mkError c_err


-- -----------------------------------------------------------------------------
-- |
-- Format a parsed XPath-expression in tree representation.
-- Text output is done by 'formatXmlTree'
--
expr2XPathTree                          :: Expr -> XPathTree
expr2XPathTree (GenExpr op ex)          = NTree (show op) (map expr2XPathTree ex)
expr2XPathTree (NumberExpr f)           = NTree (show f) []
expr2XPathTree (LiteralExpr s)          = NTree s []
expr2XPathTree (VarExpr name)           = NTree ("Var: " ++ show name) []
expr2XPathTree (FctExpr n arg)          = NTree ("Fct: " ++ n) (map expr2XPathTree arg)

expr2XPathTree (FilterExpr [])          = NTree "" []
expr2XPathTree (FilterExpr (primary:predicate))
                                        = NTree "FilterExpr" [expr2XPathTree primary, pred2XPathTree predicate]

expr2XPathTree (PathExpr Nothing (Just lp))
                                        = locpath2XPathTree lp
expr2XPathTree (PathExpr (Just fe) (Just lp))
                                        = NTree "PathExpr" [expr2XPathTree fe, locpath2XPathTree lp]
expr2XPathTree (PathExpr _ _)           = NTree "" []

locpath2XPathTree                       :: LocationPath -> XPathTree
locpath2XPathTree (LocPath rel steps)   = NTree (show rel ++ "LocationPath") (map step2XPathTree steps)


step2XPathTree                          :: XStep -> XPathTree
step2XPathTree (Step axis nt [])        = NTree (show axis) [nt2XPathTree nt]
step2XPathTree (Step axis nt expr)      = NTree (show axis) [nt2XPathTree nt, pred2XPathTree expr]

nt2XPathTree                            :: NodeTest -> XPathTree
nt2XPathTree (TypeTest s)               = NTree ("TypeTest: "++ typeTest2String s) []
nt2XPathTree (PI s)                     = NTree ("TypeTest: processing-instruction("++ show s ++ ")") []
nt2XPathTree (NameTest s)               = NTree ("NameTest: "++ show s) []


pred2XPathTree                          :: [Expr] -> XPathTree
pred2XPathTree exprL                    = NTree "Predicates" (map expr2XPathTree exprL)

typeTest2String                         :: XPathNode -> String
typeTest2String XPNode                  = "node()"
typeTest2String XPCommentNode           = "comment()"
typeTest2String XPPINode                = "processing-instruction()"
typeTest2String XPTextNode              = "text()"

-- ------------------------------------------------------------
