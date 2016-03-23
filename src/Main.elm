import StartApp
import Hangman exposing (init, view, update)
import Keyboard
import Char
import Task
import Effects exposing (Never)

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

main =
    app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks