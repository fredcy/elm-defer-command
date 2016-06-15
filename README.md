# elm-defer-command

The Defer module provides a component following The Elm Architecture that defers
one or more commands to run after the next browser animation frame.

This is useful such as when setting focus on a newly created element. By
deferring a command this way we can be sure that the element is mounted in the
browser's DOM and can be found and manipulated by javascript code triggered by
commands sent over a port.

See the example directory for a program that uses the Defer module in this way.
It's nearly a minimal example; searching for "Defer" in it shows how a `Defer`
component is to be wired into another program.

(The necessary component wiring code is about as big as the Defer module
itself. If that's an issue the Defer code could be used as a basis for doing
similar logic inline in the program.)
