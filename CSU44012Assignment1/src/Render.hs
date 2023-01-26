module Render(Window,defaultWindow, renderColoured) where
import Codec.Picture
import Shapes


--  A window specifies what part of the world to render and at which
--  resolution.
--  Values are top left & bottom right corner to be rendered, 
--             and the size of the output device to render into
data Window = Window Point Point (Int,Int)

-- Default window renders a small region around the origin into 
-- a 500x500 pixel image
defaultWindow :: Window
defaultWindow = Window (point (-10) (-10)) (point 10 10) (500,500)

-- lookup1 (O(1) operation) returns the point that corresponds to the pixel of a window 
-- We need to double check that x and y are within the window before we can say the point that it represents
lookup1 :: Window -> (Int, Int) -> Point
lookup1 (Window pointAtTopLeftCorner pointAtBottomRightCorner (width, height)) (x,y) = 
  -- First make sure that the coordinates are within the window
  if (x < width && y < height && x >= 0 && y >= 0) 
  -- If so, then return the point that corresponds to the pixel of the window (N.B. getX and getY get the x and y coordinates from a point : https://hackage.haskell.org/package/SGplus-1.1/docs/Data-SG-Vector.html#v:getX)
    then point (getSample (getX pointAtTopLeftCorner) (getX pointAtBottomRightCorner) width x) (getSample (getY pointAtTopLeftCorner) (getY pointAtBottomRightCorner) height (height-y))
    -- If not, then return an empty point
    else point 0 0

-- getSample (O(1) operation) returns a sample between the range startingRange to endingRange, splitting it up into n equal segments (i.e. numberOfSegmentsToSplitInto), and returning the index-th segment (index starting from 0)
-- getSample: getSample 1 2 5 2 = 1.5 (i.e. returns 1.5 which is index 2 (or element 3 from above))
getSample :: Double -> Double -> Int -> Int -> Double
getSample startingRange endingRange numberOfSegmentsToSplitInto index = startingRange + (fromIntegral(index) * ((endingRange-startingRange) / (fromIntegral $ numberOfSegmentsToSplitInto-1)))

toPixelRGBA8 :: Colour -> PixelRGBA8
toPixelRGBA8 col = PixelRGBA8 (r col) (g col) (b col) (a col)

-- Render a drawing into an image, then save into a file
render :: String -> Window -> Drawing -> IO ()
render path win sh = writePng path $ generateImage pixRenderer w h
    where
      Window _ _ (w,h) = win
      pixRenderer x y = PixelRGB8 a a a where a = (colourForImage $ lookup1 win (x,y))
      colourForImage p | p `inside` sh = 255
                      | otherwise     = 0

-- Render a coloured drawing into an image, then save into a file
renderColoured :: String -> Window -> ColouredDrawing -> IO ()
renderColoured path win sh = writePng path $ generateImage pixRenderer w h
    where
      Window _ _ (w,h) = win
      pixRenderer x y = toPixelRGBA8 $ getColour (lookup1 win (x,y)) sh