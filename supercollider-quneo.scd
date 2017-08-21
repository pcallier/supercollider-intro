s.boot;
MIDIClient.init;
MIDIIn.connect(device: MIDIClient.sources.at(18));
(
MIDIdef.noteOn(\noteOnTest,
  {|val, num, chan, src|

    [val, num].postln;
    {
      var sig, env;
      sig = SinOsc.ar((num+60).midicps)!2;
      env = EnvGen.kr(Env.perc, doneAction: 2);
      sig = sig * env * val.linexp(1, 127, 0.01, 0.3);

    }.play;
});
)

{SinOsc.ar}.play;


MIDIdef.cc(\ccTest,
  { |...args|
    args.postln;
});
s.quit;
MIDIFunc.trace(true)
