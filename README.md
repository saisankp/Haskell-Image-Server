# Haskell-Image-Server

In this stack project using Haskell I created a drawing eDSL, combined with two web eDSL languages Scotty and Blaze to produce a web application capable of delivering images. I used the JuicyPixels library to create the images.This project provides a drawing eDSL with the following shapes: Circle, Rectangle, Ellipse, Polygon and a mandelbrot. I also provide the following transformations: Scale, Rotate, Translate, and functions to combine them with shapes to produce drawings. You can provide a way to specify colour for each shape and mask images so that when one is overlaid with another so you can specify which one is seen. This can be seen using the Scotty application which can render the images to show the result. The images are returned as PNG graphics rendered using JuicyPixels. For clarity, the web application shows the text of the DSL program that produced the image in the web page, so that the user of the web app can see how the image was produced. Furthermore, there are optimisations to the DSL program before shapes are rendered.


## Demo


https://user-images.githubusercontent.com/34750736/214978113-a41df981-5214-4625-9348-7139ee50fb77.mp4



## How to run the project
To run the project, run this command in the root project directory (this will take 2-3 minutes to complete):

`bash render.sh`

If you want to see a visualization of the project, have a look at [my demo video on Youtube.](https://youtu.be/Vwto9clVuf8)
