module Main exposing (main)

import Html
import Html.App


type alias Model =
    {}


type Msg
    = NoOp


main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.text <| toString model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
