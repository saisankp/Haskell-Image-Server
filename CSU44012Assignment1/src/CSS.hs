module CSS
    ( css
    ) where

import qualified Text.Blaze.Html5 as H

css :: H.Html
css = H.toHtml " @import url('https://fonts.googleapis.com/css?family=Press+Start+2P'); \n\
                \ @import url('https://fonts.googleapis.com/css?family=Lato'); \n\
                \ html { \n\
                \ background-image: linear-gradient(to right, #fc5c7d, #6a82fb); \n\
                \ background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab); \n\
                \ background-size: 400% 400%; \n\
                \   animation: gradient 15s ease infinite; \n\
                \ } \n\
                \ .webpage { \n\
                \   max-width: 1000px; \n\
                \   margin: auto; \n\
                \   text-align: center; \n\
                \ } \n\
                \ a.button{ \n\
                \   font-family:'Roboto',sans-serif; \n\
                \   font-weight:300; \n\
                \   color:#FFFFFF; \n\
                \   text-align:center; \n\
                \   text-decoration:none; \n\
                \   padding:0.35em 1.2em; \n\
                \   border:0.1em solid #FFFFFF; \n\
                \   transition: all 0.2s; \n\
                \   display:inline-block; \n\
                \   box-sizing: border-box; \n\
                \   margin:0 0.3em 0.3em 0; \n\
                \   border-radius:0.12em; \n\
                \ } \n\
                \ a.button:hover{ \n\
                \   color:#000000; \n\
                \   background-color:#FFFFFF; \n\
                \ } \n\
                \ h1, h2 { \n\
                \   font-family: 'Press Start 2P', serif; \n\
                \   text-shadow: -2px 0 white, 0 2px white, 2px 0 white, 0 -2px white; \n\
                \ } \n\
                \ h3 { \n\
                \   font-family: 'Lato', serif; \n\
                \   text-shadow: -1px 0 white, 0 1px white, 1px 0 white, 0 -1px white; \n\
                \ } \n\
                \ @keyframes gradient { \n\
                \ 0% { \n\
                \   background-position: 0% 50%; \n\
                \ } \n\
                \ 25% { \n\
                \   background-position: 50% 50%; \n\
                \ } \n\
                \ 50% { \n\
                \   background-position: 100% 50%; \n\
                \ } \n\
                \ 75% { \n\
                \   background-position: 50% 50%; \n\
                \ } \n\
                \ 100% { \n\
                \   background-position: 0% 50%; \n\
                \ } \n\
                \}"