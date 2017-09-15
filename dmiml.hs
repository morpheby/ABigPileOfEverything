#!/usr/bin/env runhaskell

{-
 - dmiml.hs
 - test
 - 
 - Created by Илья Михальцов on 2013-06-04.
 - Copyright 2013 Илья Михальцов. All rights reserved.
 -}


f :: Int -> Int -> Int -> Int -> Int

f _ _ _ k | k < 0  = 0
f _ _ _ 0          = 1
f a b c k          = (f a b c (k-a)) + (f a b c (k-b)) + (f a b c (k-c))

f1 = f 3 5 7

g  :: Int -> [Int] -> Int

g  _ []                         = 0
g  k _        | k < 0           = 0
g  k (x:[])   | k `mod` x == 0  = 1
              | otherwise       = 0
g  k (x:xs)                     = (g k xs) + (g (k-x) (x:xs))
