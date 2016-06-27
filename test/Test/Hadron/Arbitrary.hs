{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Test.Hadron.Arbitrary where

import qualified Data.ByteString as BS

import           P

import           Hadron.Data

import           Test.Hadron.Gen
import           Test.QuickCheck
import           Test.QuickCheck.Instances ()

instance Arbitrary HTTPVersion where
  arbitrary = elements [minBound..maxBound]

instance Arbitrary HTTPMethod where
  arbitrary = fmap HTTPMethod $ oneof [
      genStdHttpMethod
    , genToken EmptyForbidden
    ]

instance Arbitrary HeaderName where
  arbitrary = HeaderName <$> genToken EmptyForbidden

-- Tabs are allowed, but not as the initial character.
instance Arbitrary HeaderValue where
  arbitrary = fmap HeaderValue $ oneof [
      genVisible EmptyAllowed
    , genVisibleWithTab
    ]
    where
      genVisibleWithTab = liftM2 (<>) (genVisible EmptyForbidden) $ oneof [
          genVisible EmptyForbidden
        , fmap ("\t" <>) genVisibleWithTab
        , liftM2 (<>) (genVisible EmptyAllowed) genVisibleWithTab
        ]

instance Arbitrary URIPath where
  arbitrary = fmap URIPath genURIPath

-- FIXME: have a more realistic example as well as the "everything we're
-- allowed to do" version
instance Arbitrary QueryString where
  arbitrary = frequency [(1, pure NoQueryString), (999, genQueryString')]
    where
      genQueryString' = do
        ps <- fmap BS.concat $ listOf genQueryStringPart
        pure . QueryStringPart $ "?" <> ps
