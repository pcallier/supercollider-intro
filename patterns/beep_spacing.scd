s.boot;
s.plotTree
(
SynthDef(\anInstrument, {
  arg freq=220, atk=0.05, rel=0.2, trig=1.0, amp=0.3, out=0;
  var env, sig;

  env = EnvGen.kr(Env(levels: [0, 1, 0, 0], times: [atk, rel, 1.0]), gate: trig, doneAction: 2);
  sig = VarSaw.ar(freq) * env;
  sig = FreeVerb.ar(sig, mix: 0.7, room: 0.75, damp: 0.15);

  Out.ar(out, sig);
}).add;
)

// Pattern of random spacing between tones
(
Pdef(\test,
  Pbind(
    \instrument, \anInstrument,
    \rel, 0.3,
    \atk, 0.01,
    \amp, 0.05,
    \freq, Pseq([220, Rest], inf),
    \note_spacing, Pbrown(0.2, 1.0, 0.05),
    \dur, Pseq([0,
      Pwhite(Pkey(\note_spacing) / 5, Pkey(\note_spacing), 1)
    ], inf),
  ).trace(\note_spacing, prefix: "Note spacing: ");
).play;
)
Pdef(\test).stop;
