# Hangman in Elm ([DEMO](http://robinpokorny.github.io/elm-hangman/))

[![version](https://img.shields.io/badge/version-1.0.0-green.svg?style=flat-square)]()
[![Build Status](https://img.shields.io/badge/build-passed-brightgreen.svg?style=flat-square)](https://semaphoreci.com/robinpokorny/elm-hangman)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/robinpokorny/elm-hangman/blob/master/LICENSE)

A simple hangman game in Elm with HTTP word fetching.

## Build
```bash
elm make src/Main.elm --output public/elm.js --yes
```

Bundles application to `/public` folder.

Unstylled version can be run with `elm reactor` and navigating to `src/Main.elm`.