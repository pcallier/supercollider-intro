(
  SynthDef(\sineWave,
    {
      arg base_freq = 110, harmonic_range = 5, pos=0, level=0.5,
        freq_noise=5.0;
      var sig, freq, env;

      freq = base_freq * IRand(1, harmonic_range) +
        Rand(-1.0 * freq_noise, freq_noise);
      sig = SinOsc.ar(freq);
      env = EnvGen.kr(Env.triangle, doneAction: 2);

      sig = sig * env * 0.5;
      sig = Pan2.ar(sig, pos: pos, level: level);
      Out.ar(0, sig);
    }
  ).add;
);

(
  a = Pbind(
    \instrument, \sineWave,
    \base_freq, Pwrand([150, 40], [0.75, 0.25], 20),
    \dur, Pwrand([0.5, 0.75, 0.05], [0.6, 0.3, 0.1], inf),
    \pos, Pseq([-1, -0.5, 0, 0.5, 1], inf),
    \level, 0.25,
    \harmonic_range, 3
  ).play;

);
