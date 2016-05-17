// Intervals practice

(
s.boot;
s.scope(2);
FreqScope.new(width: 600, height: 300);
)

// Basic intervals
(
var scale=Scale.major;
var deg=scale.degrees[1..];
var root=8;
var instr=SynthDef(\sinePerc,
	{ |freq, amp, dur|
		var sig = SinOsc.ar(freq: freq) *
		EnvGen.ar(Env.perc(0.08, dur - 0.08 - 0.001, level: amp), doneAction: 2);
		"Hello".postln;
		Out.ar([0], sig);
}).add;
var step_pattern=Pbind(*[
	root:   Pseq([root], inf),
	degree: Place([0, deg, \rest], inf),
	amp: 0.1,
	instrument: \sinePerc,
	dur:    Pseq([0.5, 1.0, 0.1], 10);
]);

//step_pattern.play;
deg.postln;
step_pattern.trace.play;
)


// Cute example of random mixes of notes
(
var scale=Scale.major;
var deg=scale.degrees[1..];
var root=8;
var instr=SynthDef(\sinePerc,
	{ |freq, amp, dur|
		var sig = SinOsc.ar(freq: freq) *
		EnvGen.ar(Env.perc(0.08, dur - 0.08 - 0.001, level: amp), doneAction: 2);
		Out.ar([0], sig);
}).add;
var step_pattern=Pbind(*[
	root:   Pseq([root], inf),
	degree: Place([Pn(Pxrand(deg),2), \rest], inf),
	amp: 0.1,
	instrument: \sinePerc,
	dur:    Pseq([0.5, 1.0, 0.1], 8);
]);

//step_pattern.play;
deg.postln;
5.do{step_pattern.trace.play};
)
