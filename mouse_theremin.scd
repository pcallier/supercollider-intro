s.boot;

(
SynthDef(\mouseTheremin,
	{
		var sig, amp, freq;
		amp = MouseY.kr.range(0,1);
		freq = MouseX.kr(120, 660);
		sig = Pulse.ar(freq, width: LFTri.kr(2).range(0,1));
		sig = Pan2.ar(sig, pos: 0);
		sig = sig * amp;
		Out.ar(0, sig);
	}).add;
)

(
x = Synth(\mouseTheremin);
)
