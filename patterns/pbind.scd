(
s.boot;
s.scope(2);
FreqScope.new;
)


(
// a SynthDef
SynthDef.new(\test, { | out, freq = 440, amp = 0.1, nharms = 10, pan = 0, gate = 1 |
    var audio = Blip.ar(freq, nharms, amp);
    var env = Linen.kr(gate, doneAction: 2);
    OffsetOut.ar(out, Pan2.ar(audio, pan, env) );
}).add;
)

(
SynthDef.new(\harmonicSines,
	{
		| out, freq, amp, dur, slope = -1.0 |
		var sin_wavs, num_wavs=3;
		var env = Linen.kr(1, doneAction: 2);
		sin_wavs = Mix.fill(num_wavs,
			{
				arg i;
				var out_lo, out_hi, out_mid, out_diff, mul, wav_freq;
                var sin_env = Env.sine(dur * 0.99);
				slope = slope.clip(-1.0,1.0);
				out_mid = 0.5;
				out_lo = out_mid - slope;
				out_hi = out_mid + slope;

				mul = i.linlin(0.0, num_wavs, out_lo, out_hi);
				mul = mul.linlin(0,1,0,amp/(num_wavs+2));
				wav_freq = freq + (i*freq);
				SinOsc.ar(wav_freq) * EnvGen.kr(sin_env, doneAction: 2, gate: 1, levelScale: mul);
			}
		);
		sin_wavs = FreeVerb.ar(sin_wavs, 0.9, 0.6, 0.3);
		Out.ar(out, Pan2.ar(sin_wavs, 0.0, env));
	}).add;


)

// Example
(
Pbind(\instrument, \test, \freq, Prand([1, 1.2, 2, 2.5, 3, 4], inf) * 200, \dur, 0.21).play
)

(
a = Scale.major;
// Pbind(\scale, a, \root, (-12 * 3) + 7, \degree, Pseq((0..7) ++ (6..0) ++ [\rest], 1),
//     \dur, 1.0, \instrument, \harmonicSines, \amp, 0.7,
// \slope, 1.0).play;

Pbind(\scale, a, \root, (-12 * 3) + 7, \degree, Prand([0,3,5,6], inf),
    \dur, Prand([0.3, 0.02, 0.2], inf),
    \instrument, \harmonicSines,
    \amp, 0.99,
    \slope, 1.0).play;

)

(
Pbind(\freq, Prand([300, 500, 231.2, 399.2], inf), \dur, Prand([0.1, 0.3], inf)).play;
)

Env.sine(0.2).plot;
Server.local.boot;
{ SinOsc.ar(500, 0, 0.5) }.scope;
{ SinOsc.ar(500, 0, 0.5).cubed }.scope;

{ SinOsc.ar(440, 0, 0.571) * SinOsc.kr(880) }.scope

// use an lfo to modulate the amplitude of the modulator
(
    {
        SinOsc.ar(440, 0, 0.571)
        *
        (SinOsc.kr(880)                // wrap the modulator and the lfo in parenthese
        *                     // why ... ?
        SinOsc.kr([6.99, 8.01].reciprocal)
        )
    }.scope
)

// use an lfo to modulate the amplitude of the modulator
(
    {
        SinOsc.ar(440, 0, 0.571)
        *
        (SinOsc.kr(880).abs            // wrap the modulator and the lfo in parenthese
        *                     // why ... ?
        SinOsc.kr([6.99, 8.01].reciprocal)
        )
    }.scope
)

(
// read a soundfile
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// define a sample player that will loop over a soundfile
SynthDef("aLoopingSamplePlayer", { arg outBus = 0, bufnum = 0, rateScale = 1, mul = 1;
    Out.ar(
        outBus,
        PlayBuf.ar(
            1,
            bufnum,
            BufRateScale.kr(bufnum) * rateScale + LFNoise1.kr(2.reciprocal, 0.05),
            loop: 1    // play the soundfile over and over without stopping
        )
        *
        mul
    )
}).add;

// apply amplitude modulation to an audio source
SynthDef("ampMod", { arg inBus = 0, outBus = 0, modFreq = 1;
    Out.ar(
        outBus,
        [    // In.ar ugen reads from an audio bus
            In.ar(inBus, 1) * SinOsc.kr(modFreq),
            In.ar(inBus, 1) * SinOsc.kr(modFreq - 0.02)
        ]
    )
}).add;

// apply a low pass filter to an audio source
SynthDef("aLowPassFilter", { arg inBus = 0, outBus = 0, freq = 300, freqDev = 50, boost = 1;
    Out.ar(
        outBus,
        RLPF.ar(
            In.ar(inBus, 2),
            Lag.kr(LFNoise0.kr(1, freqDev, freq), 1),
            0.2
        )
        *
        boost
        *
        LFPulse.kr(1, [0.25, 0.75], [0.5, 0.45])
        +
        In.ar(inBus, 2)
    )
}).add;
)

// define 2 groups, 1 for source material and the other for effects
(
~source = Group.head(s);
~effect = Group.tail(~s);
)

(
// add the samplePlayer to the source group
~theSource = Synth.head(
    ~source,
    "aLoopingSamplePlayer", [\outBus, 3, \bufNum, b, \rateScale, 1, \mul, 0.051]);
// add an amplitude modulation synth to the head of the effects group
~fx1 = Synth.head(
    ~effect,
    "ampMod", [\inBus, 3, \outBus, 5, \modFreq, 1]);
// add filtering to the tail of the effects group
~fx2 = Synth.tail(
    ~effect,
    "aLowPassFilter", [\inBus, 5, \outBus, 0, \boost, 5])
)

// Over the rainbow
(
SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
    Out.ar(0, sig ! 2)
}).add;
)

(
p = Pbind(
        // the name of the SynthDef to use for each note
    \instrument, \smooth,
        // MIDI note numbers -- converted automatically to Hz
    \midinote, Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1),
        // rhythmic values
    \dur, Pseq([2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3], 1)
).play;
)
(4 ! 16) ++ \rest
(
TempoClock.default.tempo = 84/60;

p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Pseq(#[rest, 4, 3, 4, 2, 4, 1, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2, 4,
        -3, 4, -1.9, 4, -0.9, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2], 1),
    \dur, 0.25
).play;
)
FreqScope.new;
(
p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Ppatlace([Pseq(#[rest, 3, 2, 1, 0, -0.9, 0, 1, 2, -3, -1.9, -0.9, 0, -0.9, 0, 1, 2], 1),
        Pn(4, 16)], inf),
    \dur, 0.5
).play;
)
(
var    melodies = (
        lowMelody: Pseries(4, Prand(#[-2, -1, 1, 2], inf), inf).fold(-7, 11),
        highMelody: Pseries(14, Prand(#[-3, -2, 2, 3], inf), inf).fold(7, 18)
    );

p = Pbind(
    \degree, Pnsym1(Pwrand(#[lowMelody, highMelody], [0.7, 0.3], inf), melodies),
    \dur, Pwrand(#[0.25, 0.5], #[0.4, 0.6], inf)
).play;
)
