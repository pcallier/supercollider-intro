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
