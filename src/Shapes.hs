module Shapes(
  Shape, Point, Vector, Transform, Drawing, ColouredDrawing, Colour,
  point, getX, getY, empty, circle, square, rectangle, ellipse, polygon,
  identity, translate, rotate, scale, shear, (<+>), inside, next, mandelbrot, 
  fairlyClose, inMandelbrotSet, approxTest, maskImages,
  colour, red, green, blue, transparent, orange, yellow, cyan,
  purple, magenta, pink, black, white, r, g, b, a, getColour)  where

-- Import Word for Word8 (0 to 255 value) for colours described with (r)ed (g)reen (b)lue (a)lpha.
import Data.Word
import Data.Bool

-- Utilities
data Vector = Vector Double Double
              deriving Show
vector = Vector

cross :: Vector -> Vector -> Double
cross (Vector a b) (Vector a' b') = a * a' + b * b'

add :: Matrix -> Matrix -> Matrix
add (Matrix (Vector a1 b1) (Vector c1 d1)) (Matrix (Vector a2 b2) (Vector c2 d2)) = Matrix (Vector (a1+a2) (b1+b2)) (Vector (c1+c2) (d1+d2))

mult :: Matrix -> Vector -> Vector
mult (Matrix r0 r1) v = Vector (cross r0 v) (cross r1 v)

invert :: Matrix -> Matrix
invert (Matrix (Vector a b) (Vector c d)) = matrix (d / k) (-b / k) (-c / k) (a / k)
  where k = a * d - b * c
        
-- 2x2 square matrices are all we need.
data Matrix = Matrix Vector Vector
              deriving Show

matrix :: Double -> Double -> Double -> Double -> Matrix
matrix a b c d = Matrix (Vector a b) (Vector c d)

getX (Vector x y) = x
getY (Vector x y) = y

-- Point (Vector for for x and y)
type Point  = Vector
point :: Double -> Double -> Point
point = vector

-- Shapes
data Shape = Empty 
           | Circle 
           | Square
           | Mandelbrot
           | Rectangle
           | Ellipse
           | Polygon [Point]
             deriving Show

-- The polygon is defined by a series of points listed in clockwise order
polygon :: [Point] -> Shape
empty, circle, square, mandelbrot, rectangle, ellipse :: Shape

empty = Empty
circle = Circle
square = Square
mandelbrot = Mandelbrot
rectangle = Rectangle
ellipse = Ellipse
polygon (x:xs) = Polygon (x:xs)

-- Colours
data Colour = Colour {r::Word8, g::Word8, b::Word8, a::Word8} deriving Show
colour r g b a = Colour r g b a
transparent = Colour 255 255 255 0
black = Colour 0 0 0 255
white = Colour 255 255 255 255
yellow = Colour 255 255 0 255
orange = Colour 255 140 0 255
green = Colour 0 255 0 255
blue = Colour 0 0 255 255
red = Colour 255 0 0 255
pink = Colour 255 192 203 255
magenta = Colour 255 0 255 255
purple = Colour 128 0 128 255
cyan = Colour 0 255 255 255

-- Transformations
data Transform = Identity
           | Translate Vector
           | Scale Vector
           | Shear Matrix
           | Compose Transform Transform
           | Rotate Matrix
             deriving Show

identity = Identity
translate = Translate
scale = Scale
shearX angle = Shear $ matrix (1) (-sin angle) (0) (1)
shearY angle = Shear $ matrix (1) (0) (sin angle) (1)
-- OPTIMISATION BEFORE RENDERING #1: If one of the angles for shear is 0 (or both), then we can avoid a useless function call (i.e. shearX 0 or shearY 0) which would have no effect.
shear angleX angleY = if (angleX == 0)
                      then shearY angleY
                      else if (angleY == 0)
                      then shearX angleX
                      else if (angleX == 0 && angleY == 0)
                      then Identity
                      else shearX angleX <+> shearY angleY
rotate angle = Rotate $ matrix (cos angle) (-sin angle) (sin angle) (cos angle)

-- OPTIMISATION BEFORE RENDERING #2, #3 and #4: Translate (Vector 5 5) <+> Translate (Vector 5 5) is equivalent to Translate (Vector 10 10).
-- Instead of doing two separate function calls to Translate, we can simplify this. This works the same with Scale. This also works with
-- Rotate except you get the summation of both angles to save 1 extra function call.
Translate (Vector x1 y1) <+> Translate (Vector x2 y2) = Translate (Vector (x1+x2) (y1+y2))
Scale (Vector x1 y1) <+> Scale (Vector x2 y2) = Scale (Vector (x1+x2) (y1+y2))
Rotate angle1 <+> Rotate angle2 = Rotate (angle1 `add` angle2)
t0 <+> t1 = Compose t0 t1

transform :: Transform -> Point -> Point
transform Identity                   x = id x
transform (Translate (Vector tx ty)) (Vector px py)  = Vector (px - tx) (py - ty)
transform (Scale (Vector tx ty))     (Vector px py)  = Vector (px / tx) (py / ty)
transform (Shear m)                  p = (invert m) `mult` p
transform (Rotate m)                 p = (invert m) `mult` p
transform (Compose t1 t2)            p = transform t2 $ transform t1 p

-- Drawing
type ColouredDrawing = [(Transform, Shape, Colour)]
type Drawing = [(Transform,Shape)]

-- We use white below to ensure the background of all images is white
getColour :: Point -> ColouredDrawing -> Colour
getColour point colouredDrawing = getOverallColour point colouredDrawing white 

getOverallColour :: Point -> ColouredDrawing -> Colour -> Colour
getOverallColour point [] colour = colour
getOverallColour point ((drawingTransform, drawingShape, drawingColour):ds) colour = 
  if (inside1 point (drawingTransform, drawingShape) == False)
    then (getOverallColour point ds) colour 
    else (getOverallColour point ds) ((Colour (mixColour (r colour) (r drawingColour) (a drawingColour)) (mixColour (g colour) (g drawingColour) (a drawingColour)) (mixColour (b colour) (b drawingColour) (a drawingColour)) 255)) 

mixColour :: Word8 -> Word8 -> Word8 -> Word8 
mixColour bgColour fgColour fgAlpha = fromIntegral $ div ((fromIntegral bgColour) * (255 - (fromIntegral fgAlpha)) + (fromIntegral fgColour) * (fromIntegral fgAlpha)) 255 

maskImages :: Word8 -> ColouredDrawing -> ColouredDrawing -> ColouredDrawing
maskImages _ _ [] = []
-- OPTIMISATION BEFORE RENDERING #5: Masking with value 0 passed in should simply return the image that would have been masked over.
maskImages 0 drawing _ = drawing
maskImages transparency [] ((maskTransform, maskShape, maskColour) : rest) = (maskTransform, maskShape, (Colour (r maskColour) (g maskColour) (b maskColour) transparency)) : maskImages transparency [] rest
maskImages transparency ((maskTransform, maskShape, maskColour) : rest) (drawing) = (maskTransform, maskShape, maskColour) : maskImages transparency rest drawing 

inside :: Point -> Drawing -> Bool
inside p d = or $ map (inside1 p) d

inside1 :: Point -> (Transform, Shape) -> Bool
inside1 p (t,s) = insides (transform t p) s

insides :: Point -> Shape -> Bool
p `insides` Empty = False
p `insides` Circle = distance p <= 1
p `insides` Square = maxnorm  p <= 1
p `insides` Mandelbrot = approxTest 1000 p
Vector x y `insides` Polygon (first:(second:[])) = halfLine (Vector x y) first second
Vector x y `insides` Polygon (first:(second:rest)) = if (halfLine (Vector x y) first second == False)
                                                      then False
                                                      else insides ((Vector x y)) (Polygon (second:rest)) 
-- We use (16/9) below as it is the ratio of 16 (width) to 9 (height) to stretch the shape into a rectangle (otherwise it would be a square if we used 1) and into a ellipse (otherwise it would be a circle if we used 1).
Vector x y `insides` Rectangle = (sqrt (y**2) <= 1) && (sqrt (x**2) <= (16/9))
Vector x y `insides` Ellipse = (x**2/(16/9)**2) + (y**2/1**2) <= 1

-- Function below is from lecture slide 5 from Week 4 - Designing an eDSL (04.02 - Geometric regions and shapes)
halfLine :: (Vector) -> (Vector) -> (Vector) -> Bool
-- We subtract the x from x1, and y from y1, then subtract x1 from x2 and y1 from y2.
halfLine (Vector x y) (Vector x1 y1) (Vector x2 y2) = zcross (Vector (x1-x) (y1-y)) (Vector (x2-x1) (y2-y1)) < 0
                                                        where zcross (Vector a b) (Vector c d) = a*d - b*c                                                   

distance :: Point -> Double
distance (Vector x y ) = sqrt ( x**2 + y**2 )

maxnorm :: Point -> Double
maxnorm (Vector x y ) = max (abs x) (abs y)

-- Mandelbrot code (N.B. Taken  from research paper "Composing Fractals" by MARK P. JONES, which we discussed for the week 5 assignment)
next :: Point -> Point -> Point
next (Vector u v) (Vector x y) = Vector (x*x - y*y +u) (2*x*y+v)

mandelbrotFunction :: Point -> [Point]
mandelbrotFunction p = iterate (next p) (Vector 0 0)

fairlyClose :: Point -> Bool
fairlyClose (Vector u v) = (u*u + v*v) < 100

inMandelbrotSet :: Point -> Bool
inMandelbrotSet p = all fairlyClose (mandelbrotFunction p)

approxTest :: Int -> Point -> Bool
approxTest n p = all fairlyClose (take n (mandelbrotFunction p))