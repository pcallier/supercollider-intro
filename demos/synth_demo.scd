// Fun with synths
s.boot;
s.scope;
FreqScope.new(300, 300);

// Basic sine wave oscillator
(
var dur, deg, scale;

SynthDef(\sineWave,
    {
        arg freq=150, amp=1.0;
        var sig = SinOsc.ar(freq, phase: Rand(0,1)) * amp;
        // make it stereo
        sig=Pan2.ar(sig);
        Out.ar(0, sig);
}).add;
)

// Basic sine wave oscillator + Envelope
(
SynthDef(\sineWave,
    {
        arg freq=150, amp=1.0, sustain_time=1.0;
        var sig = SinOsc.ar(freq, phase: Rand(0,1));
        var env = EnvGen.kr(Env.sine(dur: sustain_time, level: amp), doneAction: 2);
        sig = sig * env;
        sig=Pan2.ar(sig);
        Out.ar(0, sig);
}).add;
)


// Demo
(
// Play
x = Synth.new(\sineWave);
x.free;
)

// Plot envelope
(
var sin_envelope = Env.sine;
sin_envelope.plot;
)


(
var dur, deg, scale;

// Play a scale
TempoClock.default.tempo = 1.0;
scale = Scale.major;
deg = Pseq(scale.degrees);
dur = 0.25;
x = Pbind(*[
    instrument: \sineWave,
    degree: deg,
    scale: scale,
    root: 0,
    dur: dur,
    sustain_time: dur/TempoClock.default.tempo * 0.9,
    amp: 0.2]
).play;
)
