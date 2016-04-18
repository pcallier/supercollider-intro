// Basics
Server.local.boot;
Server.local.quit;
// shortcuts available
s == Server.local;
s.boot;

// Make it play
x = {SinOsc.ar}.play;
// Make it stop
s.freeAll;        // or, Ctrl/Cmd-.