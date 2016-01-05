{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -fplugin Data.UnitsOfMeasure.Plugin #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Data.UnitsOfMeasure.Extra
  ( module Data.UnitsOfMeasure
  , cube
  , square
  , mod'
  ) where

import qualified Data.Fixed as F (mod')
import Data.Coerce (coerce)
import Data.UnitsOfMeasure
import Data.UnitsOfMeasure.Internal (Quantity(..))

cube :: Num a => Quantity a v -> Quantity a (v ^: 3)
cube x = x *: x *: x

square :: Num a => Quantity a v -> Quantity a (v ^: 2)
square x = x *: x

mod' :: forall a v. Real a => Quantity a v -> Quantity a v -> Quantity a v
mod' = coerce (F.mod' :: a -> a -> a)
