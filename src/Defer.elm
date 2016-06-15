module Defer exposing (Model, Msg(AddCmd), init, update, subscriptions)

{-| Defer one or more commands to run after the browser render-loop has run at
least once.

This is useful such as when setting focus on a newly-created element as we can
be sure that the element is in the actual DOM and and be manipulated via port
commands.

# Wiring
@docs Model, Msg, init, update, subscriptions
-}

import AnimationFrame
import Time


{-| Holds commands to be deferred, if any.
-}
type alias Model =
    List (Cmd Msg)


{-| The `AddCmd` message is used by the parent module to add a command to be
deferred.
-}
type Msg
    = AddCmd (Cmd Msg)
    | Tick Time.Time


{-| Initialize this component with a list of commands.
-}
init : List (Cmd Msg) -> Model
init cmdList =
    cmdList


{-| Update the component model.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddCmd cmd ->
            (cmd :: model) ! []

        Tick time ->
            [] ! model


{-| Subscriptions used to manage deferred commands. Add this to the parent
program's subscriptions.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        [] ->
            Sub.none

        _ ->
            AnimationFrame.times Tick
