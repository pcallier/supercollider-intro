s.boot;

(
(
SynthDef(\mouseTheremin,
	{
		var sig, amp, freq;
		amp = MouseY.kr.range(0,1);
		freq = MouseX.kr(120, 660);
		sig = Pulse.ar(freq, width: LFTri.kr(2).range(0,1));
		sig = Pan2.ar(sig, pos: SinOsc.kr(0.2).range(0,1));
		sig = sig * amp;
		Out.ar([0,1], sig);
	}).add;
);

(
x = Synth(\mouseTheremin);
);
)
