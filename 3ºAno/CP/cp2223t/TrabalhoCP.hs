module TrabalhoCP where

import Rose
import List
import Cp
import Svg
import Control.Concurrent
import LTree

type Point = (Double,Double)
type Side  = Double 
type Square = (Point,Side)
type Team = String


geneCata(a,l)=a:concat l

g1(((x,y),z),w) =((x+z/3,y+z/3),z/3)
g2(((x,y),z),w) = if w>0 then [(((x,y),z/3),w-1),  (((x+z/3,y),z/3),w-1),  (((x+(2*z/3),y),z/3),w-1), (((x,y+z/3),z/3),w-1), (((x+2*z/3,y+z/3),z/3),w-1), (((x,y+2*z/3),z/3),w-1), (((x+z/3,y+2*z/3),z/3),w-1) , (((x+2*z/3,y+2*z/3),z/3),w-1)] 
                  else []

geneAna=split g1 g2 

sierpinski=hyloRose geneCata geneAna


sq2svg (p, l) = (color "#67AB9F". polyg) [p, p .+ (0, l), p .+ (l, l), p .+ (l, 0)]
drawSq x = picd'' [Svg.scale 0.44 (0, 0) (x >>= sq2svg)]

await = threadDelay 1000000

sierp4 = drawSq (sierpinski (((0, 0), 32), 3))
constructSierp5 = do 
        drawSq (sierpinski (((0, 0), 32), 0))
        await
        drawSq (sierpinski (((0, 0), 32), 1))
        await
        drawSq (sierpinski (((0, 0), 32), 2))
        await
        drawSq (sierpinski (((0, 0), 32), 3))
        await
        drawSq (sierpinski (((0, 0), 32), 4))
        await
   
carpets :: Int ->[[Square]]
carpets 0 = []
carpets n =carpets (n-1) ++ [sierpinski(((0,0),32),n-1)]

present = mmap(\l -> do { square <- drawSq l;await})

constructSierp= present.carpets
    
    


