module Hangman (init, view, update, Model, Action(RequestMore, Guess)) where

import Char
import String
import Set exposing (Set)
import Json.Decode as Json
import Task
import Effects exposing (Effects)
import Http
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events


-- MODEL


type alias Model =
  { word : String
  , used : Set Char
  }


init : ( Model, Effects Action )
init =
  ( { word = "hangman"
    , used = Set.empty
    }
  , getRandomWord
  )


attemptsCount : Int
attemptsCount =
  6



-- UPDATE


type Action
  = Guess Char
  | RequestMore
  | NewWord (Maybe String)


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Guess c ->
      ( case (status model) of
          Guessing _ ->
            { model | used = Set.insert (Char.toLower c) model.used }

          _ ->
            model
      , Effects.none
      )

    NewWord new ->
      ( { word = Maybe.withDefault model.word new
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


type Status
  = Guessing Int
  | Winner
  | Loser


status : Model -> Status
status model =
  if (winner model) then
    Winner
  else
    let
      wrong =
        wrongAttempts model
    in
      if (wrong < attemptsCount) then
        Guessing (attemptsCount - wrong)
      else
        Loser


winner : Model -> Bool
winner { word, used } =
  String.all (\c -> Set.member c used) word


wrongAttempts : Model -> Int
wrongAttempts { word, used } =
  word
    |> String.toList
    |> Set.fromList
    |> Set.diff used
    |> Set.size



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ Attributes.class "splash" ]
    [ h1
        [ Attributes.class "splash-head" ]
        [ inputField address
        , text (String.toUpper (showSelected model.word model.used))
        ]
    , p
        [ Attributes.class "splash-subhead" ]
        [ message model ]
    , p
        []
        [ button
            [ Events.onClick address RequestMore
            , Attributes.href "#"
            , Attributes.class "pure-button pure-button-primary"
            ]
            [ text "New word" ]
        ]
    ]


message : Model -> Html
message model =
  case (status model) of
    Guessing remaining ->
      text ("Attempts remaining " ++ (toString remaining))

    Winner ->
      text "Winner!"

    Loser ->
      span
        []
        [ strong
            []
            [ text "Loser! " ]
        , text "Word was: "
        , em
            []
            [ text model.word ]
        ]


inputField : Signal.Address Action -> Html
inputField address =
  input
    [ onKeyUp address Guess
    , Attributes.value ""
    , Attributes.class "splash-input"
    ]
    []


onKeyUp : Signal.Address Action -> (Char -> Action) -> Attribute
onKeyUp address handler =
  Events.on
    "keyup"
    Events.keyCode
    (\code ->
      code
        |> Char.fromCode
        |> handler
        |> Signal.message address
    )


showSelected : String -> Set Char -> String
showSelected word selected =
  String.map
    (\c ->
      if (Set.member c selected) then
        c
      else
        '_'
    )
    word


wotdUrl : String
wotdUrl =
  Http.url
    "http://api.wordnik.com:80/v4/words.json/randomWord"
    [ ( "hasDictionaryDef", "true" )
    , ( "includePartOfSpeech", "noun" )
    , ( "minCorpusCount", "100000" )
    , ( "maxCorpusCount", "-1" )
    , ( "minDictionaryCount", "1" )
    , ( "maxDictionaryCount", "-1" )
    , ( "minLength", "5" )
    , ( "maxLength", "-1" )
    , ( "api_key", "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5" )
    ]
