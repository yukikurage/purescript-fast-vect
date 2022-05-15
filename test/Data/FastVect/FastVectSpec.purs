module Data.FastVect.FastVectSpec where

import Prelude

import Data.FastVect.FastVect as FV
import Data.FastVect.Sparse.Read as FVR
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec ∷ Spec Unit
spec =
  describe "FastVect" do
    describe "Data.FastVect.FastVect" do
      describe "fromArray" do
        it "should create a Vect from an Array" do
          let
            actualSuccess ∷ Maybe (FV.Vect 3 String)
            actualSuccess = FV.fromArray (FV.term ∷ _ 3) [ "a", "b", "c" ]

            expectedSuccess = FV.append (FV.singleton "a") (FV.append (FV.singleton "b") (FV.singleton "c"))
            actualFail1 ∷ Maybe (FV.Vect 4 String)
            actualFail1 = FV.fromArray (FV.term ∷ _ 4) [ "a", "b", "c" ]

            actualFail2 ∷ Maybe (FV.Vect 2 String)
            actualFail2 = FV.fromArray (FV.term ∷ _ 2) [ "a", "b", "c" ]
          actualSuccess `shouldEqual` (Just expectedSuccess)
          actualFail1 `shouldEqual` Nothing
          actualFail2 `shouldEqual` Nothing

        it "should successfully acccess elements from a Vect" do
          let
            vect = FV.cons 1 $ FV.cons 2 $ FV.cons 3 $ FV.cons 4 FV.empty
          (FV.head vect) `shouldEqual` 1
          --(head empty) `shouldEqual` 1 -- should not compile
          (FV.index (FV.term :: _ 0) vect) `shouldEqual` 1
          (FV.index (FV.term :: _ 3) vect) `shouldEqual` 4
          --(index (term :: _ 4) vect) `shouldEqual` 1 -- should not compile

          (FV.drop (FV.term :: _ 4) vect) `shouldEqual` FV.empty
          (FV.drop (FV.term :: _ 3) vect) `shouldEqual` (FV.singleton 4)
          --(drop (term :: _ 5) vect) `shouldEqual` (singleton 4) -- should not compile

          (FV.take (FV.term :: _ 4) vect) `shouldEqual` vect
          (FV.take (FV.term :: _ 3) vect) `shouldEqual` (FV.cons 1 $ FV.cons 2 $ FV.cons 3 FV.empty)
          --let _ = (take (term :: _ 5) vect) -- should not compile
          pure unit
        it "should adjust an Array to a Vect" do
          let
            expectedPad = [ 0, 0, 0, 0, 0, 0, 0, 1, 2, 3 ]

            actualPad = FV.adjust (FV.term ∷ _ 10) 0 [ 1, 2, 3 ]

            expectedDrop = [ 1, 2, 3 ]

            actualDrop = FV.adjust (FV.term ∷ _ 3) 0 [ 0, 0, 0, 0, 1, 2, 3 ]

            expectedEqual = [ 1, 2, 3, 4, 5 ]
            actualEqual = FV.adjust (FV.term ∷ _ 5) 0 [ 1, 2, 3, 4, 5 ]

            expectedPadM = [ "", "", "", "", "a", "b", "c" ]
            actualPadM = FV.adjustM (FV.term ∷ _ 7) [ "a", "b", "c" ]
          (FV.toArray actualPad) `shouldEqual` expectedPad
          (FV.toArray actualDrop) `shouldEqual` expectedDrop
          (FV.toArray actualEqual) `shouldEqual` expectedEqual
          (FV.toArray actualPadM) `shouldEqual` expectedPadM
        it "should apply" do
          let
            applies = FV.cons (add 1) $ FV.cons (add 42) $ FV.cons (mul 5) $ FV.cons (sub 6) FV.empty

            expectedApplies = FV.cons 6 $ FV.cons  47 $ FV.cons  25 $ FV.cons 1 FV.empty
            actualApplies = applies <*> pure 5

          actualApplies `shouldEqual` expectedApplies
    describe "Data.FastVect.Sparse.Read" do
      describe "fromArray" do
        it "should create a Vect from an Array" do
          let
            actualSuccess ∷ Maybe (FVR.Vect 3 String)
            actualSuccess = FVR.fromMap (FVR.term ∷ _ 3) $ Map.fromFoldable [ 0 /\ "a", 2 /\ "b", 1 /\ "c" ]

            expectedSuccess = FVR.append (FVR.singleton "a") (FVR.append (FVR.singleton "c") (FVR.singleton "b"))
            actualFail1 ∷ Maybe (FVR.Vect 4 String)
            actualFail1 = FVR.fromMap (FVR.term ∷ _ 4) $ Map.fromFoldable [ 0 /\ "a", 22 /\ "b"]

            actualFail2 ∷ Maybe (FVR.Vect 2 String)
            actualFail2 = FVR.fromMap (FVR.term ∷ _ 2) $ Map.fromFoldable [ 0 /\ "a", 52 /\ "b" ]
          actualSuccess `shouldEqual` (Just expectedSuccess)
          actualFail1 `shouldEqual` Nothing
          actualFail2 `shouldEqual` Nothing

        it "should successfully acccess elements from a Vect" do
          let
            vect = FVR.cons 1 $ FVR.cons 2 $ FVR.cons 3 $ FVR.cons 4 FVR.empty
          (FVR.head vect) `shouldEqual` (Just 1)
          --(head empty) `shouldEqual` 1 -- should not compile
          (FVR.index (FVR.term :: _ 0) vect) `shouldEqual` (Just 1)
          (FVR.index (FVR.term :: _ 3) vect) `shouldEqual` (Just 4)
          --(index (term :: _ 4) vect) `shouldEqual` 1 -- should not compile

          (FVR.drop (FVR.term :: _ 4) vect) `shouldEqual` FVR.empty
          (FVR.drop (FVR.term :: _ 3) vect) `shouldEqual` (FVR.singleton 4)
          --(drop (term :: _ 5) vect) `shouldEqual` (singleton 4) -- should not compile

          (FVR.take (FVR.term :: _ 4) vect) `shouldEqual` vect
          (FVR.take (FVR.term :: _ 3) vect) `shouldEqual` (FVR.cons 1 $ FVR.cons 2 $ FVR.cons 3 FVR.empty)
          --let _ = (take (term :: _ 5) vect) -- should not compile
          pure unit
        it "should apply" do
          let
            applies = FVR.cons (add 1) $ FVR.cons (add 42) $ FVR.cons (mul 5) $ FVR.cons (sub 6) FVR.empty

            expectedApplies = FVR.cons 6 $ FVR.cons  47 $ FVR.cons  25 $ FVR.cons 1 FVR.empty
            actualApplies = applies <*> pure 5

          actualApplies `shouldEqual` expectedApplies
