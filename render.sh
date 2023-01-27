# Make sure neccessary libraries are available on machine.
cabal install --lib JuicyPixels
cabal install --lib scotty   
cabal install --lib blaze-html
cabal install --lib terminal-progress-bar

# Clean and build the stack project.
stack clean --full
stack build

# Run the project
cd src
ghci main.hs -e 'main'