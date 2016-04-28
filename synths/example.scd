(
s.boot;
s.scope(2);
)

// Get SynthDefs from other files
(
"/home/patrick/Documents/supercollider-intro/synths/beeps.scd".load
)

(
Synth.new(\bloop).play;
)
