-- |
-- Convert an XPath result set into a node set
--


module Text.XML.MXT.XPath.XPathToNodeSet
    ( xPValue2XmlNodeSet
    , emptyXmlNodeSet
    )
where

import Text.XML.MXT.DOM.TypeDefs
import Text.XML.MXT.XPath.XPathDataTypes

-- -----------------------------------------------------------------------------
-- |
-- Convert a a XPath-value into a XmlNodeSet represented by a tree structure
--
-- The XmlNodeSet can be used to traverse a tree an process all
-- marked nodes.

xPValue2XmlNodeSet                      :: XPathValue -> XmlNodeSet
xPValue2XmlNodeSet (XPVNode ns)         = toNodeSet' ns

xPValue2XmlNodeSet _                    = emptyXmlNodeSet

emptyXmlNodeSet                         :: XmlNodeSet
emptyXmlNodeSet                         = XNS False [] []

leafNodeSet                             :: XmlNodeSet
leafNodeSet                             = XNS True [] []

toNodeSet'                              :: NodeSet -> XmlNodeSet
toNodeSet'                              = pathListToNodeSet . map toPath . fromNodeSet

toPath                                  :: NavXmlTree -> XmlNodeSet
toPath                                  = upTree leafNodeSet


upTree                                  :: XmlNodeSet -> NavXmlTree -> XmlNodeSet
upTree ps (NT _ _ [] _ _)               = ps    -- root node reached

upTree ps (NT (NTree n _)
              ix par _left _right)      = upTree ps' $ head par
    where
    ps'                                 = pix n

    pix (XAttr qn)                      = XNS False [qn] []
    pix _                               = XNS False []   [(ix, ps)]

pathListToNodeSet                       ::[XmlNodeSet] -> XmlNodeSet
pathListToNodeSet                       = foldr mergePaths emptyXmlNodeSet
    where
    mergePaths (XNS p1 al1 cl1)
               (XNS p2 al2 cl2)         = XNS (p1 || p2) (al1 ++ al2) (mergeSubPaths cl1 cl2)

    mergeSubPaths []       sp2          = sp2
    mergeSubPaths (s1:sp1) sp2          = mergeSubPath s1 (mergeSubPaths sp1 sp2)

    mergeSubPath s1 []                  = [s1]
    mergeSubPath s1@(ix1,p1)
                 sl@(s2@(ix2, p2) : sl')
        | ix1 < ix2                     = s1 : sl
        | ix1 > ix2                     = s2 : mergeSubPath s1 sl'              -- ordered insert of s1
        | otherwise                     = (ix1, mergePaths p1 p2) : sl'         -- same ix merge subpaths

-- -----------------------------------------------------------------------------
