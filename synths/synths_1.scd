// Fun with synths
(
    s.boot;
    s.scope(2);
    FreqScope.new(300, 300);
)
// Define synths

// Basic sine wave oscillator
(
var dur, deg, scale;

// SynthDef
//   This defines the instrument.
//   The synth is essentially a program written in the 
//   server's (limited) instruction set. The SynthDef is the declaration
//   of how the program behaves.

//   Two arguments: the identifier (\sineWave), and the code
//   describing the synth.

// Args are runtime parameters and can be changed every time a
// Synth is instantiated. amp and sustain_time are also given default
// values.

// Other named variables must also be declared ("var") before any 
// of the synth's instructions are specified.  Declarations may, as in 
// this example, include pretty complicated instructions to the server
// as well.

// This synth works by creating a basic oscillator that vibrates
// at a given frequency. Then it wraps an "envelope" around
// this oscillator to give control over amplitude and duration.
// The envelope knows how to kill the oscillator when it is done,
// which helps with garbage collection

SynthDef(\sineWave,
    {
        // Three arguments: frequency, amplitude, and sustain time
        arg freq, amp=1.0, sustain_time=1.0;
        // The envelope is the object that modulates the duration 
        // and amplitude of a signal for us.
        var env = EnvGen.kr(Env.sine(dur: sustain_time, level: amp), doneAction: 2);
        // The actual oscillator is declared with the 
        // SinOsc.ar call
        // Multiplying by env applies the envelope
        // And wrapping all that in Out.ar(..., Pan2.ar(), ...)
        // sends output to both audio out channels
        Out.ar(0, Pan2.ar(SinOsc.ar(freq, phase: Rand(0,1)) * env), 0);
}).add;


// Play a scale to demonstrate. More examples
// or Pbind in the patterns directory.
TempoClock.default.tempo = 1.0;
scale = Scale.hijaz;
deg = Pseq(scale.degrees);
dur = 0.25;
x = Pbind(*[
    instrument: \sineWave,
    degree: deg,
    scale: scale,
    root: 0,
    dur: dur,
    // some tomfoolery adjusting sustain based on tempo
    sustain_time: dur/TempoClock.default.tempo * 0.9,
    amp: 0.2]
).play;
)


// Triangle wave whose
// frequency is controlled by a
// saw wave chained to a sinewave
(
    SynthDef.new(\industrial,
	{
		arg freq, osc_lo=1, osc_hi=3.5,
	        osc_freq=0.25, amp=1.0;
		var lo, hi, osc, sig, env;
        // Range of fundamental frequency
        lo = freq * 0.8;
        hi = freq * 1.1;
		// Frequency oscillation controls
		osc = LFSaw.kr(osc_freq).range(osc_lo,osc_hi);
		freq = SinOsc.kr(osc).range(lo,hi);
		// Triangle wave that actually produces
		// sound signal
		sig = LFTri.ar(freq) * amp;
		sig = FreeVerb.ar(sig, 0.7, 0.8, 0.25);
        // Envelope
        env = EnvGen.kr(Env.sine(dur: 0.95), doneAction: 2);
		Out.ar([0,1], sig);
    }).add;
)

// Play a scale
(
    var scale, dur, deg;
    TempoClock.default.tempo = 1.0;
    scale = Scale.major;
    deg = Pseq(scale.degrees);
    dur = 1.0;
    x = Pbind(*[
        instrument: \industrial,
        degree: deg,
        scale: scale,
        root: -30,
        dur: dur,
        amp: 0.8]
    ).play;
)

// Define random beeps
(
    SynthDef.new(\bloop,
        {
            arg freq = 200,
                range = 20,
                noise_freq=5,
                amp=0.7;
            var noise, sig, amp_envelope;
            amp_envelope = LFPulse.kr(noise_freq,
                width: 0.75) * amp;
            noise = LFNoise0.kr(noise_freq).
                range(freq - range / 2,
                      freq + range / 2);
            sig = SinOsc.ar(noise, 0.5) *
                      amp_envelope;
            Out.ar([0,1], sig);
    }).add;
)

// Play random beeps, always good
(
    z = Synth.new(\bloop, [\freq, 520, \range, 60, \amp, 0.6]);
    z.set(\range, 200);
    z.set(\fund_freq, 320);
    z.set(\noise_freq, 5);
)

// End it
(
    s.freeAll;
)
