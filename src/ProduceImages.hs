module ProduceImages (renderColouredShapes, renderTransformations, renderOverlapping, renderMaskingSimple, renderMasking) where

-- Imports for Shapes
import Shapes
import Render (renderColoured,defaultWindow)
import qualified System.ProgressBar as PB

-- Render coloured shapes and store into img directory
renderColouredShapes ::  ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> IO ()
renderColouredShapes redCircle greenRectangle blueEllipse orangePolygon blackMandelbrot = do
     pb <- PB.newProgressBar PB.defStyle 5 (PB.Progress 0 5 ())
     renderColoured "img/red-circle.png" defaultWindow redCircle
     PB.incProgress pb 1
     renderColoured "img/green-rectangle.png" defaultWindow greenRectangle
     PB.incProgress pb 1
     renderColoured "img/blue-ellipse.png" defaultWindow blueEllipse
     PB.incProgress pb 1
     renderColoured "img/orange-polygon.png" defaultWindow orangePolygon
     PB.incProgress pb 1
     renderColoured "img/black-mandelbrot.png" defaultWindow blackMandelbrot
     PB.incProgress pb 1

-- Render shapes with transformations and store into img directory
renderTransformations ::  ColouredDrawing -> IO ()
renderTransformations transformations = do
     pb <- PB.newProgressBar PB.defStyle 10 (PB.Progress 0 1 ())
     renderColoured "img/transformations.png" defaultWindow transformations
     PB.incProgress pb 1

-- Render shapes with overlapping and store into img directory
renderOverlapping :: ColouredDrawing -> IO ()
renderOverlapping overlapping = do
     pb <- PB.newProgressBar PB.defStyle 10 (PB.Progress 0 1 ())
     renderColoured "img/overlapping.png" defaultWindow overlapping
     PB.incProgress pb 1

-- Render shapes with simple masking and store into img directory
renderMaskingSimple :: ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> IO ()
renderMaskingSimple blackCircle yellowRectangle fakeMasking realMasking1 realMasking2 = do
     pb <- PB.newProgressBar PB.defStyle 10 (PB.Progress 0 5 ())
     renderColoured "img/black-circle.png" defaultWindow blackCircle
     PB.incProgress pb 1
     renderColoured "img/yellow-rectangle.png" defaultWindow yellowRectangle
     PB.incProgress pb 1
     renderColoured "img/fake-masking.png" defaultWindow fakeMasking
     PB.incProgress pb 1
     renderColoured "img/real-masking-1.png" defaultWindow realMasking1
     PB.incProgress pb 1
     renderColoured "img/real-masking-2.png" defaultWindow realMasking2
     PB.incProgress pb 1

-- Render shapes with more complex masking and store into img directory
renderMasking :: ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> ColouredDrawing -> IO ()
renderMasking maskedImage1 maskedImage2 maskedImage3 maskedImage4 maskedImage5 = do
     pb <- PB.newProgressBar PB.defStyle 10 (PB.Progress 0 5 ())
     renderColoured "img/masking-1.png" defaultWindow maskedImage1
     PB.incProgress pb 1
     renderColoured "img/masking-2.png" defaultWindow maskedImage2
     PB.incProgress pb 1
     renderColoured "img/masking-3.png" defaultWindow maskedImage3
     PB.incProgress pb 1
     renderColoured "img/masking-4.png" defaultWindow maskedImage4
     PB.incProgress pb 1
     renderColoured "img/masking-5.png" defaultWindow maskedImage5
     PB.incProgress pb 1