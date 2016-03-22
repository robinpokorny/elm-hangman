module Hangman where

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Effects exposing (Effects)
import Set exposing (Set)
import Char
import String
import Json.Decode as Json
import Task

-- MODEL

type alias Model =
  { word: String
  , used: Set Char 
  }

init =
  ( { word = "hangman"
    , used = Set.empty
    }
  , getRandomWord
  )

-- UPDATE

type Action = Guess Char | RequestMore | NewWord (Maybe String)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Guess c ->
      (
        if (status model == Guessing)
        then
          { model | used = Set.insert (Char.toLower c) model.used}
        else
          model
      , Effects.none
      )

    NewWord new ->
      ( { word = Maybe.withDefault model.word (Debug.log "new" new)
        , used = Set.empty
        }
      , Effects.none
      )

    RequestMore ->
      ( model
      , getRandomWord
      )

getRandomWord : Effects Action
getRandomWord =
  Http.get decodeJson wotdUrl
    |> Task.toMaybe
    |> Task.map NewWord
    |> Effects.task

decodeJson : Json.Decoder String
decodeJson =
  Json.at [ "word" ] Json.string

type Status = Guessing | Winner | Loser

status: Model -> Status
status model =
  if (winner model)
  then Winner
  else if ((wrongAttempts model) < 10)
    then Guessing
    else Loser

winner: Model -> Bool
winner { word, used } =
  String.all (\c -> Set.member c used) word

wrongAttempts: Model -> Int
wrongAttempts { word, used } =
  word
  |> String.toList
  |> Set.fromList
  |> Set.diff used
  |> Set.size

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "splash" ]
    [ h1 [ class "splash-head" ] [ text (String.toUpper (showSelected model.word model.used)) ]
    , p [ class "splash-subhead"] [ message model ]
    ,  p [] [ button [ onClick address RequestMore, href "#", class "pure-button pure-button-primary" ] [text "New word"] ]
    ]

message model =
  case (status model) of
    Guessing -> text ( "Attempts remaining " ++ (toString (10 - wrongAttempts model)))
    Winner -> text "Winner!"
    Loser -> span []
             [ strong [] [ text "Loser! " ]
             , text "Word was: "
             , em [] [ text model.word ]
             ]

showSelected word selected =
  String.map
    (\c ->
      if (Set.member c selected)
      then c
      else '_'
    )
    word

wotdUrl =
  "http://api.wordnik.com/v4/words.json/randomWord?hasDictionaryDef=true&includePartOfSpeech=noun&minCorpusCount=100000&maxCorpusCount=-1&minDictionaryCount=1&maxDictionaryCount=-1&minLength=5&maxLength=-1&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
