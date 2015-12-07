-- ------------------------------------------------------------

{- |
   Module     : Text.XML.MXT.XPath.XPathEval
   Copyright  : Copyright (C) 2006-2011 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   The core functions for evaluating the different types of XPath expressions.
   Each 'Expr'-constructor is mapped to an evaluation function.

-}

-- ------------------------------------------------------------

module Text.XML.MXT.XPath.XPathEval
    ( getXPath
    , getXPathSubTrees
    , getXPathNodeSet'

    , getXPathWithNsEnv
    , getXPathSubTreesWithNsEnv
    , getXPathNodeSetWithNsEnv'

    , evalExpr
    , addRoot'

    , parseXPathExpr
    , parseXPathExprWithNsEnv

    , getXPath'
    , getXPathSubTrees'
    , getXPathNodeSet''
    )
where

import Data.List                        ( partition )
import Data.Maybe                       ( fromJust, fromMaybe )

import Text.XML.MXT.XPath.XPathFct
import Text.XML.MXT.XPath.XPathDataTypes
import Text.XML.MXT.XPath.XPathArithmetic
                                        ( xPathAdd
                                        , xPathDiv
                                        , xPathMod
                                        , xPathMulti
                                        , xPathUnary
                                        )
import Text.XML.MXT.XPath.XPathParser   ( parseXPath )
import Text.XML.MXT.XPath.XPathToString ( xPValue2XmlTrees )
import Text.XML.MXT.XPath.XPathToNodeSet( xPValue2XmlNodeSet
                                        , emptyXmlNodeSet
                                        )

import Text.XML.MXT.Parser.XmlCharParser( withNormNewline )

import Text.ParserCombinators.Parsec    ( runParser )

-- ----------------------------------------

-- the DOM functions

import           Text.XML.MXT.DOM.Interface
import qualified Text.XML.MXT.DOM.XmlNode as XN

-- ----------------------------------------

-- the list arrow functions

import Control.Arrow                    ( (>>>), (>>^), left )
import Control.Arrow.ArrowList          ( arrL, isA )
import Control.Arrow.ArrowIf            ( filterA )
import Control.Arrow.ListArrow          ( runLA )
import qualified
       Control.Arrow.ArrowTree          as AT

import Text.XML.MXT.Arrow.XmlArrow      ( ArrowDTD, isDTD, getDTDAttrl )
import Text.XML.MXT.Arrow.Edit          ( canonicalizeForXPath )

-- -----------------------------------------------------------------------------
-- |
-- Select parts of a document by a string representing a XPath expression.
--
-- The main filter for selecting parts of a document via XPath.
-- The string argument must be a XPath expression with an absolute location path,
-- the argument tree must be a complete document tree.
-- Result is a possibly empty list of XmlTrees forming the set of selected XPath values.
-- XPath values other than XmlTrees (numbers, attributes, tagnames, ...)
-- are converted to text nodes.

getXPath                :: String -> XmlTree -> XmlTrees
getXPath                = getXPathWithNsEnv []

-- -----------------------------------------------------------------------------
-- |
-- Select parts of a document by an already parsed XPath expression

getXPath'               :: Expr -> XmlTree -> XmlTrees
getXPath' e             = runLA $
                          canonicalizeForXPath
                          >>>
                          arrL (getXPathValues' xPValue2XmlTrees e)

-- -----------------------------------------------------------------------------
-- |
-- Select parts of a document by a namespace aware XPath expression.
--
-- Works like 'getXPath' but the prefix:localpart names in the XPath expression
-- are interpreted with respect to the given namespace environment

getXPathWithNsEnv       :: Attributes -> String -> XmlTree -> XmlTrees
getXPathWithNsEnv env s = runLA ( canonicalizeForXPath
                                  >>>
                                  arrL (getXPathValues xPValue2XmlTrees xPathErr env s)
                                )

-- -----------------------------------------------------------------------------
-- |
-- Select parts of an XML tree by a string representing an XPath expression.
--
-- The main filter for selecting parts of an arbitrary XML tree via XPath.
-- The string argument must be a XPath expression with an absolute location path,
-- There are no restrictions on the arument tree.
--
-- No canonicalization is performed before evaluating the query
--
-- Result is a possibly empty list of XmlTrees forming the set of selected XPath values.
-- XPath values other than XmlTrees (numbers, attributes, tagnames, ...)
-- are convertet to text nodes.

getXPathSubTrees                        :: String -> XmlTree -> XmlTrees
getXPathSubTrees                        = getXPathSubTreesWithNsEnv []

-- -----------------------------------------------------------------------------
-- |
-- Select parts of an XML tree by an XPath expression.

getXPathSubTrees'                       :: Expr -> XmlTree -> XmlTrees
getXPathSubTrees'                       = getXPathValues' xPValue2XmlTrees

-- -----------------------------------------------------------------------------
-- | Same as 'getXPathSubTrees' but with namespace aware XPath expression

getXPathSubTreesWithNsEnv               :: Attributes -> String -> XmlTree -> XmlTrees
getXPathSubTreesWithNsEnv nsEnv xpStr   = getXPathValues xPValue2XmlTrees xPathErr nsEnv xpStr

-- -----------------------------------------------------------------------------
-- |
-- compute the node set of an XPath query

getXPathNodeSet'                        :: String -> XmlTree -> XmlNodeSet
getXPathNodeSet'                        = getXPathNodeSetWithNsEnv' []

-- -----------------------------------------------------------------------------
-- |
-- compute the node set of an XPath query for an already parsed XPath expr

getXPathNodeSet''                       :: Expr -> XmlTree -> XmlNodeSet
getXPathNodeSet''                       = getXPathValues' xPValue2XmlNodeSet

-- -----------------------------------------------------------------------------
-- | compute the node set of a namespace aware XPath query

getXPathNodeSetWithNsEnv'               :: Attributes -> String -> XmlTree -> XmlNodeSet
getXPathNodeSetWithNsEnv' nsEnv xpStr   = getXPathValues xPValue2XmlNodeSet (const emptyXmlNodeSet) nsEnv xpStr

-- -----------------------------------------------------------------------------

-- | parse xpath, evaluate xpath expr and prepare results

getXPathValues                          :: (XPathValue -> a) -> (String -> a) -> Attributes -> String -> XmlTree -> a
getXPathValues cvRes cvErr nsEnv xpStr t
                                        = case parseXPathExprWithNsEnv nsEnv xpStr of
                                          Left  parseError      -> cvErr parseError
                                          Right xpExpr          -> getXPathValues' cvRes xpExpr t

xPathErr                                :: String -> [XmlTree]
xPathErr parseError                     = [ XN.mkError c_err parseError ]

-- -----------------------------------------------------------------------------

-- | parse xpath, evaluate xpath expr and prepare results

getXPathValues'                         :: (XPathValue -> a) -> Expr -> XmlTree -> a
getXPathValues' cvRes xpExpr t          = cvRes xpRes
    where
    t'                                  = addRoot' t                            -- we need a root node for starting xpath eval
    idAttr                              = ( ("", "idAttr")                      -- id attributes from DTD (if there)
                                          , idAttributesToXPathValue . getIdAttributes $ t'
                                          )
    navTD                               = ntree t'
    xpRes                               = evalExpr (idAttr:(getVarTab varEnv),[]) (1, 1, navTD) xpExpr (XPVNode . singletonNodeSet $ navTD)

addRoot'                                :: XmlTree -> XmlTree
addRoot' t
    | XN.isRoot t                       = t
    | otherwise                         = XN.mkRoot [] [t]

-- -----------------------------------------------------------------------------

-- | parse an XPath expr string
-- and return an expr tree or an error message.
-- Namespaces are not taken into account.

parseXPathExpr                          :: String -> Either String Expr
parseXPathExpr                          = parseXPathExprWithNsEnv []

-- | parse an XPath expr string with a namespace environment for qualified names in the XPath expr
-- and return an expr tree or an error message

parseXPathExprWithNsEnv                 :: Attributes -> String -> Either String Expr
parseXPathExprWithNsEnv nsEnv xpStr     = left fmtErr . runParser parseXPath (withNormNewline (toNsEnv nsEnv)) "" $ xpStr
    where
    fmtErr parseError                   = "Syntax error in XPath expression " ++
                                          show xpStr ++ ": " ++
                                          show parseError

-- -----------------------------------------------------------------------------

-- |
-- The main evaluation entry point.
-- Each XPath-'Expr' is mapped to an evaluation function. The 'Env'-parameter contains the set of global variables
-- for the evaluator, the 'Context'-parameter the root of the tree in which the expression is evaluated.
--

evalExpr                                :: Env -> Context -> Expr -> XPathFilter
evalExpr env cont (GenExpr Or ex)       = boolEval  env cont Or  ex
evalExpr env cont (GenExpr And ex)      = boolEval  env cont And ex
evalExpr env cont (GenExpr Eq ex)       = relEqEval env cont Eq        . evalExprL env cont ex
evalExpr env cont (GenExpr NEq ex)      = relEqEval env cont NEq       . evalExprL env cont ex
evalExpr env cont (GenExpr Less ex)     = relEqEval env cont Less      . evalExprL env cont ex
evalExpr env cont (GenExpr LessEq ex)   = relEqEval env cont LessEq    . evalExprL env cont ex
evalExpr env cont (GenExpr Greater ex)  = relEqEval env cont Greater   . evalExprL env cont ex
evalExpr env cont (GenExpr GreaterEq ex)
                                        = relEqEval env cont GreaterEq . evalExprL env cont ex
evalExpr env cont (GenExpr Plus ex)     = numEval xPathAdd   Plus  . toXValue xnumber cont env . evalExprL env cont ex
evalExpr env cont (GenExpr Minus ex)    = numEval xPathAdd   Minus . toXValue xnumber cont env . evalExprL env cont ex
evalExpr env cont (GenExpr Div ex)      = numEval xPathDiv   Div   . toXValue xnumber cont env . evalExprL env cont ex
evalExpr env cont (GenExpr Mod ex)      = numEval xPathMod   Mod   . toXValue xnumber cont env . evalExprL env cont ex
evalExpr env cont (GenExpr Mult ex)     = numEval xPathMulti Mult  . toXValue xnumber cont env . evalExprL env cont ex
evalExpr env cont (GenExpr Unary ex)    = xPathUnary . xnumber cont env . evalExprL env cont ex
evalExpr env cont (GenExpr Union ex)    = unionEval . evalExprL env cont ex
evalExpr env cont (FctExpr name args)   = fctEval env cont name args

evalExpr env _    (PathExpr Nothing   (Just lp))
                                        = locPathEval env lp
evalExpr env cont (PathExpr (Just fe) (Just lp))
                                        = locPathEval env lp . evalExpr env cont fe

evalExpr env cont (FilterExpr ex)       = filterEval env cont ex
evalExpr env _    ex                    = evalSpezExpr env ex

-- -----------------------------------------------------------------------------

evalExprL                               :: Env -> Context -> [Expr] -> XPathValue -> [XPathValue]
evalExprL env cont ex ns                = map (\e -> evalExpr env cont e ns) ex

-- -----------------------------------------------------------------------------

evalSpezExpr                            :: Env -> Expr -> XPathFilter
evalSpezExpr _ (NumberExpr (Float 0)) _ = XPVNumber Pos0
evalSpezExpr _ (NumberExpr (Float f)) _ = XPVNumber (Float f)
evalSpezExpr _ (LiteralExpr s) _        = XPVString s
evalSpezExpr env (VarExpr name) v       = getVariable env name v
evalSpezExpr _ _ _                      = XPVError "Call to evalExpr with a wrong argument"

-- -----------------------------------------------------------------------------

-- |
-- filter for evaluating a filter-expression

filterEval                              :: Env -> Context -> [Expr] -> XPathFilter
filterEval env cont (prim:predicates) ns
                                        = case evalExpr env cont prim ns of
                                          (XPVNode nns) -> nodeListResToXPathValue . evalPredL env predicates . Right . fromNodeSet $ nns
                                          _             -> XPVError "Return of a filterexpression is not a nodeset"
filterEval _ _ _ _                      = XPVError "Call to filterEval without an expression"


-- -----------------------------------------------------------------------------
-- |
-- returns the union of its arguments, the arguments have to be node-sets.

unionEval                               :: [XPathValue] -> XPathValue
unionEval vs
    | not (null evs)                    = case head evs of
                                          e@(XPVError _)        -> e
                                          _                     -> XPVError "A value of a union ( | ) is not a nodeset"
    | otherwise                         = XPVNode . unionsNodeSet . map theNode $ nvs
    where
    (nvs, evs)                          = partition isNode vs

    isNode (XPVNode _)                  = True
    isNode _                            = False

    theNode (XPVNode ns)                = ns
    theNode _                           = error "illegal argument in unionEval"

-- -----------------------------------------------------------------------------
-- |
-- Equality or relational test for node-sets, numbers, boolean values or strings,
-- each computation of two operands is done by relEqEv'

relEqEval                               :: Env -> Context -> Op -> [XPathValue] -> XPathValue
relEqEval env cont op                   = foldl1 (relEqEv' env cont op)

relEqEv'                                :: Env -> Context -> Op -> XPathValue -> XPathFilter
relEqEv' _ _ _ e@(XPVError _) _         = e
relEqEv' _ _ _ _ e@(XPVError _)         = e

-- two node-sets

relEqEv' env cont op a@(XPVNode _)
                     b@(XPVNode _)      = relEqTwoNodes env cont op a b

-- one node-set

relEqEv' env cont op a b@(XPVNode _)    = relEqOneNode env cont (fromJust $ getOpFct op) a b
relEqEv' env cont op a@(XPVNode _) b    = relEqOneNode env cont (flip $ fromJust $ getOpFct op) b a


--  test without a node-set and equality or not-equality operator

relEqEv' env cont Eq a b                = eqEv env cont (==) a b
relEqEv' env cont NEq a b               = eqEv env cont (/=) a b

-- test without a node-set and less, less-equal, greater or greater-equal operator

relEqEv' env cont op a b                = XPVBool ((fromJust $ getOpFct op) (toXNumber a) (toXNumber b))
    where
    toXNumber x                         = xnumber cont env [x]

-- -----------------------------------------------------------------------------

-- |
-- Equality or relational test for two node-sets.
-- The comparison will be true if and only if there is a node in the first node-set
-- and a node in the second node-set such that the result of performing the
-- comparison on the string-values of the two nodes is true

relEqTwoNodes                           :: Env -> Context -> Op -> XPathValue -> XPathFilter
relEqTwoNodes _ _ op (XPVNode ns)
                     (XPVNode ms)       = XPVBool $
                                          foldr  (\n -> (any (fct op n) (getStrValues ms) ||)) False $
                                          fromNodeSet ns
                                          where
                                          fct op' n'   = (fromJust $ getOpFct op') (stringValue n')
                                          getStrValues = map stringValue . fromNodeSet
relEqTwoNodes _ _ _ _ _                 = XPVError "Call to relEqTwoNodes without a nodeset"

-- -----------------------------------------------------------------------------
-- |
-- Comparison between a node-set and different type.
-- The node-set is converted in a boolean value if the second argument is of type boolean.
-- If the argument is of type number, the node-set is converted in a number, otherwise it is converted
-- in a string value.

relEqOneNode                            :: Env -> Context ->
                                           (XPathValue -> XPathValue -> Bool) -> XPathValue -> XPathFilter

relEqOneNode env cont fct arg           = withXPVNode "Call to relEqOneNode without a nodeset" $
                                          \ ns -> XPVBool (any  (fct arg) (getStrValues arg ns))
    where
    getStrValues arg'                   = map ((fromJust $ getConvFct arg') cont env . (:[])) .
                                          map stringValue .
                                          fromNodeSet

-- -----------------------------------------------------------------------------

-- |
-- No node-set is involved and the operator is equality or not-equality.
-- The arguments are converted in a common type. If one argument is a boolean value
-- then it is the boolean type. If a number is involved, the arguments have to converted in numbers,
-- else the string type is the common type.

eqEv                                    :: Env -> Context -> (XPathValue -> XPathValue -> Bool) -> XPathValue -> XPathFilter
eqEv env cont fct f@(XPVBool _) g       = XPVBool (f `fct` xboolean cont env [g])
eqEv env cont fct f g@(XPVBool _)       = XPVBool (xboolean cont env [f] `fct` g)
eqEv env cont fct f@(XPVNumber _) g     = XPVBool (f `fct` xnumber cont env [g])
eqEv env cont fct f g@(XPVNumber _)     = XPVBool (xnumber cont env [f] `fct` g)
eqEv env cont fct f g                   = XPVBool (xstring cont env [f] `fct` xstring cont env [g])

-- -----------------------------------------------------------------------------

getOpFct                                :: Op -> Maybe (XPathValue -> XPathValue -> Bool)
getOpFct Eq                             = Just (==)
getOpFct NEq                            = Just (/=)
getOpFct Less                           = Just (<)
getOpFct LessEq                         = Just (<=)
getOpFct Greater                        = Just (>)
getOpFct GreaterEq                      = Just (>=)
getOpFct _                              = Nothing

-- -----------------------------------------------------------------------------

-- |
-- Filter for accessing the root element of a document tree

getRoot                                 :: XPathFilter
getRoot                                 = withXPVNode "Call to getRoot without a nodeset" $ getRoot'
    where
    getRoot' ns
        | nullNodeSet ns                = XPVError "Call to getRoot with empty nodeset"
        | otherwise                     = XPVNode . singletonNodeSet . getRoot'' . headNodeSet $ ns

    getRoot'' tree                      = case upNT tree of
                                          Nothing       -> tree
                                          Just t        -> getRoot'' t

-- -----------------------------------------------------------------------------

type NodeList = NavXmlTrees

type NodeListRes = Either XPathValue NodeList

nodeListResToXPathValue :: NodeListRes -> XPathValue
nodeListResToXPathValue = either id (XPVNode . toNodeSet)

nullNL  :: NodeListRes
nullNL  = Right []

plusNL  :: NodeListRes -> NodeListRes -> NodeListRes
plusNL res@(Left _) _                   = res
plusNL _            res@(Left _)        = res
plusNL (Right ns1)  (Right ns2)         = Right $ ns1 ++ ns2

sumNL   :: [NodeListRes] -> NodeListRes
sumNL   = foldr plusNL nullNL

mapNL   :: (NavXmlTree -> NodeListRes) -> NodeListRes -> NodeListRes
mapNL _ res@(Left _)    = res
mapNL f (Right ns)      = sumNL . map f $ ns

mapNL'  :: (Int -> NavXmlTree -> NodeListRes) -> NodeListRes -> NodeListRes
mapNL' _ res@(Left _)   = res
mapNL' f (Right ns)     = sumNL . zipWith f [1..] $ ns

-- ------------------------------------------------------------

-- |
-- Filter for accessing all nodes of a XPath-axis
--
--    * 1.parameter as :  axis specifier
--

getAxisNodes                            :: AxisSpec ->  NodeSet -> [NodeListRes]
getAxisNodes as                         =  map (Right . (fromJust $ lookup as axisFctL)) . fromNodeSet

-- |
-- Axis-Function-Table.
-- Each XPath axis-specifier is mapped to the corresponding axis-function

axisFctL                                :: [(AxisSpec, (NavXmlTree -> NavXmlTrees))]
axisFctL                                = [ (Ancestor           , ancestorAxis)
                                          , (AncestorOrSelf     , ancestorOrSelfAxis)
                                          , (Attribute          , attributeAxis)
                                          , (Child              , childAxis)
                                          , (Descendant         , descendantAxis)
                                          , (DescendantOrSelf   , descendantOrSelfAxis)
                                          , (Following          , followingAxis)
                                          , (FollowingSibling   , followingSiblingAxis)
                                          , (Parent             , parentAxis)
                                          , (Preceding          , precedingAxis)
                                          , (PrecedingSibling   , precedingSiblingAxis)
                                          , (Self               , selfAxis)
                                          ]

-- -----------------------------------------------------------------------------
-- |
-- evaluates a location path,
-- evaluation of an absolute path starts at the document root,
-- the relative path at the context node

locPathEval                             :: Env -> LocationPath -> XPathFilter
locPathEval env (LocPath Rel steps)     = evalSteps env steps
locPathEval env (LocPath Abs steps)     = evalSteps env steps . getRoot


-- -----------------------------------------------------------------------------

evalSteps                               :: Env -> [XStep] -> XPathFilter
evalSteps env steps ns                  = foldl (flip $ evalStep env) ns steps

-- |
-- evaluate a single XPath step
-- namespace-axis is not supported

evalStep                                :: Env -> XStep -> XPathFilter

evalStep _   (Step Namespace _  _ ) _   = XPVError "namespace-axis not supported"
evalStep _   (Step Attribute nt _ ) ns  = withXPVNode "Call to getAxis without a nodeset"
                                          evalAttr'
                                          ns
    where
      evalAttr' = nodeListResToXPathValue . sumNL . map (evalAttr nt) . getAxisNodes Attribute

evalStep env (Step axisSpec  nt pr) ns  = withXPVNode "Call to getAxis without a nodeset"
                                          evalSingleStep
                                          ns
    where
      evalSingleStep = nodeListResToXPathValue . sumNL . map (evalStep' env pr nt) . getAxisNodes axisSpec

-- -----------------------------------------------------------------------------

-- the goal:
-- evalAttr                                :: NodeTest -> NavXmlTrees -> XPathValue

evalAttr                                :: NodeTest -> NodeListRes -> NodeListRes
evalAttr nt                             =  mapNL (Right . evalAttrNodeTest nt)

evalAttrNodeTest                        :: NodeTest -> NavXmlTree -> NavXmlTrees
evalAttrNodeTest (NameTest qn)
                 ns@(NT (NTree (XAttr qn1) _) _ix _ _ _)
                                        = if ( ( uri == uri1               && lp == lp1)
                                               ||
                                               ((uri == "" || uri == uri1) && lp == "*")
                                             )
                                          then [ns]
                                          else []
    where
    uri                                 = namespaceUri qn
    uri1                                = namespaceUri qn1
    lp                                  = localPart    qn
    lp1                                 = localPart    qn1

evalAttrNodeTest (TypeTest XPNode)
                 ns@(NT (NTree (XAttr _) _) _ix _ _ _)
                                        = [ns]
evalAttrNodeTest _ _                    = []

-- -----------------------------------------------------------------------------

evalStep'                               :: Env -> [Expr] -> NodeTest -> NodeListRes -> NodeListRes
evalStep' env pr nt                     = evalPredL env pr . nodeTest nt

evalPredL                               :: Env -> [Expr] -> NodeListRes -> NodeListRes
evalPredL env pr ns                     = foldl (flip $ evalPred env) ns pr

evalPred                                :: Env -> Expr -> NodeListRes -> NodeListRes
evalPred _   _  res@(Left _)            = res
evalPred env ex arg@(Right ns)          = mapNL' (evalPred' env ex (length ns)) arg 

evalPred'                               :: Env -> Expr -> Int -> Int -> NavXmlTree -> NodeListRes
evalPred' env ex len pos x              = case testPredicate env (pos, len, x) ex (XPVNode . singletonNodeSet $ x) of
                                          e@(XPVError _) -> Left e
                                          XPVBool True   -> Right [x]
                                          XPVBool False  -> Right []
                                          _              -> Left $ XPVError "Value of testPredicate is not a boolean"

testPredicate                                   :: Env -> Context -> Expr -> XPathFilter
testPredicate env context@(pos, _, _) ex ns
                                        = case evalExpr env context ex ns of
                                          XPVNumber (Float f) -> XPVBool (f == fromIntegral pos)
                                          XPVNumber _         -> XPVBool False
                                          _                   -> xboolean context env [evalExpr env context ex ns]

-- -----------------------------------------------------------------------------
-- |
-- filter for selecting a special type of nodes from the current fragment tree
--
-- the filter works with namespace activated and without namespaces.
-- If namespaces occur in XPath names, the uris are used for matching,
-- else the name prefix
--
--    Bugfix : "*" (or any other name-test) must not match the root node

nodeTest                                :: NodeTest -> NodeListRes -> NodeListRes
nodeTest _ res@(Left _)                 = res
nodeTest t (Right ns)                   = Right . nodeTest' t $ ns

nodeTest'                               :: NodeTest -> NodeList -> NodeList
nodeTest' (NameTest q)
    | isWildcardTest                    = filterNodes' (wildcardTest q)
    | otherwise                         = filterNodes' (nameTest     q)
      where
      isWildcardTest                    = localPart q == "*"

nodeTest' (PI n)                        = filterNodes' isPiNode
                                          where
                                          isPiNode = maybe False ((== n) . qualifiedName) . XN.getPiName

nodeTest' (TypeTest t)                  = typeTest t

-- |
-- the filter selects the NTree part of a navigable tree and
-- tests whether the node is of the necessary type
--
--    * 1.parameter fct :  filter function from the XmlTreeFilter module which tests the type of a node

filterNodes'                            :: (XNode -> Bool) -> NodeList -> NodeList
filterNodes' fct                        = filter (fct . dataNT)

-- -----------------------------------------------------------------------------

nameTest                                :: QName -> XNode -> Bool
nameTest xpName (XTag elemName _)
    | namespaceAware                    = localPart xpName == localPart elemName
                                          &&
                                          namespaceUri  xpName == namespaceUri  elemName
    | otherwise                         = qualifiedName xpName == qualifiedName elemName
    where
    namespaceAware                      = not . null . namespaceUri $ xpName

nameTest _ _                            = False

-- -----------------------------------------------------------------------------

wildcardTest                            :: QName -> XNode -> Bool
wildcardTest xpName (XTag elemName _)
    | namespaceAware                    = namespaceUri xpName == namespaceUri elemName
    | prefixMatch                       = namePrefix   xpName == namePrefix   elemName
    | otherwise                         = localPart  elemName /= t_root                 -- all names except the root name "/"
    where
    namespaceAware                      = not . null . namespaceUri $ xpName
    prefixMatch                         = not . null . namePrefix   $ xpName

wildcardTest _ _                        = False

-- -----------------------------------------------------------------------------
-- |
-- tests whether a node is of a special type
--
typeTest                                :: XPathNode -> NodeList -> NodeList
typeTest XPNode                         = id
typeTest XPCommentNode                  = filterNodes' XN.isCmt
typeTest XPPINode                       = filterNodes' XN.isPi
typeTest XPTextNode                     = filterNodes' XN.isText

-- -----------------------------------------------------------------------------
-- |
-- evaluates a boolean expression, the evaluation is non-strict

boolEval                                :: Env -> Context -> Op -> [Expr] -> XPathFilter
boolEval _ _ op [] _                    = XPVBool (op == And)
boolEval env cont Or (x:xs) ns          = case xboolean cont env [evalExpr env cont x ns] of
                                          e@(XPVError _) -> e
                                          XPVBool True   -> XPVBool True
                                          _              -> boolEval env cont Or xs ns

boolEval env cont And (x:xs) ns         = case xboolean cont env [evalExpr env cont x ns] of
                                          e@(XPVError _) -> e
                                          XPVBool True   -> boolEval env cont And xs ns
                                          _              -> XPVBool False
boolEval _ _ _ _ _                      = XPVError "Call to boolEval with a wrong argument"


-- -----------------------------------------------------------------------------
-- |
-- returns the value of a variable
getVariable                             :: Env -> VarName -> XPathFilter
getVariable env name _                  = fromMaybe (XPVError ("Variable: " ++ show name ++ " not found")) $
                                          lookup name (getVarTab env)


-- -----------------------------------------------------------------------------
-- |
-- evaluates a function,
-- computation is done by 'XPathFct.evalFct' which is defined in "XPathFct".

fctEval                                 :: Env -> Context -> FctName -> [Expr] -> XPathFilter
fctEval env cont name args              = evalFct name env cont . evalExprL env cont args

-- -----------------------------------------------------------------------------
-- |
-- evaluates an arithmetic operation.
--
--   1.parameter f :  arithmetic function from "XPathArithmetic"
--
numEval                                 :: (Op -> XPathValue -> XPathValue -> XPathValue) ->
                                           Op -> [XPathValue] -> XPathValue
numEval f op                            = foldl1 (f op)

-- -----------------------------------------------------------------------------
-- |
-- Convert list of ID attributes from DTD into a space separated 'XPVString'
--

idAttributesToXPathValue                :: XmlTrees -> XPathValue
idAttributesToXPathValue ts             = XPVString (foldr (\ n -> ( (valueOfDTD a_value n ++ " ") ++)) [] ts)

-- -----------------------------------------------------------------------------
-- |
-- Extracts all ID-attributes from the document type definition (DTD).
--

getIdAttributes                         :: XmlTree -> XmlTrees
getIdAttributes                         = runLA $
                                          AT.getChildren
                                          >>>
                                          isDTD
                                          >>>
                                          AT.deep (isIdAttrType)

-- ----------------------------------------

isIdAttrType                            :: ArrowDTD a => a XmlTree XmlTree
isIdAttrType                            = hasDTDAttrValue a_type (== k_id)

valueOfDTD                              :: String -> XmlTree -> String
valueOfDTD n                            = concat . runLA ( getDTDAttrl >>^ lookup1 n )

hasDTDAttrValue                         :: ArrowDTD a => String -> (String -> Bool) -> a XmlTree XmlTree
hasDTDAttrValue an p                    = filterA $
                                          getDTDAttrl >>> isA (p . lookup1 an)

-- ------------------------------------------------------------
