
(
var which_device;
MIDIClient.init;
// Find and connect to QuNeo
MIDIIn.connect(device: MIDIIn.findPort("QUNEO", "QUNEO MIDI 1"));
s.boot;
s.scope;
)

(
~notes = Array.fill(100, nil);
// Associate control numbers with pads and functions
~cc = (23..70);
~pad = (0..15).stutter(3);
~fns = [\pressure, \x, \y].wrapExtend(48);
~control_mapping = Dictionary.newFrom(48.collect{|i| [~cc[i], [~pad[i], ~fns[i]]]}.flatten);
// Associate pads with notes (for this preset)
~note_mapping = Dictionary.newFrom((36..51).collect{|i| [i, i-36]}.flatten) ++  Dictionary.newFrom((52..67).collect{|i| [i, i-52]}.flatten) ++
Dictionary.newFrom((68..83).collect{|i| [i, i-68]}.flatten) ++
Dictionary.newFrom((84..99).collect{|i| [i, i-84]}.flatten);


/*
~note_mapping = Dictionary.newFrom((0..63).collect{|i| [i, i]}.flatten);
~control_mapping = Dictionary.newFrom((0..63).collect{|i| [i, [i, \pressure]]}.flatten)
~midi_adjust=24;
*/
~midi_adjust=0;

// Configuration variables
~instrument_names = [\squareWaves, \basicWave, \basicPerc, \strikePerc];
~play_button=26;
~stop_button=25;
~record_button=24;

// Lights -- connect using qjackctl
m=MIDIOut(0);

)

(

// Some functions
~amp_mapping = { |x| x.lincurve(1,127,0.35, 0.65) };
~vel_mapping = { |val| val.linlin(1, 127, 0.10, 0.01) };

SynthDef(\basicWave, {
  arg freq, amp, gate, peak=0.75, vel=0.45, detune=0.0;
  var sig, env, trem;
  trem = SinOsc.ar(6, mul: 10 * detune, add: freq, phase: Rand());
  sig = LFTri.ar(trem)!2;

  env = EnvGen.kr(Env.adsr(attackTime: vel, peakLevel: peak, sustainLevel: amp), gate, doneAction: 2);
  sig = sig * env;
  Out.ar(0, sig);
}).add;

// ?
SynthDef(\squareWaves, {
  arg freq, amp, gate, vel=0.05;
  var sig, env, amps, num_waves=5;
  sig = 0;
  // amplitude decay for each component
  //amps = (1..num_waves).collect{|x|
  //  1/num_waves.pow(x)}.normalizeSum;
  amps = (num_waves..1).normalizeSum * amp;
  amps.postln;
  num_waves.do{ |i|
    sig = sig + VarSaw.ar(freq * (i+1)) * amps[i];
  };

  env = EnvGen.kr(Env.adsr(attackTime: vel, peakLevel: amp, releaseTime: 2*vel, curve: -1),
    gate, doneAction: 2);

  sig = sig * env * 10;
  Out.ar(0, sig!2);
}).add;
Env.adsr(0.01, 1, curve: 5).plot;

SynthDef(\basicPerc, {
  arg freq, amp, gate, peak=1;
  var sig, env, strike;
  sig = SinOsc.ar(freq)!2;
  strike = BPF.ar(WhiteNoise.ar(mul: 1.25), freq, 1.5) * EnvGen.kr(Env.perc(releaseTime: 0.025));
  sig = sig + strike;

  env = EnvGen.kr(Env.perc(level: amp * peak), gate, doneAction: 2);
  sig = sig * env;
  Out.ar(0, sig);
}).add;

SynthDef(\strikePerc, {
  arg freq, amp, peak=1;
  var sig, env;
  sig = BPF.ar(BrownNoise.ar(mul: 1.25), freq, 1.5);

  env = EnvGen.kr(Env.perc(releaseTime: 0.05, level: amp * peak), doneAction: 2);
  sig = sig * env;
  Out.ar(0, sig);
}).add;

MIDIdef.noteOn(\downNote, {
  arg val, num, chan, src;
  var note, freq, vel, amp;
  case
  // Notes sent from pads
  {(num >= 36) && (num < 100)} {
    note = ~note_mapping[num];
    num.postln;
    freq = (num + ~midi_adjust).midicps;
    vel = ~vel_mapping.value(val);
    amp = ~amp_mapping.value(val);
    ~notes[note] = Synth(~instrument_names[0],
      [
        \freq, freq,
        \amp, amp,
        \gate, 1,
        \peak, 0.35,
        \vel, vel
    ]);
    ('ON num: ' ++ num ++ ' val: ' ++ val).postln;
  }
  // Arrows below pads
  {(num >= 20) && (num < 24)} {
    switch (num,
      // Switch instruments
      // Up
      20, {
        ~instrument_names.add(~instrument_names.removeAt(0));
        ~instrument_names[0].postln;
      },
      // Down
      21, {
        ~instrument_names.addFirst(~instrument_names.pop);
        ~instrument_names[0].postln;
    },
      22, {
        TempoClock.default.tempo = TempoClock.default.tempo + 0.1;
      },
      23, {
        TempoClock.default.tempo = TempoClock.default.tempo - 0.1;
      }
    );
  }
  // Play button
  {num==~play_button}{
    try {~metronome.stop; ~metronome.free; ~metronome=nil};
    ~metronome = Pbind(\dur, Pseq([0.1, 0.9], repeats: inf),
      \freq, Pseq([8000, \rest], repeats: inf),
      \instrument, \strikePerc,
      \amp, 1.0
    ).play(quant: 1);

    // Lights
    ~metro_lights = Pbind(
      \type, \midi,
      \midicmd, \noteOn,
      \midiout, m,
      \chan, 0,
      \midinote, Pseq([25, \rest, 27, \rest, 29, \rest, 31, \rest], repeats: inf),
      \dur, Pseq([0.9, 0.1], repeats: inf)
    ).play(quant: 1);

  }
  {num==~stop_button}{
    try {
      ~metronome.stop; ~metronome.free; ~metronome=nil;
      ~metro_lights.stop; ~metro_lights.free; m.allNotesOff;
    };
  };
});

MIDIdef.cc(\controlResponse, {
  arg val, num, chan, src;
  var note, fn, new_amp, detune;
  // Get note and function from control dictionaries
  try
  {note = ~control_mapping[num][0];
    fn = ~control_mapping[num][1];} {};
  case
  {note.notNil} {
    // Amp on pressure
    case
    {fn == \pressure} {
      new_amp = ~amp_mapping.value(val);
      ~notes[note].set(\amp, new_amp);
      //('CC num: ' ++ num ++ ' val: ' ++ val ++ ' amp: ' ++ new_amp).postln;
    }
    // Detune on x
    {fn == \x} {
      detune = val.linlin(0, 127, -0.06, 0.06);
      ~notes[note].set(\detune, detune);
      //('CC num: ' ++ num ++ ' val: ' ++ val ++ ' detune: ' ++ detune).postln;
    };
  };
});

(1..127).explin(1, 127, 0.35, 1.25).plot;
MIDIdef.noteOff(\upNote, {
  arg val, num;
  var note = ~note_mapping[num];
  if (note.notNil, {
    ~notes[note].set(\gate, 0);
    ~notes[note] = nil;
  });
});

)

(
(0..16).select{|i| i.even}.do{|x| m.noteOn(0, x, 100)};
//(128).do{|x| m.noteOn(0, x, 0)};
)

b = [0, 1, 2]
c = Routine({
  4.do{|x| x.yield;}
});
a = [1,2,3];
a.addFirst(a.pop)

TempoClock.default.tempo_(160/60);

MIDIFunc.trace;
MIDIFunc.trace(false);
m.noteOff(0, 29, 100);
~metro_lights.stop;
[ 0.17857510267314, 0.15979602287609, 0.14299176394009, 0.12795465235424, 0.11449885369588, 0.10245807601725, 0.091683514745394, 0.082042013697908 ].plot
(1..4).collect{|x| Env([1,0])[x/5]}.normalizeSum.plot
(1..8).collect{|x| 1/4.pow(x)}.normalizeSum.plot
5.do{|i| i.postln;}

~amp_mapping.value((1..127)).plot;
(6..2).log.normalizeSum.plot