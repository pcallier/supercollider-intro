// Arpeggios
(
TempoClock.default.tempo = 120/60;
t=TempoClock.default;
)

(
a=Scale.major;
p = Pbind(\scale, a,
    \amp, 1.0,
    \dur, Pseq([0.5], inf),
//  Randomization possibilities:
//    \dur, Pxrand([0.5, 0.2, 0.3], inf),
    \degree, Pseq([0, 2, 4, 6], inf),
    \root, 4,
    \ctranspose, Pstutter(4, Pseq([0,2,5], inf)),
    \instrument, \triWave);
)

// happy: var notes=Pseq([80, 78, 77, 80, 77, 73], 1);


// Play pattern
(
var stream = p.play(quant: 1);
stream.xstop(10);
)