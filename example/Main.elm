port module Main exposing (main)

import Defer
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE


{- This program is an example of using the Defer module, deferring commands to
   set focus on new input fields. The program provides a button for adding an
   additional HTML input field. When the model is updated to add such a new input
   field the update function also adds a command to the 'defer' component to set
   focus on that field.

   The program has a checkbox to enable/disable deferred focus commands to show
   that deferring commands this way matters. When enabled the new input fields
   should get focus. When disabled they usually do not get focus because the
   commmand sent over the focus port is received and acted on by the javascript
   side before the new element has been mounted on the DOM.
-}


{-| Define the model, including the opaque model for the Defer component.
-}
type alias Model =
    { numInputs :
        Int
        -- the number of Html input fields to display
    , defer :
        Defer.Model
        -- the Defer helper component
    , enabled :
        Bool
        -- if True, defer focus commands; else run focus commands immediately
    }


{-| Set up the program's messages, including those forwarded to the Defer
component.
-}
type Msg
    = AddInput
    | DeferMsg Defer.Msg
    | SetEnable Bool


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


{-| We send HTML selector values over this port to request focus on the element
matched by the selector. See the index.html file for the corresponding
Javascript code.
-}
port focus : String -> Cmd msg


{-| Create initial model as usual, initializing the Defer component as well with
an initial command to focus on the one and only input element (to start).
-}
init : ( Model, Cmd Msg )
init =
    let
        focusCmd =
            focus (inputSelector 1)
    in
        { numInputs = 1
        , defer = Defer.init [ focusCmd ]
        , enabled = True
        }
            ! []


{-| Update the model as usual, passing along the opaque DeferMsg commands to the
Defer commpoent. When handling the AddInput command (triggered by user action)
we either defer a focus command (on the new Input element) or run the focus
command immediately (to show the benefit of deferring).
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        AddInput ->
            let
                numInputs_ =
                    model.numInputs + 1

                focusCmd =
                    focus (inputSelector numInputs_)
            in
                if model.enabled then
                    -- this is the normal usage of Defer
                    let
                        ( deferModel, deferCmd ) =
                            Defer.update (Defer.AddCmd focusCmd) model.defer
                    in
                        { model | numInputs = numInputs_, defer = deferModel }
                            ! [ Cmd.map DeferMsg deferCmd ]
                else
                    -- this shows what happens if we don't defer the command
                    { model | numInputs = numInputs_ } ! [ focusCmd ]

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


{-| Show the input elements and controls. Note that the Defer component has no
view of its own.
-}
view : Model -> Html.Html Msg
view model =
    Html.div [] (enableView model :: buttonView :: List.map inputView (List.range 1 model.numInputs))


{-| Show control that enables/disabled deferred commands.
-}
enableView : Model -> Html.Html Msg
enableView model =
    Html.label []
        [ Html.text "enable deferred focus"
        , Html.input [ HA.type_ "checkbox", HE.onCheck SetEnable, HA.checked model.enabled ] []
        ]


{-| Show control for adding new Input field.
-}
buttonView : Html.Html Msg
buttonView =
    Html.button [ HE.onClick AddInput ] [ Html.text "add input" ]


inputView : Int -> Html.Html Msg
inputView i =
    Html.input [ HA.type_ "text", HA.id <| inputId i ] []



-- utilities


{-| Html "id" value for i'th input element in model
-}
inputId : Int -> String
inputId i =
    "input" ++ toString i


inputSelector : Int -> String
inputSelector i =
    "#" ++ inputId i
