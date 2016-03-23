import Keyboard
import Char
import Task
import StartApp
import Html exposing (Html)
import Effects exposing (Never)

import Hangman exposing (init, view, update, Model)


app: StartApp.App Model
app =
    StartApp.start
      { init = init
      , view = view
      , update = update
      , inputs = [ guessChar ]
      }

guessChar: Signal Hangman.Action
guessChar =
  Signal.map codeToAction Keyboard.presses

codeToAction: Char.KeyCode -> Hangman.Action
codeToAction c =
  c
  |> Char.fromCode
  |> Hangman.Guess

main: Signal Html
main =
    app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks