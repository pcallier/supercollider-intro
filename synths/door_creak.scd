s.boot;
(
{ Blip.ar(freq: XLine.kr(start: 550, end: 150, dur: 0.9, doneAction: 2) +
	SinOsc.kr(freq: CombC.kr(WhiteNoise.ar(50), 0.02, Line.kr(50,80)), mul: 20)
) }.play;


s.freeAll;
)