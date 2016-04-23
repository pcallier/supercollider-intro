(
s.boot;
s.scope(2);

)

// Instrument
(
SynthDef(\pulseWave,
    {
        arg dur, freq=35;
        var pulse, width_osc, env;
        env = EnvGate.new;
        width_osc = LFTri.kr(freq/5).range(0.65,0.8);
        pulse = Pulse.ar(freq, width: width_osc) * env;
        Out.ar(0, Pan2.ar(pulse, 0));
}).add;
)


// Arpeggios
(
TempoClock.default.tempo = 180/60;
t=TempoClock.default;
)

(
a=Scale.major;
p = Pbind(\scale, a,
    \amp, 1.0,
    \dur, Pseq([0.5, 0.5, 0.45, 0.45], inf),
//  Randomization possibilities:
//    \dur, Pxrand([0.5, 0.2, 0.3], inf),
    \degree, Pseq([0, 2, 4, 6], inf),
    \root, 4,
    \ctranspose, Pstutter(4, Pseq([0,2,5], inf)),
    \instrument, \pulseWave);
)

// happy: var notes=Pseq([80, 78, 77, 80, 77, 73], 1);


// Play pattern (using stream object)
(
var stream = p.play(quant: 1);
stream.xstop(10);
)

(
s.quit
)
