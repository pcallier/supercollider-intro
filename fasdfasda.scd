(
MIDIClient.init;
MIDIClient.sources;
MIDIIn.connectAll;
s.boot;
)
MIDIFunc.trace(false);

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
)

~control_mapping[24];
~note_mapping[36];

(
SynthDef(\basicWave, {
    arg freq, amp, gate, peak=0.75, vel=0.45, detune=0.0;
    var sig, env, trem;
    trem = SinOsc.ar(6, mul: 10 * detune, add: freq);
    sig = LFTri.ar(trem, mul: amp/3)!2;

    env = EnvGen.kr(Env.adsr(attackTime: vel, peakLevel: peak, sustainLevel: amp), gate, doneAction: 2);
    sig = sig * env;
    Out.ar(0, sig);
}).add;



MIDIdef.noteOn(\downNote, {
    arg val, num, chan, src;
    var note, freq, vel, peak;
    note = ~note_mapping[num];
    num.postln;
    freq = (num + ~midi_adjust).midicps;
    vel = val.linexp(1, 127, 0.35, 0.01);
    peak = val.linexp(1, 127, 0.05, 0.95);
    if(note.notNil, {
        ~notes[note] = Synth(\basicWave,
            [\freq, freq,
                \amp, peak,
                \gate, 1,
                \peak, 0.95,
                \vel, vel

        ]);
    ('ON num: ' ++ num ++ ' val: ' ++ val).postln;
    });
});

MIDIdef.cc(\Pressure, {
    arg val, num, chan, src;
    var note, fn, new_amp, detune;
    note = ~control_mapping[num][0];
    fn = ~control_mapping[num][1];
    // Amp on pressure
    if(note.notNil && fn == \pressure, {
        new_amp = val.linexp(1, 127, 0.35, 1.25);
        ~notes[note].set(\amp, new_amp);
        //('CC num: ' ++ num ++ ' val: ' ++ val ++ ' amp: ' ++ new_amp).postln;
    });
    // Detune on x
    if(note.notNil && fn == \x, {
        detune = val.linlin(0, 127, -0.02, 0.02);
        ~notes[note].set(\detune, detune);
        //('CC num: ' ++ num ++ ' val: ' ++ val ++ ' detune: ' ++ detune).postln;
    })
});


MIDIdef.noteOff(\upNote, {
    arg val, num;
    var note = ~note_mapping[num];
    if (note.notNil, {
        ~notes[note].set(\gate, 0);
        ~notes[note] = nil;
    });
});

)
~cc_mapping[24]
a=Synth(\basicWave, [\freq,220, \amp,0.75, \gate,1]);
a.set(\gate, 0);
~notes[16]
MIDIdef.cc(\downNote).free;
s.scope
Env.adsr(attackTime: 0.05, peakLevel: 0.45, sustainLevel:0.45).plot;