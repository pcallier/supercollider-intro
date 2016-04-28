(
  s.boot
)


(
    var sine_synth = SynthDef.new(\basicSine,
    { | freq, amp=0.3, dur=1.0, peak=0.3 |
     var env = EnvGen.kr(Env.new(levels: [0, amp, 0], 
       times: [dur*peak, dur-(dur*peak)],
       curve: \lin),
       doneAction: 2);
     var out = SinOsc.ar(freq) * env;
     Out.ar(0, out);
    });
    sine_synth.add;
    Archive.global.put(\basicSine, sine_synth);
)

(
    Archive.write;
    Archive.global.postTree;
)

(
    var sine_synth=Archive.global.at(\basicSine);
    sine_synth.add;
)

(
    Synth.new(\basicSine, [freq: exprand(220, 660), 
       dur: 0.15, amp: 0.05, peak: 0.9]);
)

(
var amp=1.0, dur=2.50, peak=0.5;
a=Env.new(levels: [0, amp, 0],
          times: [dur*peak, dur-(dur*peak)],
          curve: \lin,);
a.totalDuration;            
)

(
SynthDescLib.global.synthDescs;
)
