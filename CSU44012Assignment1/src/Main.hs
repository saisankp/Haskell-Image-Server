{-# LANGUAGE OverloadedStrings #-}

module Main where

-- Imports for Shapes
import Shapes
import Render (renderColoured, defaultWindow)
import ProduceImages (renderColouredShapes, renderTransformations, renderOverlapping, renderMaskingSimple, renderMasking)

-- Imports for Blaze and Scotty
import Data.Text.Lazy
import Web.Scotty
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Blaze.Html.Renderer.Text as R

-- Import for CSS applied to Image Server
import CSS (css)

-- Below are different drawings for different sections of the Image Server
-- Section 1: Show coloured shapes
redCircle = [(identity, circle, red)]
greenRectangle = [(identity, rectangle, green)]
blueEllipse = [(identity, ellipse, blue)]
orangePolygon = [(identity, polygon [point (-2) 3.5, point 2 3.5, point 4 0, point 2 (-3.5), point (-2) (-3.5), point (-4) 0, point (-2) 3.5], orange)]
blackMandelbrot = [(identity, mandelbrot, black)]   

-- Section 2: Show transformations
transformations = [(shear 45 0, rectangle, green), (translate (point 4 (-4)), circle, red), (rotate 45 <+> translate (point 1 6), ellipse, blue), (scale (point 2 2) <+> translate (point (-2) (-2)), polygon [point (-0.5) 0.875, point 0.5 0.875, point 1 0, point 0.5 (-0.875), point (-0.5) (-0.875), point (-1) 0, point (-0.5) 0.875], orange), (rotate 180 <+> scale (point 1 1) <+> translate (point (-4) 1), mandelbrot, black)]      

-- Section 3: Show overlapping
overlapping = [(scale (point 2 2), rectangle, green), (scale (point 2 2) <+> translate (point (2) (1)), ellipse, blue), (scale (point 2 2) <+> translate (point (3) (2)), circle, red), (scale (point 2 2) <+> translate (point (-1) (-1)), mandelbrot, black)]

-- Section 3: Show masking #1 (simple example)
maskedImage1 = maskImages 255 overlapping transformations
maskedImage2 = maskImages 100 overlapping transformations 
maskedImage3 = maskImages 50 overlapping transformations 
maskedImage4 = maskImages 25 overlapping transformations 
maskedImage5 = maskImages 0 overlapping transformations 

-- Section 4: Show masking #2 (using images from section 2 and 3)
blackCircle = [(scale (point 2 2), circle, black)]
yellowRectangle = [(scale (point 0.5 0.5), rectangle, yellow)]
fakeMasking =  [(scale (point 2 2), circle, black), (scale (point 0.5 0.5), rectangle, yellow)]
realMasking1 = maskImages 0 blackCircle yellowRectangle
realMasking2 = maskImages 255 blackCircle yellowRectangle

-- N.B: Optimisations have been added to the DSL program that is run before it is rendered below.
-- This is in the form of optimised transformations that occur while making the drawings above (Seen as comments above each optimisation in Shapes.hs)
main = do
     putStrLn "Rendering images showcasing coloured shapes (Step 1/5)..."
     renderColouredShapes redCircle greenRectangle blueEllipse orangePolygon blackMandelbrot
     putStrLn "Rendering images showcasing transformations (Step 2/5)..."
     renderTransformations transformations
     putStrLn "Rendering images showcasing overlapping (Step 3/5)..."
     renderOverlapping overlapping
     putStrLn "Rendering image batch #1 showcasing simple masking (Step 4/5)..."
     renderMaskingSimple blackCircle yellowRectangle fakeMasking realMasking1 realMasking2
     putStrLn "Rendering image batch #2 showcasing complex masking (Step 5/5)..."
     renderMasking maskedImage1 maskedImage2 maskedImage3 maskedImage4 maskedImage5
     scotty 3000 $ do
          get "/" $ do
               html $ R.renderHtml $ do
                         H.style (css)
                         H.div H.! A.class_ "webpage" $ do
                                             H.h1 "Image Server - CSU44012"
                                             H.h2 "Student name: Prathamesh Sai"
                                             H.h2 "Student ID: 19314123"
                                             H.h3 "For this assignment, I have to provide a number of shapes with their specified colour. The shapes that can be produced by this image server are a circle, rectangle, ellipse, polygon, and a mandelbrot set. These can be coloured red, orange, yellow, green, blue, cyan, purple, magenta, pink, black, white and can also be transparent. You can view them all by pressing the button below."
                                             H.a "Coloured shapes" H.! A.href "http://localhost:3000/coloured-shapes"  H.! A.class_ "button"
                                             H.h3 "Also, I have to provide a set of basic affine transformations. These include scale, rotate, shear, translate, and functions to combine these transformations with the shapes. You can view them in action by pressing the button below where I also show how multiple shapes can be fitted into the same image using these transformations."
                                             H.a "Affine transformations" H.! A.href "http://localhost:3000/transformations"  H.! A.class_ "button"
                                             H.h3 "The images produced must be able to show that you can overlap shapes so that one is on top of the other. You can view this being done by pressing the button below."
                                             H.a "Overlapping shapes" H.! A.href "http://localhost:3000/overlapping" H.! A.class_ "button"
                                             H.h3 "I have to provide a masking functionality to mask images so that when one is overlaid with another, the user can specify which parts are seen. You can view masking by clicking the button below where I have a black circle and yellow rectangle, and use masking to be able to hide or see the yellow rectangle overlaid on the black circle."
                                             H.a "Masked images" H.! A.href "http://localhost:3000/masking" H.! A.class_ "button"
                                             H.h3 "I have already shown the functionality of masking, however I want to re-iterate the fact that you can mask 2 images that have many shapes in each. You can click below to see a mask of the image from the affine transformations (from button 2 on this page) masked over the image from the overlapping shapes (from button 3 on this page). I also use different values when masking meaning I am able to alter how much of the affine transformations image is being shown."
                                             H.a "Masked images #2" H.! A.href "http://localhost:3000/masking-2" H.! A.class_ "button"
          -- Easy access to the rendered images
          get "/getPNG/:image" $ do 
               image <- param "image"
               file ("img/" ++ image ++ ".PNG")
          -- Different pages for the Image Server
          get "/coloured-shapes" $ do
               html $ R.renderHtml $ multipleImagesPerPage "Coloured shapes" "Scroll down to view all the different shapes this image server offers!" "http://localhost:3000/getPNG/red-circle" "renderColoured \"img/red-circle.png\" defaultWindow redCircle" "redCircle = [(identity, circle, red)]" "http://localhost:3000/getPNG/green-rectangle" "renderColoured \"img/green-rectangle.png\" defaultWindow greenRectangle" "greenRectangle = [(identity, rectangle, green)]" "http://localhost:3000/getPNG/blue-ellipse" "renderColoured \"img/blue-ellipse.png\" defaultWindow blueEllipse" "blueEllipse = [(identity, ellipse, blue)]" "http://localhost:3000/getPNG/orange-polygon" "renderColoured \"img/orange-polygon.png\" defaultWindow orangePolygon" "orangePolygon = [(identity, polygon [point (-2) 3.5, point 2 3.5, point 4 0, point 2 (-3.5), point (-2) (-3.5), point (-4) 0, point (-2) 3.5], orange)]" "http://localhost:3000/getPNG/black-mandelbrot" "renderColoured \"img/black-mandelbrot.png\" defaultWindow blackMandelbrot" "blackMandelbrot = [(identity, mandelbrot, black)]"
          get "/transformations" $ do
               html $ R.renderHtml $ oneImagePerPage "Transformations" "This page contains all transformations using all the types of shapes this image server offers." "http://localhost:3000/getPNG/transformations" "renderColoured \"img/transformations.png\" defaultWindow transformations" "transformations = [(shear 45 0, rectangle, green), (translate (point 4 (-4)), circle, red), (rotate 45 <+> translate (point 1 6), ellipse, blue), (scale (point 2 2) <+> translate (point (-2) (-2)), polygon [point (-0.5) 0.875, point 0.5 0.875, point 1 0, point 0.5 (-0.875), point (-0.5) (-0.875), point (-1) 0, point (-0.5) 0.875], orange), (rotate 180 <+> scale (point 1 1) <+> translate (point (-4) 1), mandelbrot, black)]"       
          get "/overlapping" $ do
               html $ R.renderHtml $ oneImagePerPage "Overlapping shapes" "This page contains shapes that overlap over each other. The shape that is declared last is overlapped over the ones before it." "http://localhost:3000/getPNG/overlapping" "renderColoured \"img/overlapping.png\" defaultWindow overlapping" "overlapping = [(scale (point 2 2), rectangle, green), (scale (point 2 2) <+> translate (point (2) (1)), ellipse, blue), (scale (point 2 2) <+> translate (point (3) (2)), circle, red), (scale (point 2 2) <+> translate (point (-1) (-1)), mandelbrot, black)]"
          get "/masking" $ do
               html $ R.renderHtml $ multipleImagesPerPage "Masking" "This page shows how masking works. The 1st image is a black circle. The 2nd image is a yellow rectangle. One could \"fake\" the masking by simply overlapping both shapes over each other, as seen in the 3rd image. However, the 4th and 5th image show real masking where you can mask images so that when one is overlaid with another, you can specify which parts are seen (i.e. here we can specify with the parameter after the mask [from 0-255], how much of the yellow rectangle we want to see.)" "http://localhost:3000/getPNG/black-circle" "renderColoured \"img/black-circle.png\" defaultWindow blackCircle" "blackCircle = [(scale (point 2 2), circle, black)]" "http://localhost:3000/getPNG/yellow-rectangle" "renderColoured \"img/yellow-rectangle.png\" defaultWindow yellowRectangle" "yellowRectangle = [(scale (point 0.5 0.5), rectangle, yellow)]" "http://localhost:3000/getPNG/fake-masking" "renderColoured \"img/fake-masking.png\" defaultWindow fakeMasking" "fakeMasking =  [(scale (point 2 2), circle, black), (scale (point 0.5 0.5), rectangle, yellow)]" "http://localhost:3000/getPNG/real-masking-1" "renderColoured \"img/real-masking-1.png\" defaultWindow realMasking1" "realMasking1 = maskImages 0 blackCircle yellowRectangle" "http://localhost:3000/getPNG/real-masking-2" "renderColoured \"img/real-masking-2.png\" defaultWindow realMasking2" "realMasking2 = maskImages 255 blackCircle yellowRectangle"
          get "/masking-2" $ do
               html $ R.renderHtml $ multipleImagesPerPage "Masking #2" "Scroll down to view the image for transformations masked over the image for overlapping. As you scroll down, the opacity of the transformations image descreases meaning you can specify how much of the image you want to see." "http://localhost:3000/getPNG/masking-1" "renderColoured \"img/masking-1.png\" defaultWindow maskedImage1" "maskedImage1 = maskImages 255 overlapping transformations" "http://localhost:3000/getPNG/masking-2" "renderColoured \"img/masking-2.png\" defaultWindow maskedImage2" "maskedImage2 = maskImages 100 overlapping transformations" "http://localhost:3000/getPNG/masking-3" "renderColoured \"img/masking-3.png\" defaultWindow maskedImage3" "maskedImage3 = maskImages 50 overlapping transformations" "http://localhost:3000/getPNG/masking-4" "renderColoured \"img/masking-4.png\" defaultWindow maskedImage4" "maskedImage4 = maskImages 25 overlapping transformations" "http://localhost:3000/getPNG/masking-5" "renderColoured\"img/masking-5.png\" defaultWindow maskedImage5" "maskedImage5 = maskImages 0 overlapping transformations"

-- HTML for a button for returning to the home page of the Image Server
returnToHomePageButton :: H.Html
returnToHomePageButton = do
                    H.style (css)
                    H.a "Go back to the home page" H.! A.href "http://localhost:3000/"  H.! A.class_ "button"

-- HTML format for a webpage containing one image with code below it.
oneImagePerPage :: Text -> Text -> Text -> Text -> Text -> H.Html
oneImagePerPage title description
               image code codeExtra
               = do H.style (css)
                    H.div H.! A.class_ "webpage" $ do
                                        H.h1 ( H.toHtml title )
                                        H.h3 ( H.toHtml description )
                                        returnToHomePageButton
                                        H.hr
                                        H.img H.! A.src (H.toValue image)
                                        H.h4 ( H.toHtml code )
                                        H.h4 ( H.toHtml codeExtra )
                                        H.hr

-- HTML format for a webpage containing multiple images (5 images) with code below each image.
multipleImagesPerPage ::  Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> H.Html
multipleImagesPerPage title description
               image1 image1CodeForRender image1CodeForShape 
               image2 image2CodeForRender image2CodeForShape 
               image3 image3CodeForRender image3CodeForShape 
               image4 image4CodeForRender image4CodeForShape 
               image5 image5CodeForRender image5CodeForShape 
               = do H.style (css)
                    H.div H.! A.class_ "webpage" $ do
                                        H.h1 (H.toHtml title)
                                        H.h3 (H.toHtml description)
                                        returnToHomePageButton
                                        H.hr
                                        H.img H.! A.src (H.toValue image1)
                                        H.h4 (H.toHtml image1CodeForRender)
                                        H.h4 (H.toHtml image1CodeForShape)
                                        H.hr
                                        H.img H.! A.src (H.toValue image2)
                                        H.h4 (H.toHtml image2CodeForRender)
                                        H.h4 (H.toHtml image2CodeForShape)
                                        H.hr
                                        H.img H.! A.src (H.toValue image3)
                                        H.h4 (H.toHtml image3CodeForRender)
                                        H.h4 (H.toHtml image3CodeForShape)
                                        H.hr
                                        H.img H.! A.src (H.toValue image4)
                                        H.h4 (H.toHtml image4CodeForRender)
                                        H.h4 (H.toHtml image4CodeForShape)
                                        H.hr
                                        H.img H.! A.src (H.toValue image5)
                                        H.h4 (H.toHtml image5CodeForRender)
                                        H.h4 (H.toHtml image5CodeForShape)
                                        H.hr