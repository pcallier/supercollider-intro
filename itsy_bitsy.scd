// Itsy bitsy song
(
Pbind(\midinote,
    Pseq([60, 65, 65, 65, 67, 69, 69, 69, 67, 65, 67, 69, 65]),
    \dur,
    Pseq([1/8, 1/4, 1/8, 1/4, 1/8, 3/8, 1/4, 1/8, 1/4, 1/8, 1/4, 1/8, 3/8])).play;
)

// V. 2
(
TempoClock.default.tempo=0.5;
Pbind(\midinote,
    Pseq([60, 65, 65, 65, 67, 69, 69, 69, 67, 65, 67, 69, 65]),
    \dur,
    Pseq([1/8, 1/4, 1/8, 1/4, 1/8, 3/8, 1/4, 1/8, 1/4, 1/8, 1/4, 1/8, 3/8]),
    \ctranspose, 0,
    \instrument, \pulseWave,
    \amp, 1.0).play;
)