(
s.reboot;
MIDIClient.init;
~qno = Xzzxxyxyzxxzxz();
~mout = MIDIOut(0).connect(MIDIOut.newByName("QUNEO", "QUNEO MIDI 1").uid);
)


(
Pbind(
  \type, \midi,
  \midicmd,Pseq([\noteOn, \noteOff], inf),
  \midiout, ~mout,
  \chan, 0,
  \midinote, Pseq([25, 25], inf),
  \dur, Pseq([0.9, 0.1], inf)
).play(quant: 1);
)

//All Off
(
Pbind(\type, \midi,
  \midicmd, \control,
  \midiout, ~mout,
  \chan, 0
).play;
)

(
Pbind(
  \type, \midi,
  \midicmd, \noteOn,
  \midiout, ~mout,
  \chan, 0,
  // \midinote, Ptuple([Pshuf(~ccOut.values),
  //   Pshuf(~ccOut.values),Pshuf(~ccOut.values),
  //   Pshuf(~ccOut.values),Pshuf(~ccOut.values),
  //   Pshuf(~ccOut.values),Pshuf(~ccOut.values),
  // ], inf),
  \midinote, (1,9..31),
  \amp, Pseq((0.05, 0.06..0.90) ++ (0.90, 0.89..0.05), repeats:inf),
  \dur, 0.01,
  \hasGate, false
).play(quant: 0.5).trace;
)


