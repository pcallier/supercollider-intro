// SuperCollider basics
// evaluate each line on its own

// Basics
Server.local.boot;          // start the "local" server
Server.local.quit;          // quite the local server
// shortcuts available
s == Server.local;          // s is preset to point to Server.local

// Use the following invocation in every
// new SuperCollider session
(
s.boot
)

// Make a note play
x = {SinOsc.ar}.play;
// Make it stop
s.freeAll;        // or, Ctrl/Cmd-. (SuperCollider IDE)
