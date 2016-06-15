port module Main exposing (main)

import Defer
import Html exposing (Html)
import Html.App
import Html.Attributes as HA
import Html.Events as HE


{- This program is an example of using the Defer module, deferring commands to
   set focus on new input fields. The program provides a button for adding an
   additional HTML input field. When the model is updated to add such a new input
   field the update function also adds a command to the 'defer' component to set
   focus on that field.

   The program has a checkbox to enable/disable deferred focus commands. When
   enabled the new input fields should get focus. When disabled they usually do
   not get focus because the commmand sent over the focus port is received and
   acted on by the javascript side before the new element has been mounted on
   the DOM.
-}


type alias Model =
    -- add the Defer component to the model
    { numInputs : Int
    , defer : Defer.Model
    , enabled : Bool
    }


type Msg
    -- add the type for messages to the Defer component
    = AddInput
    | DeferMsg Defer.Msg
    | SetEnable Bool


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


port focus : String -> Cmd msg


init : ( Model, Cmd Msg )
init =
    let
        -- set initial focus on first input element
        focusCmd =
            focus (inputSelector 1)
    in
        -- initialize the Defer component along with the main model
        { numInputs = 1
        , defer = Defer.init [ focusCmd ]
        , enabled = True
        }
            ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        AddInput ->
            let
                numInputs' =
                    model.numInputs + 1

                focusCmd =
                    focus (inputSelector numInputs')
            in
                if model.enabled then
                    -- this is the normal usage of Defer
                    let
                        ( deferModel, deferCmd ) =
                            Defer.update (Defer.AddCmd focusCmd) model.defer
                    in
                        { model | numInputs = numInputs', defer = deferModel }
                            ! [ Cmd.map DeferMsg deferCmd ]
                else
                    -- this shows what happens if we don't defer the command
                    { model | numInputs = numInputs' } ! [ focusCmd ]

        DeferMsg deferMsg ->
            -- the usual forwarding of messages to a component
            let
                ( deferModel, deferCmd ) =
                    Defer.update deferMsg model.defer
            in
                { model | defer = deferModel } ! [ Cmd.map DeferMsg deferCmd ]

        SetEnable enabled ->
            { model | enabled = enabled } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    -- proxy the Defer component's subscriptions
    Defer.subscriptions model.defer |> Sub.map DeferMsg



-- view


view : Model -> Html.Html Msg
view model =
    Html.div [] (enableView model :: buttonView :: List.map inputView [1..model.numInputs])


enableView : Model -> Html.Html Msg
enableView model =
    Html.label []
        [ Html.text "enable deferred focus"
        , Html.input [ HA.type' "checkbox", HE.onCheck SetEnable, HA.checked model.enabled ] []
        ]


buttonView : Html.Html Msg
buttonView =
    Html.button [ HE.onClick AddInput ] [ Html.text "add input" ]


inputView : Int -> Html.Html Msg
inputView i =
    Html.input [ HA.type' "text", HA.id <| inputId i ] []



-- utilities


inputId : Int -> String
inputId i =
    "input" ++ toString i


inputSelector : Int -> String
inputSelector i =
    "#" ++ inputId i
