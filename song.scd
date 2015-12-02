// Basic synth

(
SynthDef(\triWave,
    {
        | out, freq, amp, pan=0 |
        var env=EnvGen.kr(Env.perc,doneAction:2);
        var sig=LFTri.ar(freq, mul: amp);
        sig=FreeVerb.ar(sig, 0.7, 0.6, 0.01);
        sig=sig*env;
        Out.ar(out, Pan2.ar(sig, pos: pan));
    }
).add;
)

s.boot;
s.scope;

// Arpeggios
(
TempoClock.default.tempo = 60/60;
t=TempoClock.default;
a=Scale.major;
p = Pbind(\scale, a,
    \amp, 1.0,
    \dur, Pseq([0.5], inf),
    \degree, Pseq([0, 2, 4, 6], inf),
    \root, 4,
    \ctranspose, Pstutter(4, Pseq([0,2,5], inf)),
    \instrument, \triWave);
)

// happy: var notes=Pseq([80, 78, 77, 80, 77, 73], 1);


(
var stream = p.play(quant: 1);
stream.xstop(10);
)

// Line
(
var notes=Pseq([80, 78, 77, 78, 77, 75, Rest, 72, 73, 75, Rest, 77, 75, 73], inf);
var durs=Pseq([1,1,0.25,0.25,0.25,0.5,0.75,1/2,1/2,1/2, 1/4, 2/3, 2/3, 1/3], inf);
var legato=Pseq([0.8].stutter(7) ++ [0.25].stutter(3) ++ [0.8].stutter(4));
var line=Pbind(
    \midinote, notes,
    //\freq, freqs,
    \instrument, \triWave,
    \dur, durs,
    \amp, 0.7,
    \legato, legato);

line.play(quant: 1);
)

(
p = (Pn(1,5) ++ 0.7).asStream;
10.do({p.next.postln;});
)