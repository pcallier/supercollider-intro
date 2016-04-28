(
  //s.options.maxNodes=256;
  s.reboot;
  "MaxNodes: ".post; s.options.maxNodes.postln;
)

s.freeAll;
SystemClock.sched(5, { "hello".postln });

(
var timeNow = TempoClock.default.beats;
"Time is now: ".post; timeNow.postln;
"Scheduling for:".post; (timeNow + 5).postln;
TempoClock.default.schedAbs(timeNow + 5,
    { "Time is later: ".post; thisThread.clock.beats.postln; nil });
)

(
r = Routine({
 "abcde".yield;
 "fghij".yield;
 "klmno".yield;
 "pqrst".yield;
 "uvxwy".yield;
 "z{|}~".yield;
 });

 6.do({ r.next.postln; });
)

(
// time to wait returned by routine
r = Routine({
 var delta;
 loop {
  delta = rrand(1,3) * 0.5;
  "Waiting ".post; delta.postln;
  delta.yield;
 }
});

r.next;

TempoClock.default.sched(0,r);
)
r.stop;

(
SynthDef(\singrain, { |freq = 440, amp = 0.2, sustain = 1|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.perc(0.01, sustain), doneAction: 2);
    Out.ar(0, sig ! 2);    // sig ! 2 is the same as [sig, sig]
}).add;

r = Routine({
  var delta;
  loop {
    delta = rrand(1, 3) * 0.5;
    //s.sync;
    "delta ".post; delta.postln;
    Synth(\singrain, [freq: exprand(200, 800), amp: rrand(0.1, 0.5), 
      sustain: delta * 0.8]);
    delta.yield;
  }
});
)

r.play;
r.stop;
s.queryAllNodes
s.reboot;
