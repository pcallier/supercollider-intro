s.boot;
FreqScope.new(300, 300);

(
SynthDef.new(\hammondOrgan,
    {
        arg out,
            pan=0,
            amp=1.0;
        var sin_wavs, num_wavs=12, env, freq, slope;
        freq = MouseX.kr(0, 1).exprange(80,500);
        slope = MouseY.kr(-1, 1);
        amp = sin(MouseX.kr(0,20*3.14)).range(0,1);
        //freq = 440;
        //slope = 0.8;
        sin_wavs = Mix.fill(num_wavs,
            {
                arg i;
                var out_lo, out_hi, out_mid, out_diff, mul, wav_freq;
                out_mid = 0.5;
                out_lo = out_mid - slope / 2;
                out_hi = out_mid + slope / 2;

                mul = amp * i.linlin(0.0, num_wavs, out_lo, out_hi);
                //mul = mul.linexp(0,1,0.01,amp/(num_wavs));
                wav_freq = freq + (i*freq);
                Pan2.ar(SinOsc.ar(wav_freq) * mul, pan + Rand(-0.6, 0.6));
            }
        );
        sin_wavs = FreeVerb.ar(sin_wavs, 0.9, 0.6, 0.3);
        // limit level
        sin_wavs = Limiter.ar(sin_wavs, 1.0);
        Out.ar(out, sin_wavs);
    }).add;
)

(
x = Synth.new(\hammondOrgan, [\out, 0, \amp, 0.2]);
s.scope(2);
)
