// More synths
(
SynthDef.new(\harmonicSines,
	{
		arg out,
		    freq,
		    slope = -1.0,
            pan=0,
            amp=1.0;
		var sin_wavs, num_wavs=6, env;
		sin_wavs = Mix.fill(num_wavs,
			{
				arg i;
				var out_lo, out_hi, out_mid, out_diff, mul, wav_freq;
				//slope = slope.clip(-1.0,1.0);
				out_mid = 0.5;
				out_lo = out_mid - slope / 2;
				out_hi = out_mid + slope / 2;

				mul = amp * i.linlin(0.0, num_wavs, out_lo, out_hi);
				//mul = mul.linexp(0,1,0.01,amp/(num_wavs));
				wav_freq = freq + (i*freq);
				SinOsc.ar(wav_freq) * mul;
			}
		);
		sin_wavs = FreeVerb.ar(sin_wavs, 0.9, 0.6, 0.3);
        env = Env.perc;
        sin_wavs = sin_wavs * env.kr();
        sin_wavs = Pan2.ar(sin_wavs, pan);
        // limit level
        sin_wavs = Limiter.ar(sin_wavs, 1.0);
		OffsetOut.ar(out, sin_wavs);
	}).add;

SynthDef.new(\sineAttack,
	{
		arg attack_speed = 0.1;
		var num_waves=8, wave_mix;
		wave_mix = Mix.fill(num_waves,
			{
				arg i;
				var delay_env;
				delay_env = Env.dadsr(i * attack_speed, 0.01, attack_speed, 1/num_waves, 0, 1/num_waves, -1);
				SinOsc.ar(Rand(220,880)) * delay_env.kr()});
		Out.ar([0,1], wave_mix);
}).add;





)
Scale.major.degreeToFreq(Scale.major.degrees, 60.midicps, 0)
s.scope;
FreqScope.new(200,200);
x = Synth.new(\harmonicSines, [\freq, 200]);
asArray
x.set(\slope, 0.15);
x.set(\freq, 240);
x.set(\amp,0.95);
x.free;

x = Synth.new(\sineAttack, [\attack_speed, 0.1]);
y = Synth.new(\sineAttack, [\attack_speed, 0.08]);
z = Synth.new(\sineAttack, [\attack_speed, 0.05]);

x.free; y.free; z.free;

x = Synth.new(\sineAttackChoice);
x.free; y = Synth.new(\sineAttackChoice, [root_midi: 63]);
y.free; z = Synth.new(\sineAttackChoice, [root_midi: 65]);

(
Pbind(\instrument, \sineAttackChoice,
    \root_midi, Pseq([60, 63, 65, 67, 60]),
    \dur, 1.5,
    \attack_speed, 0.15).play;
)


(
SynthDef(\help_sinegrain,
    { arg out=0, freq=440, sustain=0.05;
        var env;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction:2);
        Out.ar(out, SinOsc.ar(freq, 0, env))
    }).add;
)

(
a = Prand(#[60, 61, 63, 65, 72], inf).asStream;
Routine({
    loop({
        Synth(\help_sinegrain, [\freq, a.next.midicps]);
        0.2.wait;
    })
}).play;
)


(
SynthDef(\pulseWave,
    {
        arg dur, freq=35;
        var pulse, width_osc, env;
        env = EnvGate.new;
        width_osc = SinOsc.kr(freq/5).range(0.65,0.8);
        pulse = LFPulse.ar(freq, width: width_osc) * env;
        Out.ar(0, Pan2.ar(pulse, 0));
}).add;

x = Synth(\pulseWave, [\freq, 415]);
)